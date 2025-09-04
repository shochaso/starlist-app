-- Starlistアプリケーションのデータベース設定スクリプト
-- ER図設計書に基づいた実装: 2025-04-02
-- 2025-09-04: s_points と s_point_transactions を追加

-- ユーザーテーブルの作成
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    username TEXT UNIQUE,
    display_name TEXT,
    profile_image_url TEXT,
    bio TEXT,
    is_star BOOLEAN DEFAULT FALSE, -- スター（情報を共有する人）フラグ
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
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

-- スタープロフィールテーブル
CREATE TABLE IF NOT EXISTS public.star_profiles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL CHECK (category IN ('entertainer', 'athlete', 'creator', 'vtuber', 'musician', 'actor', 'other')),
  description TEXT,
  paid_follower_count INTEGER DEFAULT 0,
  star_rank TEXT DEFAULT 'regular' CHECK (star_rank IN ('regular', 'platinum', 'super')),
  revenue_share_rate DECIMAL(5,2) DEFAULT 80.00 CHECK (revenue_share_rate BETWEEN 0 AND 100),
  verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE (user_id)
);

-- コンテンツテーブル
CREATE TABLE IF NOT EXISTS public.contents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL CHECK (type IN ('video', 'image', 'text', 'link')),
  url TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  is_published BOOLEAN DEFAULT TRUE,
  likes INTEGER DEFAULT 0,
  comments INTEGER DEFAULT 0,
  shares INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- コンテンツ消費テーブル
CREATE TABLE IF NOT EXISTS public.content_consumptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content_type TEXT NOT NULL CHECK (content_type IN ('youtube', 'spotify', 'netflix', 'book', 'product', 'other')),
  content_id TEXT,
  title TEXT NOT NULL,
  description TEXT,
  platform TEXT,
  url TEXT,
  consumption_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  duration INTEGER,
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  is_public BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- サブスクリプションプランテーブル
CREATE TABLE IF NOT EXISTS public.subscription_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'JPY',
  interval TEXT NOT NULL CHECK (interval IN ('monthly', 'yearly')),
  features JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- サブスクリプションテーブル
CREATE TABLE IF NOT EXISTS public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  star_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  plan_id UUID NOT NULL REFERENCES public.subscription_plans(id) ON DELETE RESTRICT,
  status TEXT NOT NULL CHECK (status IN ('active', 'canceled', 'expired')),
  start_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  end_date TIMESTAMP WITH TIME ZONE,
  auto_renew BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (end_date > start_date)
);

-- チケットテーブル
CREATE TABLE IF NOT EXISTS public.tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('bronze', 'silver', 'gold')),
  quantity INTEGER NOT NULL DEFAULT 1 CHECK (quantity >= 0),
  expiry_date TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- チケット使用履歴テーブル
CREATE TABLE IF NOT EXISTS public.ticket_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID NOT NULL REFERENCES public.tickets(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content_id UUID NOT NULL REFERENCES public.contents(id) ON DELETE CASCADE,
  used_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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
  content_id UUID NOT NULL REFERENCES public.contents(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  text TEXT NOT NULL,
  likes INTEGER DEFAULT 0,
  is_hidden BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- いいねテーブル
CREATE TABLE IF NOT EXISTS public.likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  content_id UUID REFERENCES public.contents(id) ON DELETE CASCADE,
  comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (
    (content_id IS NOT NULL AND comment_id IS NULL) OR
    (content_id IS NULL AND comment_id IS NOT NULL)
  ),
  UNIQUE (user_id, content_id),
  UNIQUE (user_id, comment_id)
);

-- フォロー関係
CREATE TABLE IF NOT EXISTS public.follows (
    follower_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id)
);

-- 通知テーブル
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('new_content', 'new_comment', 'new_follower', 'new_like', 'system', 'other')),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  data JSONB DEFAULT '{}'::jsonb,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 支払いテーブル
CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  subscription_id UUID REFERENCES public.subscriptions(id) ON DELETE SET NULL,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT DEFAULT 'JPY',
  status TEXT NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_method TEXT NOT NULL,
  transaction_id TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 分析データテーブル
CREATE TABLE IF NOT EXISTS public.analytics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  event_type TEXT NOT NULL,
  event_data JSONB DEFAULT '{}'::jsonb,
  device_info JSONB DEFAULT '{}'::jsonb,
  ip_address TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

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

