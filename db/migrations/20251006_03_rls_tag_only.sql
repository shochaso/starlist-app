-- Migration: Enable RLS for tag_only_ingests table
-- Date: 2025-10-06
-- Description: Add Row Level Security policies for tag_only_ingests

BEGIN;

-- Enable RLS on tag_only_ingests table
ALTER TABLE tag_only_ingests ENABLE ROW LEVEL SECURITY;

-- Policy for SELECT: users can only select their own records
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
      AND tablename = 'tag_only_ingests' 
      AND policyname = 'select_own_tag_only'
  ) THEN
    CREATE POLICY select_own_tag_only ON tag_only_ingests
      FOR SELECT 
      USING (user_id = auth.uid());
  END IF;
END$$;

-- Policy for INSERT: users can only insert their own records
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
      AND tablename = 'tag_only_ingests' 
      AND policyname = 'insert_own_tag_only'
  ) THEN
    CREATE POLICY insert_own_tag_only ON tag_only_ingests
      FOR INSERT 
      WITH CHECK (user_id = auth.uid());
  END IF;
END$$;

-- Policy for UPDATE: users can only update their own records
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
      AND tablename = 'tag_only_ingests' 
      AND policyname = 'update_own_tag_only'
  ) THEN
    CREATE POLICY update_own_tag_only ON tag_only_ingests
      FOR UPDATE 
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;
END$$;

COMMIT;




