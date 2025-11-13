"use client";

import { useMemo, useState } from "react";

import { estimateProfit, EstimateProfitOptions } from "./estimateProfit";

const features = [
  {
    title: "投稿とストーリーの融合",
    body: "視聴/購入履歴をタイムライン化し、アクションに紐づけたストーリーをまとめて投稿できます。",
  },
  {
    title: "ファンの行動がインサイトに",
    body: "データ化されたファン行動を可視化し、投稿の反応や推定収益に直結した指標を自動で作成します。",
  },
  {
    title: "サブスクとスポット収益を一括管理",
    body: "シミュレーター付きのダッシュボードで、サブスク収益とスポット販売の合算をリアルタイムに把握可能。",
  },
  {
    title: "日本語・英語の両対応UX",
    body: "モバイルファーストのUIに加え、海外ファン向けの多言語サポートがシームレスに切り替わります。",
  },
];

const upcoming = [
  {
    title: "2026年1月：クリエイター専用アナリティクス",
    body: "TikTok・YouTube・Shopifyの連携で、収益化のギャップをダッシュボードで可視化。",
  },
  {
    title: "2026年2月：ファン投稿のリミックステンプレート",
    body: "ファンが投稿した視聴記録やレシートをテンプレート化し、他クリエイターとコラボ共有可能に。",
  },
  {
    title: "2026年春：スタジオ配信パッケージ",
    body: "ライブ配信のクリップと連携したアーカイブ販売、サブスクのクロスセルを同時進行で実現。",
  },
];

const formatter = new Intl.NumberFormat("ja-JP", {
  style: "currency",
  currency: "JPY",
  maximumFractionDigits: 0,
});

