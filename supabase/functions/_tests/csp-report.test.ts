import { assertStringIncludes } from "std/testing/asserts.ts";
import { mask } from "../csp-report/index.ts";

Deno.test("masks sensitive fields", () => {
  const payload =
    '{"token":"abc123","api_key":"XYZ789","authorization":"Bearer secret"}';
  const masked = mask(payload);
  assertStringIncludes(masked, '"token":"***MASKED***"');
  assertStringIncludes(masked, 'api_key="***MASKED***"');
  assertStringIncludes(masked, 'authorization":"***MASKED***"');
});
