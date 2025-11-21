const { LinearClient } = require('@linear/sdk');
const titles = [
  'チャット用 Supabase マイグレーション作成',
  'チャット画像用 Storage バケット作成',
  'スター側チャット画面 UI 実装',
  '運営側スレッド一覧画面の実装',
  '運営側チャット画面の実装',
  'チャット監査ログ（chat_audit_logs）の実装',
  'チャット送信失敗時のエラー処理追加',
  'チャット画像プレビュー＆拡大表示',
  'スター初回アクセス時の thread 自動生成',
  'チャット導線のルーティング追加',
  'チャット画面向け Flutter テーマ調整',
  'チャット機能のQA / E2Eチェック'
];
(async () => {
  const client = new LinearClient({ apiKey: process.env.LINEAR_API_KEY });
  const { nodes } = await client.issues({
    first: 100,
    orderBy: { field: 'createdAt', direction: 'Descending' },
  });
  const found = new Map();
  for (const issue of nodes) {
    if (titles.includes(issue.title)) {
      found.set(issue.title, issue.identifier);
    }
  }
  console.log('Found issues:');
  titles.forEach((title) => {
    console.log(`${title}: ${found.get(title) ?? 'not found'}`);
  });
})();
