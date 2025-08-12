-- Enable UPDATE for authenticated users on their own profile
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
      AND tablename = 'profiles' 
      AND policyname = 'Authenticated users can update their own profile'
  ) THEN
    CREATE POLICY "Authenticated users can update their own profile"
    ON public.profiles FOR UPDATE
    TO authenticated
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);
  END IF;
END $$; 