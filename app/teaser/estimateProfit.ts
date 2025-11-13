export interface EstimateProfitOptions {
  monthlyReach: number;
  conversionRate: number;
  avgSpend: number;
  subscriptionShare: number;
}

export function estimateProfit({
  monthlyReach,
  conversionRate,
  avgSpend,
  subscriptionShare,
}: EstimateProfitOptions): number {
  const payingFans = Math.max(monthlyReach * (conversionRate / 100), 0);
  const baseRevenue = payingFans * avgSpend;
  const subscriptionBonus = (subscriptionShare / 100) * payingFans * avgSpend * 0.35;
  const reachBoost = Math.min(monthlyReach / 8000, 1.2) * 1500;

  return Math.max(0, Math.round(baseRevenue * 0.9 + subscriptionBonus + reachBoost));
}
