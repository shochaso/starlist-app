import { assertEquals } from "https://deno.land/std@0.224.0/testing/asserts.ts";
import { buildCorsHeaders, maskPII } from "./shared.ts";

Deno.test("maskPII removes identifiable segments", () => {
  const raw = "ops@starlist.jp";
  const masked = maskPII(raw) as string;
  assertEquals(masked, "ops***@starlist.jp");

  const token = "Bearer sk_test_123456";
  const maskedToken = maskPII(token) as string;
  assertEquals(maskedToken, "Bearer ***");
});

Deno.test("buildCorsHeaders respects allowed origins", () => {
  const previous = Deno.env.get("OPS_ALLOWED_ORIGINS");
  try {
    Deno.env.set("OPS_ALLOWED_ORIGINS", "https://app.starlist.jp, https://ops.starlist.jp");
    const req = new Request("https://api.starlist.jp/health", {
      headers: { Origin: "https://ops.starlist.jp" },
    });
    const headers = buildCorsHeaders(req);
    assertEquals(headers["Access-Control-Allow-Origin"], "https://ops.starlist.jp");

    const foreignReq = new Request("https://api.starlist.jp/health", {
      headers: { Origin: "https://evil.com" },
    });
    const fallback = buildCorsHeaders(foreignReq);
    assertEquals(fallback["Access-Control-Allow-Origin"], "https://app.starlist.jp");
  } finally {
    if (previous === undefined) {
      Deno.env.delete("OPS_ALLOWED_ORIGINS");
    } else {
      Deno.env.set("OPS_ALLOWED_ORIGINS", previous);
    }
  }
});
