import { createClient } from '@supabase/supabase-js'

// SUPABASEのURLとAPIキーを設定
const supabaseUrl = 'https://zjwvmoxpacbpwawlwbrd.supabase.co'
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inpqd3Ztb3hwYWNicHdhd2x3YnJkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDEzNTQwMzMsImV4cCI6MjA1NjkzMDAzM30.37KDj4QhQmv6crotphR9GnPTM_0zv0PCCnKfXvsZx_g'

export const supabase = createClient(supabaseUrl, supabaseKey)
