-- Starlistアプリケーションのデータベース設定スクリプト

-- ユーザーテーブルの作成
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    username TEXT UNIQUE,
    display_name TEXT,
    profile_image_url TEXT,
    bio TEXT,
    is_star BOOLEAN DEFAULT FALSE, -- スター（情報を共有する人）フラグ
    follower_count INTEGER DEFAULT 0,
    star_rank TEXT DEFAULT 'none',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    social_links JSONB DEFAULT '{}'::jsonb,
    preferences JSONB DEFAULT '{
        "dark_mode": false,
        "notifications_enabled": true,
        "privacy_settings": {
            "profile_visible": true,
            "activity_visible": true
        },
        "language": "ja"
    }'::jsonb
);

-- ユーザーテーブルのサインアップトリガー
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, username, display_name, created_at, updated_at)
    VALUES (new.id, new.email, new.raw_user_meta_data->>'username', new.raw_user_meta_data->>'display_name', now(), now());
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- トリガーが存在しない場合のみ作成
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_trigger WHERE tgname = 'on_auth_user_created'
    ) THEN
        CREATE TRIGGER on_auth_user_created
            AFTER INSERT ON auth.users
            FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
    END IF;
END $$;

-- お気に入りアイテムテーブル（ユーザーがお気に入りに追加したアイテム）
CREATE TABLE IF NOT EXISTS public.favorite_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL, -- 'youtube', 'article', 'product', etc.
    item_id TEXT NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    url TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, item_type, item_id)
);

-- コメントテーブル
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    item_id UUID REFERENCES public.favorite_items(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- フォロー関係
CREATE TABLE IF NOT EXISTS public.follows (
    follower_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id)
);

-- フォロー数を更新するトリガー関数
CREATE OR REPLACE FUNCTION public.update_follower_count() 
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE public.users
        SET follower_count = follower_count + 1
        WHERE id = NEW.following_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE public.users
        SET follower_count = follower_count - 1
        WHERE id = OLD.following_id AND follower_count > 0;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- フォローテーブルのトリガー
CREATE TRIGGER update_follower_count
    AFTER INSERT OR DELETE ON public.follows
    FOR EACH ROW EXECUTE FUNCTION public.update_follower_count();

-- 閲覧履歴
CREATE TABLE IF NOT EXISTS public.view_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    item_type TEXT NOT NULL,
    item_id TEXT NOT NULL,
    title TEXT NOT NULL,
    thumbnail_url TEXT,
    viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RPC関数：スキーマバージョンの取得
CREATE OR REPLACE FUNCTION public.get_schema_version()
RETURNS TEXT AS $$
BEGIN
    RETURN '1.0.0';
END;
$$ LANGUAGE plpgsql;

-- RPC関数：システムの状態チェック
CREATE OR REPLACE FUNCTION public.get_system_health()
RETURNS JSONB AS $$
BEGIN
    RETURN jsonb_build_object(
        'status', 'healthy',
        'timestamp', now(),
        'schema_version', public.get_schema_version()
    );
END;
$$ LANGUAGE plpgsql;

-- ヘルスチェック用のテーブル
CREATE TABLE IF NOT EXISTS public._service_status (
    id SERIAL PRIMARY KEY,
    service_name TEXT NOT NULL,
    status TEXT NOT NULL,
    last_checked TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 初期データの挿入
INSERT INTO public._service_status (service_name, status)
VALUES ('database', 'ok')
ON CONFLICT DO NOTHING;

-- Row Level Security (RLS) ポリシーの設定
-- すべてのテーブルにセキュリティを有効化
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorite_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.view_history ENABLE ROW LEVEL SECURITY;

-- ユーザーテーブルのポリシー
CREATE POLICY "ユーザーは自分のプロファイルを更新可能" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "ユーザーは自分のプロファイルを読み取り可能" ON public.users
    FOR SELECT USING (true);

-- お気に入りアイテムのポリシー
CREATE POLICY "ユーザーは自分のお気に入りアイテムを作成可能" ON public.favorite_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分のお気に入りアイテムを更新可能" ON public.favorite_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分のお気に入りアイテムを削除可能" ON public.favorite_items
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "すべてのユーザーはお気に入りアイテムを閲覧可能" ON public.favorite_items
    FOR SELECT USING (true);

-- 他のテーブルにも同様のポリシーを設定
-- ... 