-- =============================================
-- Starlist 検索機能用RLS（Row Level Security）設定
-- =============================================

BEGIN;

-- 1. RLSを有効化
ALTER TABLE contents ENABLE ROW LEVEL SECURITY;
ALTER TABLE tag_only_ingests ENABLE ROW LEVEL SECURITY;
ALTER TABLE search_history ENABLE ROW LEVEL SECURITY;

-- 2. contents テーブルのRLSポリシー
-- 既存のポリシーがある場合は削除して再作成
DO $$
BEGIN
  -- SELECT ポリシー: 公開コンテンツまたは自分のコンテンツを閲覧可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'contents' AND policyname = 'contents_select_policy'
  ) THEN
    DROP POLICY contents_select_policy ON contents;
  END IF;
  
  CREATE POLICY contents_select_policy ON contents
    FOR SELECT 
    USING (
      privacy_level = 'public' OR 
      user_id = auth.uid() OR
      (privacy_level = 'followers_only' AND user_id IN (
        SELECT followed_user_id FROM user_follows 
        WHERE follower_user_id = auth.uid()
      ))
    );

  -- INSERT ポリシー: 認証済みユーザーが自分のコンテンツを作成可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'contents' AND policyname = 'contents_insert_policy'
  ) THEN
    DROP POLICY contents_insert_policy ON contents;
  END IF;
  
  CREATE POLICY contents_insert_policy ON contents
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

  -- UPDATE ポリシー: 自分のコンテンツのみ更新可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'contents' AND policyname = 'contents_update_policy'
  ) THEN
    DROP POLICY contents_update_policy ON contents;
  END IF;
  
  CREATE POLICY contents_update_policy ON contents
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

  -- DELETE ポリシー: 自分のコンテンツのみ削除可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'contents' AND policyname = 'contents_delete_policy'
  ) THEN
    DROP POLICY contents_delete_policy ON contents;
  END IF;
  
  CREATE POLICY contents_delete_policy ON contents
    FOR DELETE
    USING (auth.uid() = user_id);
END$$;

-- 3. tag_only_ingests テーブルのRLSポリシー
DO $$
BEGIN
  -- SELECT ポリシー: 自分のタグデータのみ閲覧可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'tag_only_ingests' AND policyname = 'select_own_tag_only'
  ) THEN
    DROP POLICY select_own_tag_only ON tag_only_ingests;
  END IF;
  
  CREATE POLICY select_own_tag_only ON tag_only_ingests
    FOR SELECT 
    USING (user_id = auth.uid());

  -- INSERT ポリシー: 認証済みユーザーが自分のタグデータを挿入可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'tag_only_ingests' AND policyname = 'insert_own_tag_only'
  ) THEN
    DROP POLICY insert_own_tag_only ON tag_only_ingests;
  END IF;
  
  CREATE POLICY insert_own_tag_only ON tag_only_ingests
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

  -- UPDATE ポリシー: 自分のタグデータのみ更新可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'tag_only_ingests' AND policyname = 'update_own_tag_only'
  ) THEN
    DROP POLICY update_own_tag_only ON tag_only_ingests;
  END IF;
  
  CREATE POLICY update_own_tag_only ON tag_only_ingests
    FOR UPDATE
    USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

  -- DELETE ポリシー: 自分のタグデータのみ削除可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'tag_only_ingests' AND policyname = 'delete_own_tag_only'
  ) THEN
    DROP POLICY delete_own_tag_only ON tag_only_ingests;
  END IF;
  
  CREATE POLICY delete_own_tag_only ON tag_only_ingests
    FOR DELETE
    USING (user_id = auth.uid());
END$$;

-- 4. search_history テーブルのRLSポリシー
DO $$
BEGIN
  -- SELECT ポリシー: 自分の検索履歴のみ閲覧可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'search_history' AND policyname = 'select_own_search_history'
  ) THEN
    DROP POLICY select_own_search_history ON search_history;
  END IF;
  
  CREATE POLICY select_own_search_history ON search_history
    FOR SELECT 
    USING (user_id = auth.uid());

  -- INSERT ポリシー: 認証済みユーザーが自分の検索履歴を追加可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'search_history' AND policyname = 'insert_own_search_history'
  ) THEN
    DROP POLICY insert_own_search_history ON search_history;
  END IF;
  
  CREATE POLICY insert_own_search_history ON search_history
    FOR INSERT
    WITH CHECK (user_id = auth.uid());

  -- DELETE ポリシー: 自分の検索履歴のみ削除可能
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'search_history' AND policyname = 'delete_own_search_history'
  ) THEN
    DROP POLICY delete_own_search_history ON search_history;
  END IF;
  
  CREATE POLICY delete_own_search_history ON search_history
    FOR DELETE
    USING (user_id = auth.uid());
END$$;

-- 5. 検索に必要な補助テーブル（user_follows）が存在しない場合の作成
-- ※ 既存のテーブルがある場合はスキップ
CREATE TABLE IF NOT EXISTS user_follows (
    id BIGSERIAL PRIMARY KEY,
    follower_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    followed_user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 重複フォロー防止
    CONSTRAINT unique_follow UNIQUE (follower_user_id, followed_user_id),
    
    -- 自分自身をフォローできない
    CONSTRAINT no_self_follow CHECK (follower_user_id != followed_user_id)
);

-- user_follows テーブルのRLS設定
ALTER TABLE user_follows ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  -- フォロー関係の閲覧は全ユーザー可能（プライバシー設定は別途実装）
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'user_follows' AND policyname = 'user_follows_select_policy'
  ) THEN
    DROP POLICY user_follows_select_policy ON user_follows;
  END IF;
  
  CREATE POLICY user_follows_select_policy ON user_follows
    FOR SELECT 
    USING (true); -- 全ユーザーが閲覧可能

  -- フォロー関係の作成は認証済みユーザーのみ
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'user_follows' AND policyname = 'user_follows_insert_policy'
  ) THEN
    DROP POLICY user_follows_insert_policy ON user_follows;
  END IF;
  
  CREATE POLICY user_follows_insert_policy ON user_follows
    FOR INSERT
    WITH CHECK (auth.uid() = follower_user_id);

  -- フォロー関係の削除は自分がフォローしたもののみ
  IF EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' AND tablename = 'user_follows' AND policyname = 'user_follows_delete_policy'
  ) THEN
    DROP POLICY user_follows_delete_policy ON user_follows;
  END IF;
  
  CREATE POLICY user_follows_delete_policy ON user_follows
    FOR DELETE
    USING (auth.uid() = follower_user_id);
END$$;

-- 6. インデックス追加（フォローテーブル用）
CREATE INDEX IF NOT EXISTS idx_user_follows_follower ON user_follows (follower_user_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_followed ON user_follows (followed_user_id);
CREATE INDEX IF NOT EXISTS idx_user_follows_created_at ON user_follows (created_at DESC);

COMMIT;