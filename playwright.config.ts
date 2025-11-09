import { defineConfig } from '@playwright/test';

export default defineConfig({
  retries: process.env.CI ? 2 : 0,
  timeout: 60_000,
  use: {
    actionTimeout: 20_000,
    navigationTimeout: 30_000,
    baseURL: process.env.BASE_URL ?? 'http://127.0.0.1:7357',
  },
  reporter: [
    ['list'],
    ['junit', { outputFile: 'playwright-results.xml' }],
  ],
});
