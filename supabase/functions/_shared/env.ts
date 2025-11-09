// Type-safe environment variable reader with validation
// Usage: const apiKey = getEnv('RESEND_API_KEY', true);

export interface EnvConfig {
  required?: boolean;
  defaultValue?: string;
  validator?: (value: string) => boolean;
  errorMessage?: string;
}

/**
 * Get environment variable with type safety and validation
 * @param key - Environment variable key
 * @param required - If true, throws error when missing
 * @returns Environment variable value or empty string
 * @throws Error when required variable is missing or validation fails
 */
export function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  
  if (required && !value) {
    throw new Error(`missing env: ${key}`);
  }
  
  return value || "";
}

/**
 * Get environment variable with advanced configuration
 * @param key - Environment variable key
 * @param config - Configuration object
 * @returns Environment variable value or default value
 * @throws Error when required variable is missing or validation fails
 */
export function getEnvConfig(key: string, config: EnvConfig = {}): string {
  const { required = true, defaultValue, validator, errorMessage } = config;
  const value = Deno.env.get(key) || defaultValue;
  
  if (required && !value) {
    throw new Error(errorMessage || `missing env: ${key}`);
  }
  
  if (value && validator && !validator(value)) {
    throw new Error(errorMessage || `invalid env: ${key}`);
  }
  
  return value || "";
}

/**
 * Get boolean environment variable
 * @param key - Environment variable key
 * @param defaultValue - Default value if not set
 * @returns Boolean value
 */
export function getEnvBool(key: string, defaultValue = false): boolean {
  const value = Deno.env.get(key);
  if (!value) return defaultValue;
  return value.toLowerCase() === "true" || value === "1";
}

/**
 * Get number environment variable
 * @param key - Environment variable key
 * @param defaultValue - Default value if not set
 * @returns Number value
 * @throws Error when value is not a valid number
 */
export function getEnvNumber(key: string, defaultValue?: number): number {
  const value = Deno.env.get(key);
  if (!value && defaultValue !== undefined) return defaultValue;
  if (!value) throw new Error(`missing env: ${key}`);
  
  const num = Number(value);
  if (isNaN(num)) {
    throw new Error(`invalid number env: ${key}=${value}`);
  }
  return num;
}

/**
 * Get array environment variable (comma-separated)
 * @param key - Environment variable key
 * @param defaultValue - Default value if not set
 * @returns Array of strings
 */
export function getEnvArray(key: string, defaultValue: string[] = []): string[] {
  const value = Deno.env.get(key);
  if (!value) return defaultValue;
  return value.split(",").map((s) => s.trim()).filter((s) => s.length > 0);
}

// Usage: const apiKey = getEnv('RESEND_API_KEY', true);

export interface EnvConfig {
  required?: boolean;
  defaultValue?: string;
  validator?: (value: string) => boolean;
  errorMessage?: string;
}

/**
 * Get environment variable with type safety and validation
 * @param key - Environment variable key
 * @param required - If true, throws error when missing
 * @returns Environment variable value or empty string
 * @throws Error when required variable is missing or validation fails
 */
export function getEnv(key: string, required = true): string {
  const value = Deno.env.get(key);
  
  if (required && !value) {
    throw new Error(`missing env: ${key}`);
  }
  
  return value || "";
}

/**
 * Get environment variable with advanced configuration
 * @param key - Environment variable key
 * @param config - Configuration object
 * @returns Environment variable value or default value
 * @throws Error when required variable is missing or validation fails
 */
export function getEnvConfig(key: string, config: EnvConfig = {}): string {
  const { required = true, defaultValue, validator, errorMessage } = config;
  const value = Deno.env.get(key) || defaultValue;
  
  if (required && !value) {
    throw new Error(errorMessage || `missing env: ${key}`);
  }
  
  if (value && validator && !validator(value)) {
    throw new Error(errorMessage || `invalid env: ${key}`);
  }
  
  return value || "";
}

/**
 * Get boolean environment variable
 * @param key - Environment variable key
 * @param defaultValue - Default value if not set
 * @returns Boolean value
 */
export function getEnvBool(key: string, defaultValue = false): boolean {
  const value = Deno.env.get(key);
  if (!value) return defaultValue;
  return value.toLowerCase() === "true" || value === "1";
}

/**
 * Get number environment variable
 * @param key - Environment variable key
 * @param defaultValue - Default value if not set
 * @returns Number value
 * @throws Error when value is not a valid number
 */
export function getEnvNumber(key: string, defaultValue?: number): number {
  const value = Deno.env.get(key);
  if (!value && defaultValue !== undefined) return defaultValue;
  if (!value) throw new Error(`missing env: ${key}`);
  
  const num = Number(value);
  if (isNaN(num)) {
    throw new Error(`invalid number env: ${key}=${value}`);
  }
  return num;
}

/**
 * Get array environment variable (comma-separated)
 * @param key - Environment variable key
 * @param defaultValue - Default value if not set
 * @returns Array of strings
 */
export function getEnvArray(key: string, defaultValue: string[] = []): string[] {
  const value = Deno.env.get(key);
  if (!value) return defaultValue;
  return value.split(",").map((s) => s.trim()).filter((s) => s.length > 0);
}