-- トリガー：コンテンツのいいね数更新
CREATE OR REPLACE FUNCTION public.update_content_likes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.content_id IS NOT NULL THEN
    UPDATE public.contents SET likes = likes + 1 WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' AND OLD.content_id IS NOT NULL THEN
    UPDATE public.contents SET likes = GREATEST(0, likes - 1) WHERE id = OLD.content_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_content_likes
  AFTER INSERT OR DELETE ON public.likes
  FOR EACH ROW EXECUTE FUNCTION public.update_content_likes();

-- トリガー：コメントのいいね数更新
CREATE OR REPLACE FUNCTION public.update_comment_likes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.comment_id IS NOT NULL THEN
    UPDATE public.comments SET likes = likes + 1 WHERE id = NEW.comment_id;
  ELSIF TG_OP = 'DELETE' AND OLD.comment_id IS NOT NULL THEN
    UPDATE public.comments SET likes = GREATEST(0, likes - 1) WHERE id = OLD.comment_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_comment_likes
  AFTER INSERT OR DELETE ON public.likes
  FOR EACH ROW EXECUTE FUNCTION public.update_comment_likes();

-- トリガー：コンテンツのコメント数更新
CREATE OR REPLACE FUNCTION public.update_content_comments()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.parent_id IS NULL THEN
    UPDATE public.contents SET comments = comments + 1 WHERE id = NEW.content_id;
  ELSIF TG_OP = 'DELETE' AND OLD.parent_id IS NULL THEN
    UPDATE public.contents SET comments = GREATEST(0, comments - 1) WHERE id = OLD.content_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_content_comments
  AFTER INSERT OR DELETE ON public.comments
  FOR EACH ROW EXECUTE FUNCTION public.update_content_comments();

-- トリガー：スタープロフィールの有料フォロワー数更新
CREATE OR REPLACE FUNCTION public.update_paid_follower_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' AND NEW.status = 'active' THEN
    UPDATE public.star_profiles
    SET paid_follower_count = paid_follower_count + 1
    WHERE user_id = NEW.star_id;
  ELSIF TG_OP = 'DELETE' OR (TG_OP = 'UPDATE' AND OLD.status = 'active' AND NEW.status != 'active') THEN
    UPDATE public.star_profiles
    SET paid_follower_count = GREATEST(0, paid_follower_count - 1)
    WHERE user_id = CASE WHEN TG_OP = 'DELETE' THEN OLD.star_id ELSE NEW.star_id END;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER update_paid_follower_count
  AFTER INSERT OR UPDATE OR DELETE ON public.subscriptions
  FOR EACH ROW EXECUTE FUNCTION public.update_paid_follower_count();

-- ユーザーは、スターの場合、スタープロフィールを自動作成するトリガー
CREATE OR REPLACE FUNCTION public.create_star_profile()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_star = true AND (OLD.is_star = false OR OLD.is_star IS NULL) THEN
    INSERT INTO public.star_profiles (user_id, category)
    VALUES (NEW.id, 'other')
    ON CONFLICT (user_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER create_star_profile
  AFTER UPDATE OF is_star ON public.users
  FOR EACH ROW EXECUTE FUNCTION public.create_star_profile();

-- RPC関数：スキーマバージョンの取得
CREATE OR REPLACE FUNCTION public.get_schema_version()
RETURNS TEXT AS $$
BEGIN
    RETURN '2.0.0';
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

-- すべてのテーブルに行レベルセキュリティを有効化
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.star_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.content_consumptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ticket_usages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorite_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.view_history ENABLE ROW LEVEL SECURITY;

-- RLSポリシーの設定
-- ユーザーテーブルのポリシー
CREATE POLICY "ユーザーは自分のプロファイルを更新可能" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "ユーザーは自分のプロファイルを読み取り可能" ON public.users
    FOR SELECT USING (true);

-- スタープロフィール
CREATE POLICY "スターは自分のプロフィールを管理可能" ON public.star_profiles
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "誰でもスタープロフィールを閲覧可能" ON public.star_profiles
  FOR SELECT USING (true);

-- コンテンツ
CREATE POLICY "スターは自分のコンテンツを管理可能" ON public.contents
  FOR ALL USING (auth.uid() = author_id);
CREATE POLICY "公開コンテンツは誰でも閲覧可能" ON public.contents
  FOR SELECT USING (is_published = true);

-- コンテンツ消費
CREATE POLICY "スターは自分の消費データを管理可能" ON public.content_consumptions
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "公開消費データは誰でも閲覧可能" ON public.content_consumptions
  FOR SELECT USING (is_public = true);

-- サブスクリプションプラン
CREATE POLICY "管理者のみプランを管理可能" ON public.subscription_plans
  FOR ALL USING (false);
CREATE POLICY "誰でもプランを閲覧可能" ON public.subscription_plans
  FOR SELECT USING (is_active = true);

-- サブスクリプション
CREATE POLICY "ユーザーは自分のサブスクリプションを管理可能" ON public.subscriptions
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "スターは自分への購読を閲覧可能" ON public.subscriptions
  FOR SELECT USING (auth.uid() = star_id);

-- チケット
CREATE POLICY "ユーザーは自分のチケットを管理可能" ON public.tickets
  FOR ALL USING (auth.uid() = user_id);

-- チケット使用履歴
CREATE POLICY "ユーザーは自分のチケット使用履歴を閲覧可能" ON public.ticket_usages
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "スターは自分のコンテンツのチケット使用履歴を閲覧可能" ON public.ticket_usages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.contents c
      WHERE c.id = content_id AND c.author_id = auth.uid()
    )
  );

