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