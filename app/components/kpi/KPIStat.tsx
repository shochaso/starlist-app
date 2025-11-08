export default function KPIStat({ label, value, hint }: { label: string; value: number | string; hint?: string }) {
  return (
    <div className="rounded-2xl shadow p-4">
      <div className="text-xs opacity-60">{label}</div>
      <div className="text-2xl font-semibold">{value}</div>
      {hint && <div className="text-xs opacity-60 mt-1">Target: {hint}</div>}
    </div>
  );
}

