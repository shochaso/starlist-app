# GACHA / ADS JST3 検証ランブック

## 1. 概要
- JST3:00 起算の日次キー導入 (`get_jst3_date_key`)。
- 広告視聴からのガチャチケット付与をサーバで **1日3回まで** に制限する Lv1 実装（`complete_ad_view_and_grant_ticket`）。
- `ad_views` に device/status/error を記録し、`gacha_history` に報酬メタデータを追加する Lv2-Lite ログ拡張。

## 2. 前提
```bash
cd /Users/shochaso/Downloads/starlist-app
```
- ローカル Supabase 開発スタックを使用すること。
- **本番プロジェクトでは絶対に `supabase db reset` を実行しないこと。**

## 3. ローカル Supabase の起動とマイグレーション適用
```bash
# Supabase ローカルスタック起動
supabase start

# ⚠️ ローカル開発DBを全消ししてマイグレーションを再適用（本番では絶対に実行しない）
supabase db reset

# 既存データを残したまま追加マイグレーションのみ適用したい場合
supabase migration up
```

## 4. Supabase Studio / SQL エディタの開き方
- ブラウザで `http://127.0.0.1:54323` にアクセス → Supabase Studio → 「SQL Editor」を開く。

## 5. JST3:00 日次キー関数 `get_jst3_date_key` の検証SQL
```sql
-- 現在時刻で日次キーが返ることを確認
select get_jst3_date_key(now());

-- JST 2:55 のときは「前日」、3:05 のときは「当日」になるか確認
select
  get_jst3_date_key('2025-11-22 02:55:00+09'::timestamptz) as before3,
  get_jst3_date_key('2025-11-22 03:05:00+09'::timestamptz) as after3;
```
期待: `before3` が前日、`after3` が当日になれば JST3:00 起算ロジックOK。

## 6. `complete_ad_view_and_grant_ticket` の 1日3回制限テスト
1. テスト用の `user_id` を用意する  
   - Studioの「Table Editor」で `auth.users` を開き、任意のユーザーの `id`（UUID）をコピー。

2. 同一 `user_id` で4回RPCを実行して上限動作を確認（`user_id` は差し替えること）
```sql
-- 1回目
select complete_ad_view_and_grant_ticket(
  '11111111-2222-3333-4444-555555555555', -- user_id
  null,                                   -- ad_view_id（null許容実装の場合）
  'test-device-1',                        -- device_id
  'manual-sql-test-1'                     -- user_agent / メモ
);

-- 2回目
select complete_ad_view_and_grant_ticket(
  '11111111-2222-3333-4444-555555555555',
  null,
  'test-device-1',
  'manual-sql-test-2'
);

-- 3回目
select complete_ad_view_and_grant_ticket(
  '11111111-2222-3333-4444-555555555555',
  null,
  'test-device-1',
  'manual-sql-test-3'
);

-- 4回目（ここで日3回上限を超える想定）
select complete_ad_view_and_grant_ticket(
  '11111111-2222-3333-4444-555555555555',
  null,
  'test-device-1',
  'manual-sql-test-4'
);
```

3. `ad_view_id` に `null` を渡せない場合の代替手順  
   先に `ad_views` に行をINSERTし、返った `id` を第2引数に渡す:
```sql
insert into ad_views (user_id, device_id, status, reward_granted, date_key)
values (
  '11111111-2222-3333-4444-555555555555',
  'test-device-1',
  'initiated',
  false,
  get_jst3_date_key(now())
)
returning id;
```
返ってきた `id` を使ってRPCを呼ぶ:
```sql
select complete_ad_view_and_grant_ticket(
  '11111111-2222-3333-4444-555555555555',
  '<上で返ったid>',
  'test-device-1',
  'manual-sql-test-1'
);
```
これを計4回繰り返し、4回目で上限エラー/未付与になることを確認。

## 7. `ad_views` / `gacha_attempts` の確認SQL
### ad_views（3回まで付与されているか）:
```sql
select
  id,
  user_id,
  date_key,
  status,
  reward_granted
from ad_views
where user_id = '11111111-2222-3333-4444-555555555555'
order by created_at desc
limit 10;
```
期待: 同じ user_id で4行あり、うち3行が `reward_granted = true`、4回目は false もしくはRPCが上限エラー。

### gacha_attempts（チケット残高の確認）:
```sql
select
  user_id,
  base_attempts,
  bonus_attempts,
  used_attempts
from gacha_attempts
where user_id = '11111111-2222-3333-4444-555555555555';
```
期待: 直後にガチャを回していなければ `bonus_attempts` が +3、`used_attempts = 0`。

## 8. まとめ（このランブックで確認できること）
- `get_jst3_date_key` が JST3:00 起算で日付を切り替える。
- `complete_ad_view_and_grant_ticket` が **1ユーザー1日3回まで** 付与する。
- `ad_views` に `device_id` / `status` / `reward_granted` が記録される。
- `gacha_attempts` に広告3回分のチケット残高が反映される。

---
対象マイグレーション / RPC 一覧:
- `supabase/migrations/20250722100000_gacha_ads_jst3.sql`
- RPC: `get_jst3_date_key`, `initialize_daily_gacha_attempts_jst3`, `complete_ad_view_and_grant_ticket`, `consume_gacha_attempt_atomic`, `get_available_gacha_attempts`（JST3版）