-- お気に入りアイテムのポリシー
CREATE POLICY "ユーザーは自分のお気に入りアイテムを作成可能" ON public.favorite_items
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分のお気に入りアイテムを更新可能" ON public.favorite_items
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分のお気に入りアイテムを削除可能" ON public.favorite_items
    FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "すべてのユーザーはお気に入りアイテムを閲覧可能" ON public.favorite_items
    FOR SELECT USING (true);

-- コメント
CREATE POLICY "ユーザーは自分のコメントを管理可能" ON public.comments
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "非表示でないコメントは誰でも閲覧可能" ON public.comments
  FOR SELECT USING (is_hidden = false);
CREATE POLICY "コンテンツ作成者はコメントを管理可能" ON public.comments
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.contents c
      WHERE c.id = content_id AND c.author_id = auth.uid()
    )
  );

-- いいね
CREATE POLICY "ユーザーは自分のいいねを管理可能" ON public.likes
  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "いいねは誰でも閲覧可能" ON public.likes
  FOR SELECT USING (true);

-- フォロー
CREATE POLICY "ユーザーは自分のフォロー関係を管理可能" ON public.follows
    FOR ALL USING (auth.uid() = follower_id);

CREATE POLICY "フォロー関係は誰でも閲覧可能" ON public.follows
    FOR SELECT USING (true);

-- 通知
CREATE POLICY "ユーザーは自分の通知を管理可能" ON public.notifications
  FOR ALL USING (auth.uid() = user_id);

-- 支払い
CREATE POLICY "ユーザーは自分の支払いを閲覧可能" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "スターは自分に関連する支払いを閲覧可能" ON public.payments
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.subscriptions s
      WHERE s.id = subscription_id AND s.star_id = auth.uid()
    )
  );

-- 分析データ
CREATE POLICY "管理者のみ分析データを閲覧可能" ON public.analytics
  FOR SELECT USING (false);
CREATE POLICY "ユーザーは自分の分析データを閲覧可能" ON public.analytics
  FOR SELECT USING (auth.uid() = user_id);

-- 閲覧履歴
CREATE POLICY "ユーザーは自分の閲覧履歴を閲覧可能" ON public.view_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分の閲覧履歴を管理可能" ON public.view_history
    FOR ALL USING (auth.uid() = user_id); 
-- ガチャ回数管理テーブル
CREATE TABLE IF NOT EXISTS public.gacha_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  base_attempts INTEGER NOT NULL DEFAULT 1, -- 基本ガチャ回数（1日1回）
  bonus_attempts INTEGER NOT NULL DEFAULT 0, -- 広告視聴によるボーナス回数
  used_attempts INTEGER NOT NULL DEFAULT 0, -- 使用済み回数
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date),
  CHECK (base_attempts >= 0),
  CHECK (bonus_attempts >= 0),
  CHECK (used_attempts >= 0),
  CHECK (used_attempts <= (base_attempts + bonus_attempts))
);

