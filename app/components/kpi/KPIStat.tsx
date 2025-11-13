type KPIVerdict = "pass" | "warning" | "fail";

interface KPIStatProps {
  label: string;
  value: number | string;
  hint?: string;
  verdict?: KPIVerdict;
  mean?: number;
  stdDev?: number;
  currentValue?: number;
}

function getVerdictColor(verdict?: KPIVerdict): string {
  switch (verdict) {
    case "pass":
      return "border-green-500 bg-green-50";
    case "warning":
      return "border-yellow-500 bg-yellow-50";
    case "fail":
      return "border-red-500 bg-red-50";
    default:
      return "";
  }
}

function getVerdictBadge(verdict?: KPIVerdict): string {
  switch (verdict) {
    case "pass":
      return "✅";
    case "warning":
      return "⚠️";
    case "fail":
      return "❌";
    default:
      return "";
  }
}

export default function KPIStat({
  label,
  value,
  hint,
  verdict,
  mean,
  stdDev,
  currentValue,
}: KPIStatProps) {
  const borderColor = getVerdictColor(verdict);
  const badge = getVerdictBadge(verdict);

  let calculatedVerdict: KPIVerdict | undefined = verdict;
  if (!verdict && mean !== undefined && stdDev !== undefined && typeof currentValue === "number") {
    const diff = Math.abs(currentValue - mean);
    if (diff > 3 * stdDev) {
      calculatedVerdict = "fail";
    } else if (diff > 2 * stdDev) {
      calculatedVerdict = "warning";
    } else {
      calculatedVerdict = "pass";
    }
  }

  const finalVerdict = calculatedVerdict || verdict;
  const finalBorderColor = getVerdictColor(finalVerdict);
  const finalBadge = getVerdictBadge(finalVerdict);

  return (
    <div className={`rounded-2xl shadow p-4 border-2 ${finalBorderColor}`}>
      <div className="flex items-center justify-between">
        <div className="text-xs opacity-60">{label}</div>
        {finalBadge && <span className="text-lg">{finalBadge}</span>}
      </div>
      <div className="text-2xl font-semibold">{value}</div>
      {hint && <div className="text-xs opacity-60 mt-1">Target: {hint}</div>}
      {mean !== undefined && stdDev !== undefined && (
        <div className="text-xs opacity-50 mt-1">
          μ={mean.toFixed(2)}, σ={stdDev.toFixed(2)}
        </div>
      )}
    </div>
  );
}
