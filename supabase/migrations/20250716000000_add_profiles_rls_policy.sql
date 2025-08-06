-- Enable RLS on the 'profiles' table if it's not already enabled.
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Drop existing policies for INSERT to avoid conflicts
DROP POLICY IF EXISTS "Authenticated users can insert their own profile" ON public.profiles;

-- Create a new policy that allows authenticated users to insert their own profile.
-- This policy checks if the 'id' of the row being inserted matches the 'uid' of the currently authenticated user.
CREATE POLICY "Authenticated users can insert their own profile"
ON public.profiles FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = id);

-- Additionally, it's good practice to have policies for SELECT, UPDATE, and DELETE.
-- Let's add a basic SELECT policy.

-- Drop existing policies for SELECT
DROP POLICY IF EXISTS "Authenticated users can view their own profile" ON public.profiles;

-- Allow authenticated users to view their own profile.
CREATE POLICY "Authenticated users can view their own profile"
ON public.profiles FOR SELECT
TO authenticated
USING (auth.uid() = id); 