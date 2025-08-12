-- 2FA user security table
CREATE TABLE IF NOT EXISTS public.user_security (
  user_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  totp_secret TEXT,
  two_factor_enabled BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.user_security ENABLE ROW LEVEL SECURITY;

-- UPDATE trigger for updated_at
CREATE OR REPLACE FUNCTION public.update_user_security_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS user_security_updated_at ON public.user_security;
CREATE TRIGGER user_security_updated_at
  BEFORE UPDATE ON public.user_security
  FOR EACH ROW EXECUTE FUNCTION public.update_user_security_updated_at();

-- Policies
DROP POLICY IF EXISTS "Users can select own user_security" ON public.user_security;
CREATE POLICY "Users can select own user_security"
ON public.user_security FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own user_security" ON public.user_security;
CREATE POLICY "Users can insert own user_security"
ON public.user_security FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own user_security" ON public.user_security;
CREATE POLICY "Users can update own user_security"
ON public.user_security FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id); 