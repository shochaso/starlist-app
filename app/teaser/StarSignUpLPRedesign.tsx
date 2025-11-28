"use client";

import { useMemo, useState } from "react";
import Image from "next/image";
import logo from "../../public/images/starlist-logo.png";

import { estimateRevenue, Category, Genre } from "./estimateProfit";

// カテゴリとジャンルの定義
const CATEGORIES: Category[] = [
  '動画・配信',
  '買い物・ファッション',
  '音楽・アーティスト',
  'アニメ・ゲーム',
  'ライフスタイル',
];

const GENRES_BY_CATEGORY: Record<Category, Genre[]> = {
  '動画・配信': ['VTuber', '実写配信者', '解説・勉強系', 'バラエティ'],
  '買い物・ファッション': ['コスメ', 'ファッション', 'ガジェット'],
  '音楽・アーティスト': ['歌い手/バンド', 'DJ/トラックメイカー'],
  'アニメ・ゲーム': ['ゲーム配信', 'アニメレビュー', '二次創作'],
  'ライフスタイル': ['日常・ルーティン', '子育て・家族', '勉強・資格', 'その他'],
};

// 通知方法
const NOTIFICATION_METHODS = [
  { value: "instagram", label: "Instagram DM" },
  { value: "x", label: "X DM" },
  { value: "email", label: "メール" },
] as const;

// 機能紹介
const features = [
  {
    title: "日常のデータで収益が作れる",
    body: "見た動画、聴いた音楽、買ったもの。いつもの行動を投稿するだけで、お金になる仕組みです。",
  },
  {
    title: "AIが自動でまとめてくれる",
    body: "スクリーンショットを選ぶだけ。AIが自動で内容を読み取って、きれいに整理してくれます。",
  },
  {
    title: "かんたん投稿",
    body: "撮影も編集も不要。スマホのスクリーンショットを選ぶだけで、すぐに投稿できます。",
  },
  {
    title: "セーフティ",
    body: "自動でモザイクをかけて、公開範囲も自分で選べます。安心して投稿できます。",
  },
];

