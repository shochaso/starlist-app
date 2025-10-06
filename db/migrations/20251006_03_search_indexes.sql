-- =============================================
-- Starlist 検索機能用パフォーマンス最適化インデックス
-- =============================================

BEGIN;

-- 1. pg_trgm拡張の有効化（ファジー検索用）
-- 既に存在する場合はエラーにならない
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 2. 日本語全文検索用設定の確認・作成
-- unaccentは日本語には不要だが、他の言語との互換性のため残す
CREATE EXTENSION IF NOT EXISTS unaccent;

-- 3. contents テーブル用の高度なインデックス
-- 三項検索（タイトル、本文、タグ）用の複合GINインデックス
DROP INDEX IF EXISTS idx_contents_search_vector;
CREATE INDEX idx_contents_search_vector ON contents
USING gin((
  setweight(to_tsvector('japanese', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('japanese', coalesce(body, '')), 'B') ||
  setweight(to_tsvector('japanese', coalesce(tags, '')), 'C')
));

-- 4. ファジー検索用のトライグラムインデックス
-- タイトルの部分一致検索を高速化
DROP INDEX IF EXISTS idx_contents_title_trgm;
CREATE INDEX idx_contents_title_trgm ON contents 
USING gin (title gin_trgm_ops);

-- 本文の部分一致検索を高速化
DROP INDEX IF EXISTS idx_contents_body_trgm;
CREATE INDEX idx_contents_body_trgm ON contents 
USING gin (body gin_trgm_ops);

-- タグの部分一致検索を高速化
DROP INDEX IF EXISTS idx_contents_tags_trgm;
CREATE INDEX idx_contents_tags_trgm ON contents 
USING gin (tags gin_trgm_ops);

-- 5. tag_only_ingests テーブル用の高度なインデックス
-- payload_json内のテキスト検索用
DROP INDEX IF EXISTS idx_tag_only_payload_text_trgm;
CREATE INDEX idx_tag_only_payload_text_trgm ON tag_only_ingests 
USING gin ((payload_json::text) gin_trgm_ops);

-- payload_json内の特定キーへの高速アクセス用
DROP INDEX IF EXISTS idx_tag_only_payload_title;
CREATE INDEX idx_tag_only_payload_title ON tag_only_ingests 
USING gin ((payload_json->>'title') gin_trgm_ops)
WHERE payload_json->>'title' IS NOT NULL;

DROP INDEX IF EXISTS idx_tag_only_payload_description;
CREATE INDEX idx_tag_only_payload_description ON tag_only_ingests 
USING gin ((payload_json->>'description') gin_trgm_ops)
WHERE payload_json->>'description' IS NOT NULL;

-- 6. 複合検索用のインデックス
-- カテゴリ別検索を高速化
DROP INDEX IF EXISTS idx_contents_category_updated_at;
CREATE INDEX idx_contents_category_updated_at ON contents (category, updated_at DESC)
WHERE category IS NOT NULL;

DROP INDEX IF EXISTS idx_tag_only_category_created_at;
CREATE INDEX idx_tag_only_category_created_at ON tag_only_ingests (category, created_at DESC)
WHERE category IS NOT NULL;

-- プライバシーレベル別検索を高速化
DROP INDEX IF EXISTS idx_contents_privacy_updated_at;
CREATE INDEX idx_contents_privacy_updated_at ON contents (privacy_level, updated_at DESC);

-- ユーザー別検索を高速化
DROP INDEX IF EXISTS idx_contents_user_updated_at;
CREATE INDEX idx_contents_user_updated_at ON contents (user_id, updated_at DESC);

DROP INDEX IF EXISTS idx_tag_only_user_created_at;
CREATE INDEX idx_tag_only_user_created_at ON tag_only_ingests (user_id, created_at DESC);

-- 7. 検索履歴用の最適化インデックス
-- ユーザー別検索履歴の高速取得
DROP INDEX IF EXISTS idx_search_history_user_created_at;
CREATE INDEX idx_search_history_user_created_at ON search_history (user_id, created_at DESC);

-- 検索タイプ別の統計用
DROP INDEX IF EXISTS idx_search_history_type_created_at;
CREATE INDEX idx_search_history_type_created_at ON search_history (search_type, created_at DESC);

-- 人気検索クエリの分析用
DROP INDEX IF EXISTS idx_search_history_query_created_at;
CREATE INDEX idx_search_history_query_created_at ON search_history (query, created_at DESC);

-- 8. 検索統計用のビューを作成
CREATE OR REPLACE VIEW search_analytics AS
SELECT 
    query,
    search_type,
    COUNT(*) as search_count,
    COUNT(DISTINCT user_id) as unique_users,
    MAX(created_at) as last_searched,
    MIN(created_at) as first_searched
FROM search_history 
GROUP BY query, search_type
ORDER BY search_count DESC;

-- 9. 人気タグ取得用の関数
CREATE OR REPLACE FUNCTION get_popular_tags(tag_limit INTEGER DEFAULT 10)
RETURNS TABLE(tag TEXT, tag_count BIGINT) AS $$
BEGIN
    RETURN QUERY
    WITH tag_split AS (
        SELECT 
            unnest(string_to_array(tags, ',')) as tag
        FROM contents 
        WHERE tags IS NOT NULL AND tags != ''
        UNION ALL
        SELECT 
            payload_json->>'tag' as tag
        FROM tag_only_ingests 
        WHERE payload_json->>'tag' IS NOT NULL
    ),
    tag_cleaned AS (
        SELECT 
            trim(tag) as clean_tag
        FROM tag_split 
        WHERE trim(tag) != ''
    )
    SELECT 
        clean_tag as tag,
        COUNT(*) as tag_count
    FROM tag_cleaned
    GROUP BY clean_tag
    ORDER BY COUNT(*) DESC
    LIMIT tag_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- 10. 検索履歴のクリーンアップ用関数（古いデータの削除）
CREATE OR REPLACE FUNCTION cleanup_old_search_history(retention_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM search_history 
    WHERE created_at < NOW() - (retention_days || ' days')::INTERVAL;
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- 11. 検索パフォーマンスの統計情報更新
-- 統計情報を定期的に更新してクエリプランナーの精度を向上
ANALYZE contents;
ANALYZE tag_only_ingests;
ANALYZE search_history;

COMMIT;