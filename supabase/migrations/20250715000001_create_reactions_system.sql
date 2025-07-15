-- リアクションシステムの実装
-- 投稿とコメントに対する👍と❤️のリアクション機能

-- 投稿リアクションテーブル
CREATE TABLE IF NOT EXISTS public.post_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  post_id UUID NOT NULL, -- contents テーブルを参照
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('like', 'heart')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 1ユーザーが1投稿に対して各リアクションタイプを1回のみ
  UNIQUE (user_id, post_id, reaction_type)
);

-- コメントリアクションテーブル
CREATE TABLE IF NOT EXISTS public.comment_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  comment_id UUID NOT NULL, -- comments テーブルを参照
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('like', 'heart')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 1ユーザーが1コメントに対して各リアクションタイプを1回のみ
  UNIQUE (user_id, comment_id, reaction_type)
);

-- RLS（Row Level Security）の有効化
ALTER TABLE public.post_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comment_reactions ENABLE ROW LEVEL SECURITY;

-- 投稿リアクションのRLSポリシー
CREATE POLICY "Anyone can view post reactions" ON public.post_reactions
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own post reactions" ON public.post_reactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own post reactions" ON public.post_reactions
  FOR DELETE USING (auth.uid() = user_id);

-- コメントリアクションのRLSポリシー
CREATE POLICY "Anyone can view comment reactions" ON public.comment_reactions
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own comment reactions" ON public.comment_reactions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own comment reactions" ON public.comment_reactions
  FOR DELETE USING (auth.uid() = user_id);

-- インデックスの作成（パフォーマンス向上）
CREATE INDEX IF NOT EXISTS idx_post_reactions_post_id ON public.post_reactions(post_id);
CREATE INDEX IF NOT EXISTS idx_post_reactions_user_id ON public.post_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_post_reactions_type ON public.post_reactions(reaction_type);
CREATE INDEX IF NOT EXISTS idx_post_reactions_created_at ON public.post_reactions(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_comment_reactions_comment_id ON public.comment_reactions(comment_id);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_user_id ON public.comment_reactions(user_id);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_type ON public.comment_reactions(reaction_type);
CREATE INDEX IF NOT EXISTS idx_comment_reactions_created_at ON public.comment_reactions(created_at DESC);

-- 投稿リアクション数集計関数
CREATE OR REPLACE FUNCTION get_post_reaction_counts(post_uuid UUID)
RETURNS TABLE (
  reaction_type TEXT,
  count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pr.reaction_type,
    COUNT(*) as count
  FROM public.post_reactions pr
  WHERE pr.post_id = post_uuid
  GROUP BY pr.reaction_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- コメントリアクション数集計関数
CREATE OR REPLACE FUNCTION get_comment_reaction_counts(comment_uuid UUID)
RETURNS TABLE (
  reaction_type TEXT,
  count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    cr.reaction_type,
    COUNT(*) as count
  FROM public.comment_reactions cr
  WHERE cr.comment_id = comment_uuid
  GROUP BY cr.reaction_type;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ユーザーの投稿リアクション取得関数
CREATE OR REPLACE FUNCTION get_user_post_reactions(post_uuid UUID, user_uuid UUID)
RETURNS TABLE (
  reaction_type TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT pr.reaction_type
  FROM public.post_reactions pr
  WHERE pr.post_id = post_uuid AND pr.user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ユーザーのコメントリアクション取得関数
CREATE OR REPLACE FUNCTION get_user_comment_reactions(comment_uuid UUID, user_uuid UUID)
RETURNS TABLE (
  reaction_type TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT cr.reaction_type
  FROM public.comment_reactions cr
  WHERE cr.comment_id = comment_uuid AND cr.user_id = user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- リアクション切り替え関数（投稿用）
CREATE OR REPLACE FUNCTION toggle_post_reaction(
  post_uuid UUID,
  user_uuid UUID,
  reaction_type_param TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  reaction_exists BOOLEAN;
BEGIN
  -- リアクションが存在するかチェック
  SELECT EXISTS(
    SELECT 1 FROM public.post_reactions 
    WHERE post_id = post_uuid 
    AND user_id = user_uuid 
    AND reaction_type = reaction_type_param
  ) INTO reaction_exists;
  
  IF reaction_exists THEN
    -- リアクションを削除
    DELETE FROM public.post_reactions 
    WHERE post_id = post_uuid 
    AND user_id = user_uuid 
    AND reaction_type = reaction_type_param;
    RETURN FALSE;
  ELSE
    -- リアクションを追加
    INSERT INTO public.post_reactions (user_id, post_id, reaction_type)
    VALUES (user_uuid, post_uuid, reaction_type_param);
    RETURN TRUE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- リアクション切り替え関数（コメント用）
CREATE OR REPLACE FUNCTION toggle_comment_reaction(
  comment_uuid UUID,
  user_uuid UUID,
  reaction_type_param TEXT
) RETURNS BOOLEAN AS $$
DECLARE
  reaction_exists BOOLEAN;
BEGIN
  -- リアクションが存在するかチェック
  SELECT EXISTS(
    SELECT 1 FROM public.comment_reactions 
    WHERE comment_id = comment_uuid 
    AND user_id = user_uuid 
    AND reaction_type = reaction_type_param
  ) INTO reaction_exists;
  
  IF reaction_exists THEN
    -- リアクションを削除
    DELETE FROM public.comment_reactions 
    WHERE comment_id = comment_uuid 
    AND user_id = user_uuid 
    AND reaction_type = reaction_type_param;
    RETURN FALSE;
  ELSE
    -- リアクションを追加
    INSERT INTO public.comment_reactions (user_id, comment_id, reaction_type)
    VALUES (user_uuid, comment_uuid, reaction_type_param);
    RETURN TRUE;
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 更新日時の自動更新トリガー
CREATE OR REPLACE FUNCTION update_reaction_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 投稿リアクションの更新日時トリガー
CREATE TRIGGER update_post_reactions_updated_at
  BEFORE UPDATE ON public.post_reactions
  FOR EACH ROW EXECUTE FUNCTION update_reaction_updated_at();

-- コメントリアクションの更新日時トリガー
CREATE TRIGGER update_comment_reactions_updated_at
  BEFORE UPDATE ON public.comment_reactions
  FOR EACH ROW EXECUTE FUNCTION update_reaction_updated_at();

-- リアクションシステムの権限設定
GRANT SELECT, INSERT, DELETE ON public.post_reactions TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.comment_reactions TO authenticated;
GRANT EXECUTE ON FUNCTION get_post_reaction_counts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_comment_reaction_counts(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_post_reactions(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_comment_reactions(UUID, UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_post_reaction(UUID, UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION toggle_comment_reaction(UUID, UUID, TEXT) TO authenticated;