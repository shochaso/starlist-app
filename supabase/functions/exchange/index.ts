import { createRemoteJWKSet, jwtVerify, SignJWT } from "https://deno.land/x/jose@v4.14.4/index.ts";

// CORS configuration via env, fallback to permissive defaults for local dev
const allowOrigin = Deno.env.get("CORS_ALLOW_ORIGIN") ?? "*";
const allowHeaders = Deno.env.get("CORS_ALLOW_HEADERS") ?? "authorization, content-type";
const allowMethods = Deno.env.get("CORS_ALLOW_METHODS") ?? "POST, OPTIONS";

const auth0Domain = Deno.env.get("AUTH0_DOMAIN");
const supabaseJwtSecret = Deno.env.get("SUPABASE_JWT_SECRET");
const supabaseAudience = Deno.env.get("SUPABASE_JWT_AUD") ?? "authenticated";
const auth0Audience = Deno.env.get("AUTH0_AUDIENCE") ?? undefined;

if (!auth0Domain || !supabaseJwtSecret) {
  console.warn("[exchange] Missing AUTH0_DOMAIN or SUPABASE_JWT_SECRET env vars");
}

function resolveAuth0Issuer(domain: string | null): URL | null {
  if (!domain) return null;
  const trimmed = domain.trim();
  if (!trimmed) return null;

  const buildUrl = (value: string) => {
    const parsed = new URL(value);
    if (!parsed.pathname.endsWith("/")) {
      parsed.pathname = `${parsed.pathname}/`;
    }
    parsed.search = "";
    parsed.hash = "";
    return parsed;
  };

  try {
    return buildUrl(trimmed);
  } catch {
    try {
      return buildUrl(`https://${trimmed}`);
    } catch (error) {
      console.error("[exchange] Invalid AUTH0_DOMAIN value", error);
      return null;
    }
  }
}

const auth0Issuer = resolveAuth0Issuer(auth0Domain);

const jwks = auth0Issuer
  ? createRemoteJWKSet(new URL(".well-known/jwks.json", auth0Issuer))
  : null;

function cors(json: unknown, status = 200) {
  return new Response(JSON.stringify(json), {
    status,
    headers: {
      "content-type": "application/json",
      "access-control-allow-origin": allowOrigin,
      "access-control-allow-headers": allowHeaders,
      "access-control-allow-methods": allowMethods,
    },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return cors({ ok: true });
  }

  try {
    if (!jwks || !supabaseJwtSecret || !auth0Issuer) {
      throw new Error("Function not configured");
    }

    const body = await req.json().catch(() => null);
    if (!body || typeof body.id_token !== "string") {
      return cors({ error: "id_token required" }, 400);
    }

    const { id_token } = body;

    const verifyOptions: {
      issuer: string;
      audience?: string;
    } = {
      issuer: auth0Issuer.href,
    };
    if (auth0Audience) {
      verifyOptions.audience = auth0Audience;
    }

    const { payload } = await jwtVerify(id_token, jwks, verifyOptions);

    const now = Math.floor(Date.now() / 1000);
    const expiresIn = Number(Deno.env.get("SUPABASE_JWT_EXPIRES_IN")) || 600;

    const supabaseJwt = await new SignJWT({
      sub: payload.sub,
      email: payload.email,
      provider: "line",
      exp: now + expiresIn,
      iat: now,
      aud: supabaseAudience,
    })
      .setProtectedHeader({ alg: "HS256" })
      .sign(new TextEncoder().encode(supabaseJwtSecret));

    return cors({ supabase_jwt: supabaseJwt, expires_in: expiresIn });
  } catch (error) {
    console.error("[exchange]", error);
    return cors({ error: String(error?.message ?? error) }, 401);
  }
});