-- 広告視聴記録テーブル
CREATE TABLE IF NOT EXISTS public.ad_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  ad_type TEXT NOT NULL CHECK (ad_type IN ('video', 'banner', 'interstitial')),
  ad_provider TEXT NOT NULL, -- 広告ネットワーク（Google AdMob, etc.）
  ad_id TEXT NOT NULL, -- 広告ユニットID
  view_duration INTEGER DEFAULT 0, -- 視聴時間（秒）
  completed BOOLEAN DEFAULT FALSE, -- 視聴完了フラグ
  reward_attempts INTEGER DEFAULT 1, -- 獲得するガチャ回数
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  CHECK (view_duration >= 0),
  CHECK (reward_attempts >= 0)
);

-- ガチャ結果履歴テーブル
CREATE TABLE IF NOT EXISTS public.gacha_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  gacha_result JSONB NOT NULL, -- ガチャ結果（ポイント、チケット等）
  attempts_used INTEGER NOT NULL DEFAULT 1, -- 使用した回数
  source TEXT NOT NULL DEFAULT 'normal' CHECK (source IN ('normal', 'bonus')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ガチャ回数管理テーブルに行レベルセキュリティを有効化
ALTER TABLE public.gacha_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_views ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gacha_history ENABLE ROW LEVEL SECURITY;

-- ガチャ回数管理のRLSポリシー
CREATE POLICY "ユーザーは自分のガチャ回数を管理可能" ON public.gacha_attempts
  FOR ALL USING (auth.uid() = user_id);

-- 広告視聴記録のRLSポリシー
CREATE POLICY "ユーザーは自分の広告視聴記録を管理可能" ON public.ad_views
  FOR ALL USING (auth.uid() = user_id);

-- ガチャ履歴のRLSポリシー
CREATE POLICY "ユーザーは自分のガチャ履歴を閲覧可能" ON public.gacha_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分のガチャ履歴を作成可能" ON public.gacha_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ガチャ回数管理の初期化関数
CREATE OR REPLACE FUNCTION public.initialize_daily_gacha_attempts(user_id_param UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO public.gacha_attempts (user_id, date, base_attempts)
  VALUES (user_id_param, CURRENT_DATE, 1)
  ON CONFLICT (user_id, date) DO NOTHING;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 広告視聴によるボーナス回数追加関数
CREATE OR REPLACE FUNCTION public.add_gacha_bonus_attempts(
  user_id_param UUID,
  bonus_count INTEGER
)
RETURNS VOID AS $$
BEGIN
  -- 今日の日付のレコードが存在しない場合は作成
  PERFORM public.initialize_daily_gacha_attempts(user_id_param);
  
  -- ボーナス回数を追加
  UPDATE public.gacha_attempts
  SET bonus_attempts = bonus_attempts + bonus_count,
      updated_at = NOW()
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ガチャ回数消費関数
CREATE OR REPLACE FUNCTION public.consume_gacha_attempt(user_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
  available_attempts INTEGER;
BEGIN
  -- 今日の利用可能な回数を計算
  SELECT (base_attempts + bonus_attempts - used_attempts)
  INTO available_attempts
  FROM public.gacha_attempts
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
  
  -- 回数が不足している場合はfalseを返す
  IF available_attempts IS NULL OR available_attempts <= 0 THEN
    RETURN FALSE;
  END IF;
  
  -- 回数を消費
  UPDATE public.gacha_attempts
  SET used_attempts = used_attempts + 1,
      updated_at = NOW()
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ガチャ回数取得関数
CREATE OR REPLACE FUNCTION public.get_available_gacha_attempts(user_id_param UUID)
RETURNS JSONB AS $$
DECLARE
  result JSONB;
BEGIN
  -- 今日の日付のレコードが存在しない場合は作成
  PERFORM public.initialize_daily_gacha_attempts(user_id_param);
  
  SELECT jsonb_build_object(
    'base_attempts', base_attempts,
    'bonus_attempts', bonus_attempts,
    'used_attempts', used_attempts,
    'available_attempts', (base_attempts + bonus_attempts - used_attempts),
    'date', date
  )
  INTO result
  FROM public.gacha_attempts
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ----------------------------------------------------------------
-- スターポイント (s_points) と関連機能
-- ----------------------------------------------------------------

-- s_points: ユーザーのスターポイント残高を管理
CREATE TABLE IF NOT EXISTS public.s_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  balance INT NOT NULL DEFAULT 0,
  total_earned INT NOT NULL DEFAULT 0,
  total_spent INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id),
  CHECK (balance >= 0),
  CHECK (total_earned >= 0),
  CHECK (total_spent >= 0)
);

-- s_point_transactions: ポイントの増減履歴
CREATE TABLE IF NOT EXISTS public.s_point_transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  amount INT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('earn', 'spend')),
  source TEXT NOT NULL,
  description TEXT,
  metadata JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS (Row Level Security) の有効化
