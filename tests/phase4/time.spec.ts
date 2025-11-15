/**
 * Unit tests for Phase 4 Time helpers
 */

import { describe, it, expect } from 'vitest';
import { nowUtcIso, jstFolderNameForToday, formatTimestamp, parseJstFolder } from '../../lib/phase4/time';

describe('Time helpers', () => {
  describe('nowUtcIso', () => {
    it('should return ISO8601 UTC timestamp', () => {
      const timestamp = nowUtcIso();
      expect(timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/);
      expect(timestamp).toContain('Z');
    });
  });

  describe('jstFolderNameForToday', () => {
    it('should return YYYY-MM-DD format', () => {
      const folder = jstFolderNameForToday();
      expect(folder).toMatch(/^\d{4}-\d{2}-\d{2}$/);
    });
  });

  describe('formatTimestamp', () => {
    it('should format Date to ISO8601', () => {
      const date = new Date('2025-11-14T10:00:00Z');
      const formatted = formatTimestamp(date);
      expect(formatted).toBe('2025-11-14T10:00:00.000Z');
    });
  });

  describe('parseJstFolder', () => {
    it('should parse JST folder name to UTC date range', () => {
      const { start, end } = parseJstFolder('2025-11-14');
      expect(start).toBeInstanceOf(Date);
      expect(end).toBeInstanceOf(Date);
      expect(start.getTime()).toBeLessThan(end.getTime());
    });
  });
});

