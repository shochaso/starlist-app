/**
 * Phase 4 Retry Engine
 * Classifies errors and implements exponential backoff retry logic
 */

export interface RetryConfig {
  maxRetries: number;
  initialDelayMs: number;
  backoffMultiplier: number;
  nonRetryableCodes: number[];
}

export interface RetryResult<T> {
  success: boolean;
  result?: T;
  error?: Error;
  attempts: number;
}

export enum ErrorCategory {
  NON_RETRYABLE = 'NON_RETRYABLE',
  RETRYABLE = 'RETRYABLE',
}

export interface ErrorClassification {
  category: ErrorCategory;
  httpCode?: number;
  reason: string;
}

const DEFAULT_CONFIG: RetryConfig = {
  maxRetries: 3,
  initialDelayMs: 5000,
  backoffMultiplier: 2,
  nonRetryableCodes: [422, 403],
};

export function classifyError(error: any): ErrorClassification {
  // HTTP 422: Workflow does not have 'workflow_dispatch' trigger
  if (error.message?.includes('422') || error.message?.includes('workflow_dispatch')) {
    return {
      category: ErrorCategory.NON_RETRYABLE,
      httpCode: 422,
      reason: 'Configuration error - workflow_dispatch not recognized',
    };
  }

  // HTTP 403: Resource not accessible
  if (error.message?.includes('403') || error.message?.includes('forbidden')) {
    return {
      category: ErrorCategory.NON_RETRYABLE,
      httpCode: 403,
      reason: 'Permission error - insufficient access',
    };
  }

  // HTTP 500/502/503: Server errors (retryable)
  if (error.message?.includes('500') || error.message?.includes('502') || error.message?.includes('503')) {
    return {
      category: ErrorCategory.RETRYABLE,
      httpCode: parseInt(error.message.match(/(500|502|503)/)?.[0] || '500'),
      reason: 'Server error - retryable',
    };
  }

  // Network timeout (retryable)
  if (error.message?.includes('timeout') || error.code === 'ETIMEDOUT') {
    return {
      category: ErrorCategory.RETRYABLE,
      reason: 'Network timeout - retryable',
    };
  }

  // Rate limit (retryable with backoff)
  if (error.message?.includes('rate limit') || error.status === 429) {
    return {
      category: ErrorCategory.RETRYABLE,
      httpCode: 429,
      reason: 'Rate limit - retryable with backoff',
    };
  }

  // Default: non-retryable for unknown errors
  return {
    category: ErrorCategory.NON_RETRYABLE,
    reason: 'Unknown error - non-retryable',
  };
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

function calculateBackoffDelay(attempt: number, config: RetryConfig): number {
  return config.initialDelayMs * Math.pow(config.backoffMultiplier, attempt - 1);
}

export async function retry<T>(
  fn: () => Promise<T>,
  config: RetryConfig = DEFAULT_CONFIG
): Promise<RetryResult<T>> {
  let lastError: Error | undefined;
  let attempts = 0;

  for (let attempt = 1; attempt <= config.maxRetries + 1; attempt++) {
    attempts = attempt;

    try {
      const result = await fn();
      return {
        success: true,
        result,
        attempts,
      };
    } catch (error) {
      lastError = error instanceof Error ? error : new Error(String(error));
      const classification = classifyError(lastError);

      // Non-retryable errors: fail immediately
      if (classification.category === ErrorCategory.NON_RETRYABLE) {
        return {
          success: false,
          error: lastError,
          attempts,
        };
      }

      // Retryable errors: continue if attempts remain
      if (attempt < config.maxRetries + 1) {
        const delay = calculateBackoffDelay(attempt, config);
        console.log(`Attempt ${attempt} failed, retrying in ${delay}ms...`);
        await sleep(delay);
      }
    }
  }

  return {
    success: false,
    error: lastError,
    attempts,
  };
}