ALTER TABLE public.s_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.s_point_transactions ENABLE ROW LEVEL SECURITY;

-- RLSポリシー: ユーザーは自分のポイント情報のみ操作・閲覧可能
CREATE POLICY "ユーザーは自分のポイント残高を管理可能" ON public.s_points
  FOR ALL USING (auth.uid() = user_id);

CREATE POLICY "ユーザーは自分のポイント履歴を管理可能" ON public.s_point_transactions
  FOR ALL USING (auth.uid() = user_id);

-- RPC: ポイントを付与または消費する関数
CREATE OR REPLACE FUNCTION public.grant_or_spend_s_points(
  user_id_param UUID,
  amount_param INT,
  source_param TEXT,
  description_param TEXT
)
RETURNS JSONB AS $$
DECLARE
  new_balance INT;
  updated_record RECORD;
BEGIN
  -- ユーザーのポイントレコードがなければ作成
  INSERT INTO public.s_points (user_id)
  VALUES (user_id_param)
  ON CONFLICT (user_id) DO NOTHING;

  -- ポイントを加算または減算
  UPDATE public.s_points
  SET
    balance = balance + amount_param,
    total_earned = CASE WHEN amount_param > 0 THEN total_earned + amount_param ELSE total_earned END,
    total_spent = CASE WHEN amount_param < 0 THEN total_spent - amount_param ELSE total_spent END,
    updated_at = NOW()
  WHERE user_id = user_id_param
  RETURNING balance INTO new_balance;

  -- トランザクション履歴を記録
  INSERT INTO public.s_point_transactions (user_id, amount, type, source, description)
  VALUES (user_id_param, amount_param, CASE WHEN amount_param >= 0 THEN 'earn' ELSE 'spend' END, source_param, description_param);

  -- 更新後の残高情報を取得して返す
  SELECT to_jsonb(s.*) INTO updated_record FROM public.s_points s WHERE s.user_id = user_id_param;

  RETURN updated_record;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =================================================================
-- FINAL FIX SCRIPT: Apply Row Level Security (RLS) Policies
-- This script grants permissions for users to access their own data.
-- =================================================================

-- Step 1: Enable Row Level Security on all user-data tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.s_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.s_point_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gacha_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gacha_history ENABLE ROW LEVEL SECURITY;

-- Step 2: Create policies to allow access

-- Policy for 'users' table: Users can see and update their own profile.
DROP POLICY IF EXISTS "Allow individual read access" ON public.users;
CREATE POLICY "Allow individual read access" ON public.users FOR SELECT USING (auth.uid() = id);

DROP POLICY IF EXISTS "Allow individual update access" ON public.users;
CREATE POLICY "Allow individual update access" ON public.users FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- Policy for 's_points' and 's_point_transactions': Users can only read their own point data.
DROP POLICY IF EXISTS "Allow individual read access" ON public.s_points;
CREATE POLICY "Allow individual read access" ON public.s_points FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Allow individual read access" ON public.s_point_transactions;
CREATE POLICY "Allow individual read access" ON public.s_point_transactions FOR SELECT USING (auth.uid() = user_id);

-- Policy for 'gacha_attempts': Users have full control (select, insert, update, delete) over their own attempt records.
-- This is necessary for the "upsert" operation used by the reset button.
DROP POLICY IF EXISTS "Allow full access for own attempts" ON public.gacha_attempts;
CREATE POLICY "Allow full access for own attempts" ON public.gacha_attempts FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- Policy for 'gacha_history': Users can only read their own gacha history.
DROP POLICY IF EXISTS "Allow individual read access" ON public.gacha_history;
CREATE POLICY "Allow individual read access" ON public.gacha_history FOR SELECT USING (auth.uid() = user_id);
