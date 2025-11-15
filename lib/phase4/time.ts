/**
 * Phase 4 Timezone & Naming Helpers
 * Provides utilities for JST folder naming and UTC timestamp formatting
 */

/**
 * Get current UTC timestamp in ISO8601 format
 */
export function nowUtcIso(): string {
  return new Date().toISOString();
}

/**
 * Get JST folder name for today (YYYY-MM-DD format)
 * Note: JST is UTC+9, so we calculate the date in JST timezone
 */
export function jstFolderNameForToday(): string {
  const now = new Date();
  // Convert to JST (UTC+9)
  const jstTime = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const year = jstTime.getUTCFullYear();
  const month = String(jstTime.getUTCMonth() + 1).padStart(2, '0');
  const day = String(jstTime.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

/**
 * Format timestamp for display (UTC ISO8601)
 */
export function formatTimestamp(date: Date = new Date()): string {
  return date.toISOString();
}

/**
 * Parse JST folder name to Date range (start and end of day in UTC)
 */
export function parseJstFolder(folderName: string): { start: Date; end: Date } {
  const [year, month, day] = folderName.split('-').map(Number);
  // JST 00:00:00 = UTC 15:00:00 previous day
  const start = new Date(Date.UTC(year, month - 1, day - 1, 15, 0, 0));
  // JST 23:59:59 = UTC 14:59:59 same day
  const end = new Date(Date.UTC(year, month - 1, day, 14, 59, 59));
  return { start, end };
}

