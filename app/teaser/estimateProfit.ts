// app/teaser/estimateProfit.ts

export type Category =
  | '動画・配信'
  | '買い物・ファッション'
  | '音楽・アーティスト'
  | 'アニメ・ゲーム'
  | 'ライフスタイル';

export type Genre =
  // 動画・配信
  | 'VTuber'
  | '実写配信者'
  | '解説・勉強系'
  | 'バラエティ'
  // 買い物・ファッション
  | 'コスメ'
  | 'ファッション'
  | 'ガジェット'
  // 音楽・アーティスト
  | '歌い手/バンド'
  | 'DJ/トラックメイカー'
  // アニメ・ゲーム
  | 'ゲーム配信'
  | 'アニメレビュー'
  | '二次創作'
  // ライフスタイル
  | '日常・ルーティン'
  | '子育て・家族'
  | '勉強・資格'
  | 'その他';

export interface EstimateRevenueOptions {
  followers: number;
  category: Category;
  genre: Genre;
}

// --- 計算ロジックの係数 ---

const activeRate: Record<Category, number> = {
  '動画・配信': 0.6,
  '買い物・ファッション': 0.5,
  '音楽・アーティスト': 0.55,
  'アニメ・ゲーム': 0.65,
  'ライフスタイル': 0.45,
};

const basePayRate = 0.015;

const baseArpu: Record<Category, number> = {
  '動画・配信': 800,
  '買い物・ファッション': 960,
  '音楽・アーティスト': 880,
  'アニメ・ゲーム': 800,
  'ライフスタイル': 720,
};

const genreHeat: Record<Genre, number> = {
  VTuber: 1.3,
  実写配信者: 1.2,
  '解説・勉強系': 0.9,
  バラエティ: 1.0,
  コスメ: 1.1,
  ファッション: 1.0,
  ガジェット: 0.95,
  '歌い手/バンド': 1.25,
  'DJ/トラックメイカー': 1.1,
  ゲーム配信: 1.2,
  アニメレビュー: 1.1,
  二次創作: 1.15,
  '日常・ルーティン': 0.9,
  '子育て・家族': 1.0,
  '勉強・資格': 0.85,
  その他: 1.0,
};

/**
 * フォロワー数、カテゴリ、ジャンルに基づいて推定月間収益を計算します。
 * @param options - followers, category, genre を含むオブジェクト
 * @returns 推定月間収益（円）
 */
export function estimateRevenue({
  followers,
  category,
  genre,
}: EstimateRevenueOptions): number {
  if (!followers || !category || !genre) {
    return 0;
  }

  // 計算式:
  // activeFans = followers * activeRate[category]
  // payRate = basePayRate * genreHeat[genre]
  // payingFans = activeFans * payRate
  // revenue = payingFans * baseArpu[category]

  const activeFans = followers * activeRate[category];
  const payRate = basePayRate * genreHeat[genre];
  const payingFans = activeFans * payRate;
  const revenue = payingFans * baseArpu[category];

  return Math.round(revenue);
}