export default function StarSignUpLPRedesign() {
  const [formState, setFormState] = useState<EstimateProfitOptions>({
    monthlyReach: 72000,
    conversionRate: 13,
    avgSpend: 3900,
    subscriptionShare: 32,
  });

  const monthlyProfit = useMemo(() => estimateProfit(formState), [formState]);

  const updateField = (key: keyof EstimateProfitOptions, value: number) => {
    setFormState((prev) => ({ ...prev, [key]: value }));
  };

  return (
    <main className="min-h-screen bg-slate-950 text-slate-50">
      <div className="mx-auto flex max-w-5xl flex-col gap-12 px-5 py-10">
        <header className="space-y-6">
          <div className="flex items-center justify-between text-sm text-slate-300">
            <span>STARLIST - Teaser LP</span>
            <nav className="flex gap-4">
              <a className="transition-colors hover:text-white" href="#simulator">
                シミュレーター
              </a>
              <a className="transition-colors hover:text-white" href="#features">
                機能
              </a>
              <a className="transition-colors hover:text-white" href="#signup">
                先行予約
              </a>
            </nav>
          </div>
          <div className="space-y-6">
            <p className="text-sm uppercase tracking-[0.3em] text-fuchsia-400">STARLIST</p>
            <h1 className="text-3xl font-semibold leading-tight text-white sm:text-4xl lg:text-5xl">
              記録した「見た・聴いた・買った」が未来の収益になっていく場所
            </h1>
            <p className="text-lg text-slate-300 sm:text-xl">
              STARLIST は、ファンが自分の体験を投稿するだけで「あなたの活動がつくる価値」が定量化される、クリエイターのための統合型ティザーサイトです。
            </p>
            <div className="flex flex-wrap gap-4">
              <a
                href="#signup"
                className="rounded-2xl bg-gradient-to-r from-pink-500 via-red-500 to-orange-500 px-6 py-3 text-sm font-semibold uppercase tracking-wider text-white transition hover:brightness-110"
              >
                先行登録して通知
              </a>
              <a
                href="#upcoming"
                className="rounded-2xl border border-white/30 px-6 py-3 text-sm font-semibold uppercase tracking-wider text-white transition hover:border-white"
              >
                ロードマップを見る
              </a>
            </div>
          </div>
        </header>

        <section
          id="simulator"
          className="space-y-6 rounded-3xl border border-white/10 bg-gradient-to-br from-slate-900/80 to-slate-900/40 p-6 shadow-2xl backdrop-blur"
        >
          <div className="flex items-baseline justify-between">
            <h2 className="text-xl font-semibold text-white">推定収益シミュレーター</h2>
            <p className="text-sm text-slate-400">実際のファン数を入れて即時にチェック</p>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            <label className="flex flex-col gap-2 text-sm text-slate-300">
              月間リーチ数
              <input
                type="number"
                min="1000"
                step="1000"
                value={formState.monthlyReach}
                onChange={(event) => updateField("monthlyReach", Number(event.target.value))}
                className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
              />
            </label>
            <label className="flex flex-col gap-2 text-sm text-slate-300">
              反応率（%）
              <input
                type="number"
                min="1"
                max="30"
                step="1"
                value={formState.conversionRate}
                onChange={(event) => updateField("conversionRate", Number(event.target.value))}
                className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
              />
            </label>
            <label className="flex flex-col gap-2 text-sm text-slate-300">
              平均収益（円）
              <input
                type="number"
                min="1000"
                step="500"
                value={formState.avgSpend}
                onChange={(event) => updateField("avgSpend", Number(event.target.value))}
                className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
              />
            </label>
            <label className="flex flex-col gap-2 text-sm text-slate-300">
              サブスク比率（%）
              <input
                type="number"
                min="0"
                max="100"
                step="1"
                value={formState.subscriptionShare}
                onChange={(event) => updateField("subscriptionShare", Number(event.target.value))}
                className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
              />
            </label>
          </div>
          <div className="rounded-2xl border border-white/10 bg-slate-900/70 p-6 text-center">
            <p className="text-xs uppercase tracking-[0.4em] text-slate-400">今月の推定収益</p>
            <p className="pt-2 text-3xl font-semibold text-white sm:text-4xl">{formatter.format(monthlyProfit)}</p>
            <p className="text-sm text-slate-400">データをもとにした指標です</p>
          </div>
        </section>

        <section id="features" className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold text-white">Feature Highlights</h2>
            <p className="text-sm text-slate-400">Mobile-first / Creator-first</p>
          </div>
          <div className="grid gap-4 sm:grid-cols-2">
            {features.map((feature) => (
              <article
                key={feature.title}
                className="rounded-3xl border border-white/10 bg-slate-900/60 p-5 transition hover:border-white/40"
              >
                <p className="text-xs uppercase tracking-[0.3em] text-fuchsia-300">Feature</p>
                <h3 className="mt-3 text-lg font-semibold text-white">{feature.title}</h3>
                <p className="mt-2 text-sm text-slate-300">{feature.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="upcoming" className="space-y-6">
          <div className="flex items-center justify-between">
            <h2 className="text-xl font-semibold text-white">Upcoming Releases</h2>
            <span className="text-xs uppercase tracking-[0.3em] text-slate-400">2025→2026</span>
          </div>
          <div className="space-y-4">
            {upcoming.map((item) => (
              <article
                key={item.title}
                className="rounded-2xl border border-white/10 bg-gradient-to-r from-slate-900/60 to-slate-800/40 p-5"
              >
                <p className="text-sm text-pink-200">{item.title}</p>
                <p className="mt-2 text-sm text-slate-200">{item.body}</p>
              </article>
            ))}
          </div>
        </section>

        <section id="signup" className="space-y-4 rounded-3xl border border-white/10 bg-slate-900/80 p-6">
          <div className="space-y-2">
            <p className="text-xs uppercase tracking-[0.4em] text-slate-400">Sign up</p>
            <h2 className="text-2xl font-semibold text-white">近日公開通知を受け取る</h2>
            <p className="text-sm text-slate-300">リリース直前のベータ招待やアップデート情報を、登録メール宛に共有します。</p>
          </div>
          <form
            className="flex flex-col gap-3 rounded-2xl border border-white/10 bg-slate-950/80 p-4 sm:flex-row"
            onSubmit={(event) => event.preventDefault()}
          >
            <label className="sr-only" htmlFor="signup-email">
              メール
            </label>
            <input
              id="signup-email"
              type="email"
              placeholder="name@example.com"
              required
              className="flex-1 rounded-2xl border border-white/10 bg-slate-900/80 px-4 py-3 text-sm text-white outline-none focus:border-white"
            />
            <button className="rounded-2xl bg-emerald-500 px-5 py-3 text-sm font-semibold uppercase tracking-[0.3em] text-white transition hover:bg-emerald-400">
              登録して通知
            </button>
          </form>
        </section>

        <footer className="border-t border-white/10 pt-6 text-center text-xs uppercase tracking-[0.4em] text-slate-500">
          STARLIST © {new Date().getFullYear()}｜遊びも収益も、一緒に届ける
        </footer>
      </div>
    </main>
  );
}
