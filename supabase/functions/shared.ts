import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import type { SupabaseClient, User } from "https://esm.sh/@supabase/supabase-js@2";

export class HttpError extends Error {
  status: number;
  constructor(status: number, message: string) {
    super(message);
    this.status = status;
  }
}

const DEFAULT_ALLOWED_ORIGINS = [
  "https://app.starlist.jp",
  "https://ops.starlist.jp",
  "http://localhost:8080",
];

const DEFAULT_OPS_CLAIM_KEY = "ops_admin";
const OPS_SECRET_HEADER = "x-ops-secret";

export const getAllowedOrigins = (): string[] => {
  const envValue = Deno.env.get("OPS_ALLOWED_ORIGINS");
  const origins = (envValue ?? DEFAULT_ALLOWED_ORIGINS.join(",")).split(",").map((o) => o.trim()).filter(Boolean);
  return origins.length > 0 ? origins : DEFAULT_ALLOWED_ORIGINS;
};

export const buildCorsHeaders = (req?: Request): Record<string, string> => {
  const origins = getAllowedOrigins();
  const origin = req?.headers.get("origin");
  const allowedOrigin = origin && origins.includes(origin) ? origin : origins[0];

  return {
    "Access-Control-Allow-Origin": allowedOrigin,
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-ops-secret",
    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
    "Access-Control-Allow-Credentials": "true",
  };
};

export const jsonResponse = (body: unknown, status = 200, req?: Request): Response =>
  new Response(JSON.stringify(body), {
    status,
    headers: {
      "Content-Type": "application/json",
      ...buildCorsHeaders(req),
    },
  });

export const createServiceClient = (supabaseUrl: string, supabaseKey: string): SupabaseClient =>
  createClient(supabaseUrl, supabaseKey);

export const createSupabaseClientWithAuth = (
  supabaseUrl: string,
  supabaseKey: string,
  authHeader: string
): SupabaseClient =>
  createClient(supabaseUrl, supabaseKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false },
  });

export interface AuthContext {
  supabase: SupabaseClient;
  user: User;
  authHeader: string;
}

const maskEmail = (value: string): string =>
  value.replace(/([A-Za-z0-9._%+-]{3})[A-Za-z0-9._%+-]*@([A-Za-z0-9.-]+\.[A-Za-z]{2,})/g, "$1***@$2");

export const maskPII = (input?: unknown): unknown => {
  if (typeof input === "string") {
    return maskEmail(input).replace(/(Bearer)\s+[A-Za-z0-9._\-]+/, "$1 ***");
  }
  return input;
};

export const safeLog = (tag: string, message: string, detail?: unknown): void => {
  const safeDetail = maskPII(detail);
  console.error(`[${tag}] ${message}`, safeDetail);
};

const hasOpsClaim = (user: User): boolean => {
  const claimKey = Deno.env.get("OPS_ADMIN_METADATA_KEY") ?? DEFAULT_OPS_CLAIM_KEY;
  const metadata = {
    ...user.app_metadata,
    ...user.user_metadata,
  };
  const claimValue = metadata?.[claimKey];
  return claimValue === true || claimValue === "true";
};

export const isOpsAdmin = (user: User): boolean => hasOpsClaim(user);

export const enforceOpsSecret = (req: Request): void => {
  const secret = Deno.env.get("OPS_SERVICE_SECRET");
  if (!secret) {
    return;
  }
  const header = req.headers.get(OPS_SECRET_HEADER);
  if (!header || header !== secret) {
    throw new HttpError(401, "Missing or invalid ops secret");
  }
};

export const requireUser = async (
  req: Request,
  supabaseUrl: string,
  supabaseServiceKey: string,
  options?: { requireOpsClaim?: boolean }
): Promise<AuthContext> => {
  const header = req.headers.get("authorization") ?? req.headers.get("Authorization");
  if (!header) {
    throw new HttpError(401, "Missing authorization header");
  }

  const supabase = createSupabaseClientWithAuth(supabaseUrl, supabaseServiceKey, header);
  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user) {
    throw new HttpError(401, "Unauthorized: Invalid or expired token");
  }

  if (options?.requireOpsClaim && !isOpsAdmin(user)) {
    throw new HttpError(403, "Forbidden: Ops access required");
  }

  return { supabase, user, authHeader: header };
};
