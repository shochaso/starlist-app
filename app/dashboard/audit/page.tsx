"use client";

import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import type { AuditKPI } from "@/types/audit";
import KPIStat from "@/components/kpi/KPIStat";

const TrendChart = dynamic(() => import("@/components/kpi/TrendChart"), { ssr: false });

export default function AuditDashboard() {
  const [kpi, setKpi] = useState<AuditKPI | null>(null);

  useEffect(() => {
    fetch("/dashboard/data/latest.json", { cache: "no-cache" })
      .then(r => r.json())
      .then(setKpi)
      .catch(() => setKpi(null));
  }, []);

  return (
    <div className="p-6 grid gap-6">
      <h1 className="text-2xl font-semibold">Audit KPI Dashboard</h1>

      {!kpi ? (
        <div className="text-sm opacity-70">Loading latest KPI…</div>
      ) : (
        <>
          <div className="grid grid-cols-2 md:grid-cols-3 gap-4">
            <KPIStat label="Slack Success" value={`${(kpi.slack_success_rate*100).toFixed(2)}%`} hint="≥ 99%" />
            <KPIStat label="Day11 Count" value={kpi.day11_count} />
            <KPIStat label="p95 Latency" value={`${kpi.p95_latency_ms} ms`} hint="< 2000ms" />
            <KPIStat label="Checkout Success" value={`${(kpi.checkout_success_rate*100).toFixed(2)}%`} hint="≥ 96%" />
            <KPIStat label="Mismatches (today)" value={kpi.mismatches_today} hint="= 0" />
            <KPIStat label="Zero-Streak" value={`${kpi.mismatch_streak_zero_days} days`} />
          </div>

          {/* 任意：時系列チャート（CIで将来データ拡張） */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <TrendChart title="Day11 p95(ms) — Weekly" seriesKey="p95_latency_ms" />
            <TrendChart title="Checkout Success — Weekly" seriesKey="checkout_success_rate" formatPercent />
          </div>

          <div className="text-xs opacity-60">
            Updated at: {new Date(kpi.updated_at).toLocaleString("ja-JP", { timeZone: "Asia/Tokyo" })}
          </div>
        </>
      )}
    </div>
  );
}

