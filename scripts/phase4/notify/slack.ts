#!/usr/bin/env node
/**
 * Phase 4 Slack Notifier
 * Writes masked Slack excerpts to file (no actual Slack posting in this version)
 */

import * as fs from 'fs/promises';
import * as path from 'path';
import { nowUtcIso } from '../../../lib/phase4/time';

/**
 * Write masked Slack excerpt to file
 * Format: [ISO8601] SLACK_POST -> masked_status (summary="<...>")
 */
export async function writeMaskedSlackExcerpt(
  runId: string | number,
  summary: string,
  excerptsDir: string
): Promise<void> {
  await fs.mkdir(excerptsDir, { recursive: true });

  const excerptPath = path.join(excerptsDir, `${runId}.log`);
  const timestamp = nowUtcIso();
  
  // Mask URLs and sensitive patterns
  const maskedSummary = summary
    .replace(/https?:\/\/[^\s]+/g, '[URL_MASKED]')
    .replace(/token[=:]\s*[^\s]+/gi, 'token=[MASKED]')
    .replace(/Bearer\s+[^\s]+/gi, 'Bearer [MASKED]')
    .replace(/key[=:]\s*[^\s]+/gi, 'key=[MASKED]')
    .substring(0, 200); // Limit length

  const logLine = `[${timestamp}] SLACK_POST -> masked_status (summary="${maskedSummary}")\n`;

  // Overwrite mode (latest entry only)
  await fs.writeFile(excerptPath, logLine, 'utf-8');
}

/**
 * Extract HTTP status code from error or response
 */
export function extractHttpStatus(error: any): string {
  if (error?.status) return String(error.status);
  if (error?.response?.status) return String(error.response.status);
  const match = String(error).match(/(\d{3})/);
  return match ? match[1] : 'N/A';
}

