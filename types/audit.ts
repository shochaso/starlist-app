export type AuditKPI = {
  updated_at: string;               // ISO
  day11_count: number;              // 直近送信数
  slack_success_rate: number;       // 0..1
  p95_latency_ms: number;           // 例: 1800
  checkout_success_rate: number;    // 0..1
  mismatches_today: number;         // Stripe×DB 不一致件数
  mismatch_streak_zero_days: number;// 不一致ゼロ連続日数
};

