"use client";

import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";

const mockWeekly = [
  { w: "W-5", p95_latency_ms: 2100, checkout_success_rate: 0.95 },
  { w: "W-4", p95_latency_ms: 1980, checkout_success_rate: 0.962 },
  { w: "W-3", p95_latency_ms: 1850, checkout_success_rate: 0.968 },
  { w: "W-2", p95_latency_ms: 1720, checkout_success_rate: 0.972 },
  { w: "W-1", p95_latency_ms: 1640, checkout_success_rate: 0.978 }
];

export default function TrendChart({ title, seriesKey, formatPercent }: { title: string; seriesKey: string; formatPercent?: boolean; }) {
  return (
    <div className="rounded-2xl shadow p-4">
      <div className="text-sm font-medium mb-2">{title}</div>
      <ResponsiveContainer width="100%" height={240}>
        <LineChart data={mockWeekly}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="w" />
          <YAxis tickFormatter={(v) => formatPercent ? `${(v*100).toFixed(0)}%` : `${v}`} />
          <Tooltip formatter={(v:any)=> formatPercent ? `${(v*100).toFixed(2)}%` : `${v}`} />
          <Line type="monotone" dataKey={seriesKey} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}



import { LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from "recharts";

const mockWeekly = [
  { w: "W-5", p95_latency_ms: 2100, checkout_success_rate: 0.95 },
  { w: "W-4", p95_latency_ms: 1980, checkout_success_rate: 0.962 },
  { w: "W-3", p95_latency_ms: 1850, checkout_success_rate: 0.968 },
  { w: "W-2", p95_latency_ms: 1720, checkout_success_rate: 0.972 },
  { w: "W-1", p95_latency_ms: 1640, checkout_success_rate: 0.978 }
];

export default function TrendChart({ title, seriesKey, formatPercent }: { title: string; seriesKey: string; formatPercent?: boolean; }) {
  return (
    <div className="rounded-2xl shadow p-4">
      <div className="text-sm font-medium mb-2">{title}</div>
      <ResponsiveContainer width="100%" height={240}>
        <LineChart data={mockWeekly}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="w" />
          <YAxis tickFormatter={(v) => formatPercent ? `${(v*100).toFixed(0)}%` : `${v}`} />
          <Tooltip formatter={(v:any)=> formatPercent ? `${(v*100).toFixed(2)}%` : `${v}`} />
          <Line type="monotone" dataKey={seriesKey} dot={false} />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}