export default function StarSignUpLPRedesign() {
  const [followers, setFollowers] = useState(10000);
  const [category, setCategory] = useState<Category>(CATEGORIES[0]);
  const [genre, setGenre] = useState<Genre>(GENRES_BY_CATEGORY[category][0]);

  const [notificationMethod, setNotificationMethod] =
    useState<(typeof NOTIFICATION_METHODS)[number]["value"]>("instagram");
  const [contactInfo, setContactInfo] = useState<string>("");

  // カテゴリが変更されたら、ジャンルの選択肢を更新し、最初のジャンルを選択する
  const handleCategoryChange = (newCategory: Category) => {
    setCategory(newCategory);
    setGenre(GENRES_BY_CATEGORY[newCategory][0]);
  };

  // 月収を計算
  const monthlyProfit = useMemo(() => {
    return estimateRevenue({
      followers,
      category,
      genre,
    });
  }, [followers, category, genre]);

      const contactInfoDetails = {
        instagram: {
          label: "連絡先（Instagram ユーザー名）",
          placeholder: "例: starlist_jp",
          type: "text",
        },
        x: {
          label: "連絡先（X ユーザー名）",
          placeholder: "例: @starlist_jp",
          type: "text",
        },
        email: {
          label: "メールアドレス",
          placeholder: "例: name@example.com",
          type: "email",
        },
      };
  
      const currentContactInfo = contactInfoDetails[notificationMethod];
  
      return (
        <main className="min-h-screen bg-slate-950 text-slate-50">
          <div className="mx-auto flex max-w-5xl flex-col gap-8 px-4 py-6 sm:gap-12 sm:px-5 sm:py-10">
            <header className="space-y-4 sm:space-y-6">
              {/* ロゴ + ナビゲーション */}
              <div className="flex items-center justify-between">
                <div className="relative h-8 w-32 flex items-center sm:h-10 sm:w-40">
                  {/* ロゴ画像 - 画像が存在しない場合はテキスト表示 */}
                  <div className="relative h-full w-full">
                    <Image
                      src="/images/starlist-logo.png"
                      alt="STARLIST"
                      width={160}
                      height={40}
                      className="object-contain object-left"
                      priority
                    />
                  </div>
                </div>
                <nav className="hidden gap-4 text-sm text-slate-300 sm:flex">
                  <a className="transition-colors hover:text-white" href="#simulator">
                    シミュレーター
                  </a>
                  <a className="transition-colors hover:text-white" href="#features">
                    機能
                  </a>
                  <a className="transition-colors hover:text-white" href="#signup">
                    先行登録
                  </a>
                </nav>
              </div>
  
              {/* ヒーローセクション */}
              <div className="space-y-4 sm:space-y-6">
                <h1 className="text-2xl font-semibold leading-tight text-white sm:text-3xl lg:text-4xl">
                  見た・聴いた・買った。その記録が、お金になる。
                </h1>
                <p className="text-base text-slate-300 sm:text-lg">
                  STARLISTは、ファンがあなたの動画を見たり、音楽を聴いたり、商品を買ったりした記録を投稿するだけで、あなたにお金が入る仕組みです。
                </p>
                <div className="flex flex-wrap gap-3 sm:gap-4">
                  <a
                    href="#signup"
                    className="rounded-2xl bg-gradient-to-r from-pink-500 via-red-500 to-orange-500 px-5 py-2.5 text-sm font-semibold uppercase tracking-wider text-white transition hover:brightness-110 sm:px-6 sm:py-3"
                  >
                    先行登録する
                  </a>
                  <a
                    href="#features"
                    className="rounded-2xl border border-white/30 px-5 py-2.5 text-sm font-semibold uppercase tracking-wider text-white transition hover:border-white sm:px-6 sm:py-3"
                  >
                    使い方を見る
                  </a>
                </div>
              </div>
            </header>
  
            {/* シミュレーター */}
            <section
              id="simulator"
              className="space-y-4 rounded-3xl border border-white/10 bg-gradient-to-br from-slate-900/80 to-slate-900/40 p-5 shadow-2xl backdrop-blur sm:space-y-6 sm:p-6"
            >
              <div>
                <h2 className="text-lg font-semibold text-white sm:text-xl">
                  あなたの月収をシミュレーション
                </h2>
                <p className="mt-1 text-xs text-slate-400 sm:text-sm">
                  フォロワー数と活動ジャンルを選ぶと、月収の目安がわかります
                </p>
              </div>
              <div className="grid gap-4 sm:grid-cols-3">
                <label className="flex flex-col gap-2 text-sm text-slate-300">
                  フォロワー数
                  <input
                    type="number"
                    min="0"
                    step="1000"
                    value={followers}
                    onChange={(e) => setFollowers(Number(e.target.value) || 0)}
                    className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
                    placeholder="例: 10000"
                  />
                </label>
                <label className="flex flex-col gap-2 text-sm text-slate-300">
                  カテゴリ
                  <select
                    value={category}
                    onChange={(e) => handleCategoryChange(e.target.value as Category)}
                    className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
                  >
                    {CATEGORIES.map((cat) => (
                      <option key={cat} value={cat}>
                        {cat}
                      </option>
                    ))}
                  </select>
                </label>
                <label className="flex flex-col gap-2 text-sm text-slate-300">
                  ジャンル
                  <select
                    value={genre}
                    onChange={(e) => setGenre(e.target.value as Genre)}
                    className="rounded-2xl border border-white/10 bg-slate-950/60 px-4 py-3 text-base text-white outline-none transition focus:border-white"
                  >
                    {GENRES_BY_CATEGORY[category].map((g) => (
                      <option key={g} value={g}>
                        {g}
                      </option>
                    ))}
                  </select>
                </label>
              </div>
              <div className="rounded-2xl border border-white/10 bg-slate-900/70 p-5 text-center sm:p-6">
                <p className="text-xs uppercase tracking-[0.4em] text-slate-400">推定月収</p>
                <p className="pt-2 text-2xl font-semibold text-white sm:text-3xl lg:text-4xl">
                  {new Intl.NumberFormat('ja-JP').format(monthlyProfit)}円
                </p>
                <p className="mt-1 text-xs text-slate-400 sm:text-sm">
                  入力された情報をもとに計算した目安です
                </p>
              </div>
            </section>
  
            {/* 機能紹介 */}
            <section id="features" className="space-y-4 sm:space-y-6">
              <div>
                <h2 className="text-lg font-semibold text-white sm:text-xl">こんなことができる</h2>
                <p className="mt-1 text-xs text-slate-400 sm:text-sm">STARLISTの4つの特徴</p>
              </div>
              <div className="grid gap-4 sm:grid-cols-2">
                {features.map((feature) => (
                  <article
                    key={feature.title}
                    className="rounded-3xl border border-white/10 bg-slate-900/60 p-4 transition hover:border-white/40 sm:p-5"
                  >
                    <h3 className="text-base font-semibold text-white sm:text-lg">{feature.title}</h3>
                    <p className="mt-2 text-sm text-slate-300">{feature.body}</p>
                  </article>
                ))}
              </div>
            </section>
  
            {/* 先行登録フォーム */}
            <section id="signup" className="space-y-4 rounded-3xl border border-white/10 bg-slate-900/80 p-5 sm:p-6">
              <div className="space-y-2">
                <p className="text-xs uppercase tracking-[0.4em] text-slate-400">先行登録</p>
                <h2 className="text-xl font-semibold text-white sm:text-2xl">
                  リリース通知を受け取る
                </h2>
                <p className="text-sm text-slate-300">
                  サービスが始まったら、登録した方法でお知らせします
                </p>
              </div>
              <form
                className="space-y-4 rounded-2xl border border-white/10 bg-slate-950/80 p-4 sm:p-5"
                onSubmit={(event) => {
                  event.preventDefault();
                  alert(
                    `登録完了！\n通知方法: ${NOTIFICATION_METHODS.find((m) => m.value === notificationMethod)?.label}\n連絡先: ${contactInfo}`
                  );
                }}
              >
                {/* 通知方法選択 */}
                <div className="flex flex-col gap-3">
                  <label className="text-sm font-medium text-slate-300">通知方法</label>
                  <div className="grid grid-cols-2 gap-2 sm:grid-cols-3">
                    {NOTIFICATION_METHODS.map((method) => (
                      <button
                        key={method.value}
                        type="button"
                        onClick={() => setNotificationMethod(method.value)}
                        className={`rounded-xl border px-3 py-2 text-xs font-medium transition sm:px-4 sm:py-2.5 sm:text-sm ${
                          notificationMethod === method.value
                            ? "border-white bg-white/10 text-white"
                            : "border-white/10 bg-slate-900/60 text-slate-300 hover:border-white/30"
                        }`}
                      >
                        {method.label}
                      </button>
                    ))}
                  </div>
                </div>
  
                {/* 連絡先入力 */}
                <div className="flex flex-col gap-2">
                  <label htmlFor="contact-info" className="text-sm font-medium text-slate-300">
                    {currentContactInfo.label}
                  </label>
                  <input
                    id="contact-info"
                    type={currentContactInfo.type}
                    value={contactInfo}
                    onChange={(event) => setContactInfo(event.target.value)}
                    placeholder={currentContactInfo.placeholder}
                    required
                    className="rounded-2xl border border-white/10 bg-slate-900/80 px-4 py-3 text-sm text-white outline-none focus:border-white"
                  />
                </div>
  
                {/* 送信ボタン */}
                <button
                  type="submit"
                  className="w-full rounded-2xl bg-emerald-500 px-5 py-3 text-sm font-semibold uppercase tracking-[0.3em] text-white transition hover:bg-emerald-400"
                >
                  登録する
                </button>
              </form>
            </section>
  
            {/* フッター */}
            <footer className="border-t border-white/10 pt-6 text-center text-xs uppercase tracking-[0.4em] text-slate-500">
              STARLIST © {new Date().getFullYear()}｜遊びも収益も、一緒に届ける
            </footer>
          </div>
        </main>
      );
    }
