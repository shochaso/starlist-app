export type AuditKPI = {
  updated_at: string; // ISO
  day11_count: number;
  slack_success_rate: number; // 0..1
  p95_latency_ms: number;
  checkout_success_rate: number; // 0..1
  mismatches_today: number;
  mismatch_streak_zero_days: number;
};
