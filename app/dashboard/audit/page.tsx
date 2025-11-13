"use client";

import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import Link from "next/link";
import type { AuditKPI } from "@/types/audit";
import KPIStat from "@/components/kpi/KPIStat";

const TrendChart = dynamic(() => import("@/components/kpi/TrendChart"), { ssr: false });

function calculateVerdict(value: number, mean: number, stdDev: number): "pass" | "warning" | "fail" {
  const diff = Math.abs(value - mean);
  if (diff > 3 * stdDev) return "fail";
  if (diff > 2 * stdDev) return "warning";
  return "pass";
}

export default function AuditDashboard() {
  const [kpi, setKpi] = useState<AuditKPI | null>(null);
  const [stats, setStats] = useState<{ mean: number; stdDev: number } | null>(null);

  useEffect(() => {
    fetch("/dashboard/data/latest.json", { cache: "no-cache" })
      .then((r) => r.json())
      .then(setKpi)
      .catch(() => setKpi(null));

    // Fetch historical stats for threshold calculation
    fetch("/dashboard/data/stats.json", { cache: "no-cache" })
      .then((r) => r.json())
      .then(setStats)
      .catch(() => setStats(null));
  }, []);

  const slackSuccessVerdict =
    stats && kpi ? calculateVerdict(kpi.slack_success_rate, stats.mean, stats.stdDev) : undefined;
  const p95LatencyVerdict =
    stats && kpi ? calculateVerdict(kpi.p95_latency_ms, stats.mean, stats.stdDev) : undefined;
  const checkoutSuccessVerdict =
    stats && kpi ? calculateVerdict(kpi.checkout_success_rate, stats.mean, stats.stdDev) : undefined;

  return (
    <div className="p-6 grid gap-6">
      <div className="flex items-center justify-between">
        <h1 className="text-2xl font-semibold">Audit KPI Dashboard</h1>
        <div className="flex gap-2 text-sm">
          <Link href="/docs/ops/RACI_MATRIX.md" className="text-blue-600 hover:underline">
            📋 RACI
          </Link>
          <Link href="/docs/ops/RISK_REGISTER.md" className="text-blue-600 hover:underline">
            ⚠️ リスク登録票
          </Link>
          <Link href="/docs/ops/DASHBOARD_FINAL_CHECKLIST.md" className="text-blue-600 hover:underline">
            ✅ 受入テスト
          </Link>
        </div>
      </div>

      {!kpi ? (
        <div className="text-sm opacity-70">Loading latest KPI…</div>
      ) : (
        <>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            <KPIStat
              label="Slack Success"
              value={`${(kpi.slack_success_rate * 100).toFixed(2)}%`}
              hint="≥ 99%"
              verdict={slackSuccessVerdict}
              mean={stats?.mean}
              stdDev={stats?.stdDev}
              currentValue={kpi.slack_success_rate}
            />
            <KPIStat label="Day11 Count" value={kpi.day11_count} />
            <KPIStat
              label="p95 Latency"
              value={`${kpi.p95_latency_ms} ms`}
              hint="< 2000ms"
              verdict={p95LatencyVerdict}
              mean={stats?.mean}
              stdDev={stats?.stdDev}
              currentValue={kpi.p95_latency_ms}
            />
            <KPIStat
              label="Checkout Success"
              value={`${(kpi.checkout_success_rate * 100).toFixed(2)}%`}
              hint="≥ 96%"
              verdict={checkoutSuccessVerdict}
              mean={stats?.mean}
              stdDev={stats?.stdDev}
              currentValue={kpi.checkout_success_rate}
            />
            <KPIStat label="Mismatches (today)" value={kpi.mismatches_today} hint="= 0" />
            <KPIStat label="Zero-Streak" value={`${kpi.mismatch_streak_zero_days} days`} />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <TrendChart title="Day11 p95(ms) — Weekly" seriesKey="p95_latency_ms" />
            <TrendChart title="Checkout Success — Weekly" seriesKey="checkout_success_rate" formatPercent />
          </div>

          <div className="text-xs opacity-60">
            Updated at: {new Date(kpi.updated_at).toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" })}
          </div>

          <footer className="mt-8 pt-4 border-t border-gray-200">
            <div className="text-xs opacity-60">
              <Link href="/docs/planning/DAY12_10X_EXECUTION_PROMPTS.md" className="text-blue-600 hover:underline">
                📦 Day12 10×強化パック
              </Link>
            </div>
          </footer>
        </>
      )}
    </div>
  );
}
