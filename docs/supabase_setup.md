# Supabaseプロジェクトのセットアップ手順

## 1. Supabaseプロジェクトの作成

1. [Supabase Dashboard](https://app.supabase.io/)にアクセスし、ログインまたはサインアップします。
2. 「New Project」ボタンをクリックします。
3. 以下の情報を入力します：
   - プロジェクト名：`starlist`（任意）
   - データベースパスワード：強力なパスワードを設定
   - リージョン：アプリの主要ユーザーに近いリージョンを選択
4. 「Create new project」をクリックし、プロジェクトの作成を待ちます（数分かかります）。

## 2. テーブルとRPC関数の作成

プロジェクトが作成されたら、SQLエディタを使用してマイグレーションスクリプトを実行します：

1. Supabaseダッシュボードの左側メニューから「SQL Editor」を選択します。
2. 「New Query」をクリックします。
3. 以下のSQLスクリプトをコピー＆ペーストします：

```sql
-- rankingsテーブルの作成
CREATE TABLE IF NOT EXISTS public.rankings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    userId VARCHAR NOT NULL,
    username VARCHAR NOT NULL,
    avatarUrl VARCHAR,
    rank INTEGER NOT NULL,
    score DOUBLE PRECISION NOT NULL,
    lastUpdated TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    type VARCHAR NOT NULL, -- 'daily', 'weekly', 'monthly', 'yearly', 'allTime'
    metadata JSONB DEFAULT '{}'::jsonb,
    
    -- 複合インデックス
    UNIQUE(userId, type)
);

-- インデックス作成
CREATE INDEX IF NOT EXISTS rankings_userId_idx ON public.rankings (userId);
CREATE INDEX IF NOT EXISTS rankings_type_rank_idx ON public.rankings (type, rank);
CREATE INDEX IF NOT EXISTS rankings_type_score_idx ON public.rankings (type, score DESC);

-- ユーザーのスコアを更新するRPC関数
CREATE OR REPLACE FUNCTION public.update_user_score(
    p_user_id VARCHAR,
    p_score DOUBLE PRECISION,
    p_last_updated TIMESTAMP WITH TIME ZONE DEFAULT now()
) RETURNS VOID AS $$
DECLARE
    daily_rank INTEGER;
    weekly_rank INTEGER;
    monthly_rank INTEGER;
    yearly_rank INTEGER;
    alltime_rank INTEGER;
    username_val VARCHAR;
    avatar_url_val VARCHAR;
BEGIN
    -- ユーザー情報の取得 (実際のプロジェクトではユーザーテーブルから取得)
    -- このサンプルでは仮の値を使用
    username_val := 'User ' || p_user_id;
    avatar_url_val := NULL;
    
    -- デイリーランキングの更新
    SELECT COUNT(*) + 1 INTO daily_rank
    FROM public.rankings
    WHERE type = 'daily' AND score > p_score;
    
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, lastUpdated, type)
    VALUES (p_user_id, username_val, avatar_url_val, daily_rank, p_score, p_last_updated, 'daily')
    ON CONFLICT (userId, type) DO UPDATE
    SET score = p_score, lastUpdated = p_last_updated;
    
    -- ウィークリーランキングの更新
    SELECT COUNT(*) + 1 INTO weekly_rank
    FROM public.rankings
    WHERE type = 'weekly' AND score > p_score;
    
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, lastUpdated, type)
    VALUES (p_user_id, username_val, avatar_url_val, weekly_rank, p_score, p_last_updated, 'weekly')
    ON CONFLICT (userId, type) DO UPDATE
    SET score = p_score, lastUpdated = p_last_updated;
    
    -- マンスリーランキングの更新
    SELECT COUNT(*) + 1 INTO monthly_rank
    FROM public.rankings
    WHERE type = 'monthly' AND score > p_score;
    
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, lastUpdated, type)
    VALUES (p_user_id, username_val, avatar_url_val, monthly_rank, p_score, p_last_updated, 'monthly')
    ON CONFLICT (userId, type) DO UPDATE
    SET score = p_score, lastUpdated = p_last_updated;
    
    -- 全期間ランキングの更新
    SELECT COUNT(*) + 1 INTO alltime_rank
    FROM public.rankings
    WHERE type = 'allTime' AND score > p_score;
    
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, lastUpdated, type)
    VALUES (p_user_id, username_val, avatar_url_val, alltime_rank, p_score, p_last_updated, 'allTime')
    ON CONFLICT (userId, type) DO UPDATE
    SET score = p_score, lastUpdated = p_last_updated;
    
    -- ランキング順位の再計算（すべてのエントリに対して）
    UPDATE public.rankings r1
    SET rank = subquery.new_rank
    FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY type ORDER BY score DESC) AS new_rank
        FROM public.rankings
    ) AS subquery
    WHERE r1.id = subquery.id AND r1.rank != subquery.new_rank;
END;
$$ LANGUAGE plpgsql;

-- ユーザーの近くのランキングを取得するRPC関数
CREATE OR REPLACE FUNCTION public.get_nearby_users(
    p_user_rank INTEGER,
    p_type VARCHAR,
    p_limit INTEGER DEFAULT 5
) RETURNS SETOF public.rankings AS $$
DECLARE
    half_limit INTEGER;
BEGIN
    half_limit := p_limit / 2;
    
    RETURN QUERY
    SELECT *
    FROM public.rankings
    WHERE type = p_type AND rank BETWEEN 
        GREATEST(1, p_user_rank - half_limit) AND
        p_user_rank + half_limit
    ORDER BY rank ASC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;
```

4. 「Run」ボタンをクリックしてSQLを実行します。

## 3. Row Level Securityの設定

データのセキュリティを確保するため、Row Level Security (RLS)を設定します：

1. Supabaseダッシュボードの左側メニューから「Authentication」→「Policies」を選択します。
2. `rankings`テーブルを選択します。
3. 「Enable RLS」をクリックしてRow Level Securityを有効にします。
4. 以下のポリシーを追加します：

### 読み取りポリシー（全員が読み取り可能）

- 名前：`allow_read_rankings`
- 操作：`SELECT`
- ターゲットロール：`authenticated` および `anon`
- ポリシー定義：`true`

### 書き込みポリシー（認証済みユーザーのみ自分のデータを更新可能）

- 名前：`allow_update_own_rankings`
- 操作：`INSERT`, `UPDATE`
- ターゲットロール：`authenticated`
- ポリシー定義：`auth.uid()::text = userId`

## 4. テストデータの挿入

ランキングのテストデータを挿入します：

1. 新しいSQLクエリを作成します：

```sql
-- テストユーザーを10人作成
DO $$
DECLARE
  i INTEGER;
BEGIN
  FOR i IN 1..10 LOOP
    -- デイリーランキング
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, type)
    VALUES (
      'user' || i, 
      'テストユーザー' || i, 
      'https://i.pravatar.cc/150?u=' || i,
      i,
      RANDOM() * 1000,
      'daily'
    );
    
    -- ウィークリーランキング
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, type)
    VALUES (
      'user' || i, 
      'テストユーザー' || i, 
      'https://i.pravatar.cc/150?u=' || i,
      i,
      RANDOM() * 5000,
      'weekly'
    );
    
    -- マンスリーランキング
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, type)
    VALUES (
      'user' || i, 
      'テストユーザー' || i, 
      'https://i.pravatar.cc/150?u=' || i,
      i,
      RANDOM() * 20000,
      'monthly'
    );
    
    -- 全期間ランキング
    INSERT INTO public.rankings (userId, username, avatarUrl, rank, score, type)
    VALUES (
      'user' || i, 
      'テストユーザー' || i, 
      'https://i.pravatar.cc/150?u=' || i,
      i,
      RANDOM() * 100000,
      'allTime'
    );
  END LOOP;
END $$;

-- ランキング順位の再計算
UPDATE public.rankings r1
SET rank = subquery.new_rank
FROM (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY type ORDER BY score DESC) AS new_rank
    FROM public.rankings
) AS subquery
WHERE r1.id = subquery.id;
```

2. 「Run」ボタンをクリックしてテストデータを挿入します。

## 5. APIキーと接続情報の取得

アプリからSupabaseに接続するための情報を取得します：

1. Supabaseダッシュボードの左側メニューから「Settings」→「API」を選択します。
2. 以下の情報をコピーして`.env`ファイルに保存します：
   - Project URL → `SUPABASE_URL`
   - anon/public key → `SUPABASE_ANON_KEY`
   - service_role key → `SUPABASE_SECRET_KEY`（安全に保管してください）

## 6. アプリのテスト実行

1. プロジェクトルートで`.env`ファイルを作成し、上記の環境変数を設定します：

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SECRET_KEY=your-secret-key
YOUTUBE_API_KEY=your-youtube-api-key
APP_ENV=development
```

2. アプリを実行して、ランキング機能をテストします：

```bash
flutter run --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY --dart-define=YOUTUBE_API_KEY=$YOUTUBE_API_KEY
```

これでSupabaseの設定が完了し、ランキング機能を実装するためのバックエンドが準備できました。 