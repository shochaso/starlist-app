-- Migration: Performance indexes for search functionality
-- Date: 2025-10-06
-- Description: Add indexes to optimize search queries

BEGIN;

-- Index for content_consumption table (full search)
CREATE INDEX IF NOT EXISTS idx_contents_updated_at 
  ON content_consumption (updated_at DESC);

-- Index for title search
CREATE INDEX IF NOT EXISTS idx_contents_title_trgm 
  ON content_consumption USING gin (title gin_trgm_ops);

-- Index for content search (if pg_trgm extension is available)
DO $$
BEGIN
  -- Check if pg_trgm extension exists
  IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
    -- Create trigram index for content field
    EXECUTE 'CREATE INDEX IF NOT EXISTS idx_contents_content_trgm 
      ON content_consumption USING gin (content gin_trgm_ops)';
  END IF;
END$$;

-- Index for tag_only_ingests table
CREATE INDEX IF NOT EXISTS idx_tag_only_created_at 
  ON tag_only_ingests (created_at DESC);

-- Index for category filtering
CREATE INDEX IF NOT EXISTS idx_tag_only_category 
  ON tag_only_ingests (category);

-- Composite index for user-specific queries
CREATE INDEX IF NOT EXISTS idx_tag_only_user_created 
  ON tag_only_ingests (user_id, created_at DESC);

-- Index for payload_json search (GIN index for JSONB)
CREATE INDEX IF NOT EXISTS idx_tag_only_payload_json 
  ON tag_only_ingests USING gin (payload_json);

COMMIT;




