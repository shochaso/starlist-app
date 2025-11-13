/**
 * Unit tests for Phase 4 Retry Engine
 */

import { describe, it, expect, beforeEach, vi } from 'vitest';
import { retry, classifyError, ErrorCategory, RetryConfig } from '../../lib/phase4/retry';

describe('Retry Engine', () => {
  describe('classifyError', () => {
    it('should classify 422 as non-retryable', () => {
      const error = new Error('HTTP 422: Workflow does not have workflow_dispatch');
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.NON_RETRYABLE);
      expect(classification.httpCode).toBe(422);
      expect(classification.reason).toContain('Configuration error');
    });

    it('should classify 403 as non-retryable', () => {
      const error = new Error('HTTP 403: Forbidden');
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.NON_RETRYABLE);
      expect(classification.httpCode).toBe(403);
      expect(classification.reason).toContain('Permission error');
    });

    it('should classify 500 as retryable', () => {
      const error = new Error('HTTP 500: Internal Server Error');
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.RETRYABLE);
      expect(classification.httpCode).toBe(500);
      expect(classification.reason).toContain('Server error');
    });

    it('should classify 502 as retryable', () => {
      const error = new Error('HTTP 502: Bad Gateway');
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.RETRYABLE);
      expect(classification.httpCode).toBe(502);
    });

    it('should classify 503 as retryable', () => {
      const error = new Error('HTTP 503: Service Unavailable');
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.RETRYABLE);
      expect(classification.httpCode).toBe(503);
    });

    it('should classify timeout as retryable', () => {
      const error = new Error('ETIMEDOUT');
      (error as any).code = 'ETIMEDOUT';
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.RETRYABLE);
      expect(classification.reason).toContain('Network timeout');
    });

    it('should classify rate limit as retryable', () => {
      const error = new Error('Rate limit exceeded');
      const classification = classifyError(error);
      
      expect(classification.category).toBe(ErrorCategory.RETRYABLE);
      expect(classification.httpCode).toBe(429);
    });
  });

  describe('retry', () => {
    beforeEach(() => {
      vi.useFakeTimers();
    });

    afterEach(() => {
      vi.useRealTimers();
    });

    it('should succeed on first attempt', async () => {
      const fn = vi.fn().mockResolvedValue('success');
      const result = await retry(fn);
      
      expect(result.success).toBe(true);
      expect(result.result).toBe('success');
      expect(result.attempts).toBe(1);
      expect(fn).toHaveBeenCalledTimes(1);
    });

    it('should not retry on 422 error', async () => {
      const error = new Error('HTTP 422: Workflow does not have workflow_dispatch');
      const fn = vi.fn().mockRejectedValue(error);
      
      const result = await retry(fn);
      
      expect(result.success).toBe(false);
      expect(result.attempts).toBe(1);
      expect(fn).toHaveBeenCalledTimes(1);
    });

    it('should not retry on 403 error', async () => {
      const error = new Error('HTTP 403: Forbidden');
      const fn = vi.fn().mockRejectedValue(error);
      
      const result = await retry(fn);
      
      expect(result.success).toBe(false);
      expect(result.attempts).toBe(1);
      expect(fn).toHaveBeenCalledTimes(1);
    });

    it('should retry on 500 error with exponential backoff', async () => {
      const error = new Error('HTTP 500: Internal Server Error');
      const fn = vi.fn()
        .mockRejectedValueOnce(error)
        .mockRejectedValueOnce(error)
        .mockResolvedValue('success');
      
      const config: RetryConfig = {
        maxRetries: 3,
        initialDelayMs: 5000,
        backoffMultiplier: 2,
        nonRetryableCodes: [422, 403],
      };

      const retryPromise = retry(fn, config);
      
      // Advance timers for first retry (5s)
      await vi.advanceTimersByTimeAsync(5000);
      // Advance timers for second retry (10s)
      await vi.advanceTimersByTimeAsync(10000);
      
      const result = await retryPromise;
      
      expect(result.success).toBe(true);
      expect(result.attempts).toBe(3);
      expect(fn).toHaveBeenCalledTimes(3);
    });

    it('should fail after max retries', async () => {
      const error = new Error('HTTP 500: Internal Server Error');
      const fn = vi.fn().mockRejectedValue(error);
      
      const config: RetryConfig = {
        maxRetries: 2,
        initialDelayMs: 1000,
        backoffMultiplier: 2,
        nonRetryableCodes: [422, 403],
      };

      const retryPromise = retry(fn, config);
      
      await vi.advanceTimersByTimeAsync(10000);
      
      const result = await retryPromise;
      
      expect(result.success).toBe(false);
      expect(result.attempts).toBe(3); // maxRetries + 1
      expect(fn).toHaveBeenCalledTimes(3);
    });
  });
});

