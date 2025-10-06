-- =============================================
-- Starlist 検索機能用テーブル作成マイグレーション
-- =============================================

BEGIN;

-- 1. contents テーブル（既存の可能性があるため、存在しない場合のみ作成）
CREATE TABLE IF NOT EXISTS contents (
    id BIGSERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    body TEXT,
    author TEXT,
    tags TEXT,
    category TEXT,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    privacy_level TEXT DEFAULT 'public' CHECK (privacy_level IN ('public', 'private', 'followers_only')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. tag_only_ingests テーブル
CREATE TABLE IF NOT EXISTS tag_only_ingests (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    source_id TEXT NOT NULL,
    tag_hash TEXT NOT NULL,
    category TEXT NOT NULL,
    payload_json JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- 重複防止用のユニーク制約
    CONSTRAINT unique_tag_ingest UNIQUE (source_id, tag_hash)
);

-- 3. search_history テーブル（検索履歴保存用）
CREATE TABLE IF NOT EXISTS search_history (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    query TEXT NOT NULL,
    search_type TEXT NOT NULL DEFAULT 'content' CHECK (search_type IN ('content', 'user', 'star', 'mixed')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. updated_at の自動更新トリガー関数（存在しない場合のみ作成）
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 5. updated_at トリガーの設定
DROP TRIGGER IF EXISTS update_contents_updated_at ON contents;
CREATE TRIGGER update_contents_updated_at
    BEFORE UPDATE ON contents
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_tag_only_ingests_updated_at ON tag_only_ingests;
CREATE TRIGGER update_tag_only_ingests_updated_at
    BEFORE UPDATE ON tag_only_ingests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 6. インデックス作成（パフォーマンス向上）
-- contents テーブル用インデックス
CREATE INDEX IF NOT EXISTS idx_contents_title_gin ON contents USING gin(to_tsvector('japanese', title));
CREATE INDEX IF NOT EXISTS idx_contents_body_gin ON contents USING gin(to_tsvector('japanese', body));
CREATE INDEX IF NOT EXISTS idx_contents_tags_gin ON contents USING gin(to_tsvector('japanese', tags));
CREATE INDEX IF NOT EXISTS idx_contents_updated_at ON contents (updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_contents_user_id ON contents (user_id);
CREATE INDEX IF NOT EXISTS idx_contents_category ON contents (category);
CREATE INDEX IF NOT EXISTS idx_contents_privacy_level ON contents (privacy_level);

-- tag_only_ingests テーブル用インデックス
CREATE INDEX IF NOT EXISTS idx_tag_only_ingests_created_at ON tag_only_ingests (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tag_only_ingests_user_id ON tag_only_ingests (user_id);
CREATE INDEX IF NOT EXISTS idx_tag_only_ingests_category ON tag_only_ingests (category);
CREATE INDEX IF NOT EXISTS idx_tag_only_ingests_source_id ON tag_only_ingests (source_id);
CREATE INDEX IF NOT EXISTS idx_tag_only_ingests_tag_hash ON tag_only_ingests (tag_hash);
CREATE INDEX IF NOT EXISTS idx_tag_only_ingests_payload_gin ON tag_only_ingests USING gin(payload_json);

-- search_history テーブル用インデックス
CREATE INDEX IF NOT EXISTS idx_search_history_user_id ON search_history (user_id);
CREATE INDEX IF NOT EXISTS idx_search_history_created_at ON search_history (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_search_history_query ON search_history (query);

-- 7. フルテキスト検索用の複合インデックス（必要に応じて）
-- 複数列の検索用
CREATE INDEX IF NOT EXISTS idx_contents_fulltext_combined ON contents 
USING gin((to_tsvector('japanese', coalesce(title,'') || ' ' || coalesce(body,'') || ' ' || coalesce(tags,''))));

COMMIT;