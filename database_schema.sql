-- Starlist データベーススキーマ

-- ユーザープロファイルテーブル
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    bio TEXT,
    avatar_url TEXT,
    cover_url TEXT,
    is_star BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT FALSE,
    follower_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- スタープロファイルテーブル（ユーザーの拡張情報）
CREATE TABLE star_profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    category TEXT NOT NULL,
    sub_category TEXT,
    verification_level INTEGER DEFAULT 0,
    official_links JSONB,
    social_media_stats JSONB,
    subscription_tiers JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- コンテンツ消費データテーブル
CREATE TABLE content_consumption (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content_type TEXT NOT NULL, -- youtube, spotify, netflix, etc.
    content_id TEXT NOT NULL,
    content_title TEXT NOT NULL,
    content_creator TEXT,
    content_url TEXT,
    content_thumbnail_url TEXT,
    content_duration INTEGER, -- 秒単位
    consumed_duration INTEGER, -- 秒単位
    consumed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_public BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ファン-スター関係テーブル
CREATE TABLE fan_star_relationships (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fan_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    star_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    relationship_type TEXT NOT NULL, -- follower, subscriber, sponsor
    tier_level INTEGER DEFAULT 1,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(fan_id, star_id, relationship_type)
);

-- サブスクリプション管理テーブル
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    fan_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    star_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tier_level INTEGER NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'JPY',
    billing_cycle TEXT NOT NULL DEFAULT 'monthly', -- monthly, yearly
    payment_method TEXT NOT NULL,
    payment_status TEXT NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    next_billing_date TIMESTAMP WITH TIME ZONE,
    cancelled_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- トランザクションテーブル
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    receiver_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    transaction_type TEXT NOT NULL, -- donation, subscription_payment, sponsor_payment
    amount DECIMAL(10, 2) NOT NULL,
    currency TEXT NOT NULL DEFAULT 'JPY',
    payment_method TEXT NOT NULL,
    payment_status TEXT NOT NULL,
    platform_fee DECIMAL(10, 2) NOT NULL,
    net_amount DECIMAL(10, 2) NOT NULL,
    message TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- カテゴリーテーブル
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    parent_id UUID REFERENCES categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- コンテンツカテゴリーマッピングテーブル
CREATE TABLE content_category_mapping (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    content_id UUID NOT NULL REFERENCES content_consumption(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(content_id, category_id)
);

-- 通知テーブル
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    notification_type TEXT NOT NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    action_url TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- データ連携設定テーブル
CREATE TABLE data_integration_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    integration_type TEXT NOT NULL, -- youtube, spotify, netflix, etc.
    is_enabled BOOLEAN DEFAULT TRUE,
    auth_token TEXT,
    refresh_token TEXT,
    token_expires_at TIMESTAMP WITH TIME ZONE,
    sync_frequency TEXT DEFAULT 'daily', -- realtime, hourly, daily, weekly
    privacy_level TEXT DEFAULT 'public', -- public, private, subscribers_only
    last_synced_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, integration_type)
);

-- インデックス
CREATE INDEX idx_content_consumption_user_id ON content_consumption(user_id);
CREATE INDEX idx_content_consumption_content_type ON content_consumption(content_type);
CREATE INDEX idx_content_consumption_consumed_at ON content_consumption(consumed_at);
CREATE INDEX idx_fan_star_relationships_fan_id ON fan_star_relationships(fan_id);
CREATE INDEX idx_fan_star_relationships_star_id ON fan_star_relationships(star_id);
CREATE INDEX idx_subscriptions_fan_id ON subscriptions(fan_id);
CREATE INDEX idx_subscriptions_star_id ON subscriptions(star_id);
CREATE INDEX idx_transactions_sender_id ON transactions(sender_id);
CREATE INDEX idx_transactions_receiver_id ON transactions(receiver_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_data_integration_settings_user_id ON data_integration_settings(user_id);

-- トリガー関数: 更新時にupdated_atを更新
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 各テーブルに更新トリガーを設定
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_star_profiles_updated_at
BEFORE UPDATE ON star_profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_content_consumption_updated_at
BEFORE UPDATE ON content_consumption
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_fan_star_relationships_updated_at
BEFORE UPDATE ON fan_star_relationships
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at
BEFORE UPDATE ON subscriptions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at
BEFORE UPDATE ON transactions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_categories_updated_at
BEFORE UPDATE ON categories
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_data_integration_settings_updated_at
BEFORE UPDATE ON data_integration_settings
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
