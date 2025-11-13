import type { ReactNode } from "react";

import "./globals.css";

export const metadata = {
  title: "STARLIST - 見た・聴いた・買った記録がファンの求めるコンテンツになる",
  description:
    "視聴履歴・レシート・プレイリストを数ステップで投稿＆リスト化できるクリエイター向けサービス STARLIST のティザーサイト",
  metadataBase: new URL("https://starlist.jp"),
  openGraph: {
    title: "STARLIST - ファンと未来をつくるプラットフォーム",
    description:
      "視聴履歴・レシート・プレイリストを数ステップで投稿＆リスト化できるクリエイター向けサービス STARLIST のティザーサイト",
    siteName: "STARLIST",
    type: "website",
  },
};

export default function RootLayout({ children }: { children: ReactNode }) {
  return (
    <html lang="ja" suppressHydrationWarning>
      <body className="min-h-screen bg-slate-950 text-slate-50 antialiased">{children}</body>
    </html>
  );
}
