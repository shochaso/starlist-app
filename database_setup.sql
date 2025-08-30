-- ガチャ回数管理テーブル
CREATE TABLE IF NOT EXISTS gacha_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  base_attempts INTEGER NOT NULL DEFAULT 1,
  bonus_attempts INTEGER NOT NULL DEFAULT 0,
  used_attempts INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, date)
);

-- 広告視聴記録テーブル
CREATE TABLE IF NOT EXISTS ad_views (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ad_type TEXT NOT NULL,
  ad_provider TEXT NOT NULL,
  ad_id TEXT NOT NULL,
  view_duration INTEGER NOT NULL DEFAULT 0,
  completed BOOLEAN NOT NULL DEFAULT FALSE,
  reward_attempts INTEGER NOT NULL DEFAULT 0,
  viewed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ガチャ履歴テーブル
CREATE TABLE IF NOT EXISTS gacha_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  gacha_result JSONB NOT NULL,
  attempts_used INTEGER NOT NULL DEFAULT 1,
  source TEXT NOT NULL DEFAULT 'normal',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ガチャ回数初期化関数
CREATE OR REPLACE FUNCTION initialize_daily_gacha_attempts(user_id_param UUID)
RETURNS VOID AS $$
BEGIN
  INSERT INTO gacha_attempts (user_id, date, base_attempts, bonus_attempts, used_attempts)
  VALUES (user_id_param, CURRENT_DATE, 1, 0, 0)
  ON CONFLICT (user_id, date) 
  DO NOTHING;
END;
$$ LANGUAGE plpgsql;

-- 利用可能なガチャ回数を取得する関数
CREATE OR REPLACE FUNCTION get_available_gacha_attempts(user_id_param UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  -- 今日のレコードがなければ作成
  PERFORM initialize_daily_gacha_attempts(user_id_param);
  
  -- 統計情報を取得
  SELECT json_build_object(
    'baseAttempts', COALESCE(base_attempts, 1),
    'bonusAttempts', COALESCE(bonus_attempts, 0),
    'usedAttempts', COALESCE(used_attempts, 0),
    'availableAttempts', COALESCE(base_attempts + bonus_attempts - used_attempts, 1),
    'date', date
  ) INTO result
  FROM gacha_attempts 
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
  
  -- レコードが見つからない場合はデフォルト値
  IF result IS NULL THEN
    result := json_build_object(
      'baseAttempts', 1,
      'bonusAttempts', 0,
      'usedAttempts', 0,
      'availableAttempts', 1,
      'date', CURRENT_DATE
    );
  END IF;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- ガチャ回数を消費する関数
CREATE OR REPLACE FUNCTION consume_gacha_attempt(user_id_param UUID)
RETURNS BOOLEAN AS $$
DECLARE
  available_count INTEGER;
BEGIN
  -- 今日のレコードがなければ作成
  PERFORM initialize_daily_gacha_attempts(user_id_param);
  
  -- 利用可能回数をチェック
  SELECT (base_attempts + bonus_attempts - used_attempts) INTO available_count
  FROM gacha_attempts 
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
  
  -- 回数が不足している場合
  IF available_count <= 0 THEN
    RETURN FALSE;
  END IF;
  
  -- 使用回数を増加
  UPDATE gacha_attempts 
  SET used_attempts = used_attempts + 1,
      updated_at = NOW()
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ボーナス回数を追加する関数
CREATE OR REPLACE FUNCTION add_gacha_bonus_attempts(user_id_param UUID, bonus_count INTEGER)
RETURNS VOID AS $$
BEGIN
  -- 今日のレコードがなければ作成
  PERFORM initialize_daily_gacha_attempts(user_id_param);
  
  -- ボーナス回数を追加（上限3回）
  UPDATE gacha_attempts 
  SET bonus_attempts = LEAST(bonus_attempts + bonus_count, 3),
      updated_at = NOW()
  WHERE user_id = user_id_param AND date = CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- インデックス作成
CREATE INDEX IF NOT EXISTS idx_gacha_attempts_user_date ON gacha_attempts(user_id, date);
CREATE INDEX IF NOT EXISTS idx_ad_views_user_viewed ON ad_views(user_id, viewed_at);
CREATE INDEX IF NOT EXISTS idx_gacha_history_user_created ON gacha_history(user_id, created_at);
