import { createClient } from '@supabase/supabase-js';
export const supabase = createClient(process.env.SUPABASE_URL, process.env.SUPABASE_SERVICE_ROLE, {
    auth: { persistSession: false },
});
export const BUCKET = process.env.SUPABASE_BUCKET || 'user-media';
export const SIGNED_TTL = parseInt(process.env.SIGNED_URL_TTL || '600', 10);
