import { expect, test } from "@playwright/test";
import process from "node:process";

const baseUrl = process.env.BASE_URL ?? "http://localhost:8080";
const reportPath = process.env.CSP_REPORT_PATH ?? "/functions/v1/csp-report";

test("CSP report endpoint receives payload", async ({ page }) => {
  const [request] = await Promise.all([
    page.waitForRequest((req) => req.url().includes(reportPath)),
    page.goto(baseUrl),
  ]);
  expect(request).toBeTruthy();
});
