BEGIN;
CREATE TABLE IF NOT EXISTS tag_only_ingests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  source_id text NOT NULL,
  tag_hash text NOT NULL,
  category text,
  payload_json jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (source_id, tag_hash)
);
CREATE INDEX IF NOT EXISTS idx_tag_only_user_created
  ON tag_only_ingests (user_id, created_at DESC);
COMMENT ON TABLE tag_only_ingests IS 'Tag-only ingests. Game purchase data filtered at app layer.';
COMMIT;
