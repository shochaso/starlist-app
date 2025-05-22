# API Documentation

## 認証

### ログイン
```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

### レスポンス
```json
{
  "token": "jwt_token",
  "user": {
    "id": "user_id",
    "email": "user@example.com",
    "username": "username"
  }
}
```

## サブスクリプション

### 利用可能なプランの取得
```http
GET /api/v1/subscriptions/plans
Authorization: Bearer jwt_token
```

### レスポンス
```json
[
  {
    "id": "plan_id",
    "name": "Basic",
    "description": "Basic plan",
    "price": 1000,
    "currency": "JPY",
    "billingPeriod": "monthly",
    "features": ["feature1", "feature2"],
    "isPopular": false
  }
]
```

### サブスクリプションの作成
```http
POST /api/v1/subscriptions
Authorization: Bearer jwt_token
Content-Type: application/json

{
  "planId": "plan_id",
  "paymentMethodId": "payment_method_id"
}
```

### レスポンス
```json
{
  "id": "subscription_id",
  "userId": "user_id",
  "planId": "plan_id",
  "status": "active",
  "startDate": "2024-01-01T00:00:00Z",
  "endDate": "2024-02-01T00:00:00Z",
  "nextBillingDate": "2024-02-01T00:00:00Z"
}
```

## 支払い

### 支払いの作成
```http
POST /api/v1/payments
Authorization: Bearer jwt_token
Content-Type: application/json

{
  "amount": 1000,
  "currency": "JPY",
  "paymentMethodId": "payment_method_id"
}
```

### レスポンス
```json
{
  "id": "payment_id",
  "userId": "user_id",
  "amount": 1000,
  "currency": "JPY",
  "status": "completed",
  "method": "credit_card",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

## プライバシー設定

### プライバシー設定の取得
```http
GET /api/v1/privacy/settings
Authorization: Bearer jwt_token
```

### レスポンス
```json
{
  "isProfilePublic": true,
  "showEmail": false,
  "showPhone": false,
  "showLocation": false,
  "allowFriendRequests": true,
  "allowMessages": true,
  "allowComments": true,
  "allowNotifications": true,
  "blockedUsers": []
}
```

### プライバシー設定の更新
```http
PUT /api/v1/privacy/settings
Authorization: Bearer jwt_token
Content-Type: application/json

{
  "isProfilePublic": true,
  "showEmail": false,
  "showPhone": false,
  "showLocation": false,
  "allowFriendRequests": true,
  "allowMessages": true,
  "allowComments": true,
  "allowNotifications": true
}
```

## ランキング

### ランキングの取得
```http
GET /api/v1/rankings?type=daily
Authorization: Bearer jwt_token
```

### レスポンス
```json
[
  {
    "userId": "user_id",
    "username": "username",
    "avatarUrl": "https://example.com/avatar.jpg",
    "rank": 1,
    "score": 1000,
    "lastUpdated": "2024-01-01T00:00:00Z"
  }
]
```

## YouTube

### 動画の検索
```http
GET /api/v1/youtube/search?q=query&maxResults=10
Authorization: Bearer jwt_token
```

### レスポンス
```json
[
  {
    "id": "video_id",
    "title": "Video Title",
    "description": "Video Description",
    "thumbnailUrl": "https://example.com/thumb.jpg",
    "publishedAt": "2024-01-01T00:00:00Z",
    "channelId": "channel_id",
    "channelTitle": "Channel Title",
    "viewCount": 1000,
    "likeCount": 100,
    "commentCount": 50,
    "duration": "PT5M"
  }
]
```

## エラーレスポンス

### 400 Bad Request
```json
{
  "error": {
    "code": "invalid_input",
    "message": "Invalid input data",
    "details": {
      "field": "error message"
    }
  }
}
```

### 401 Unauthorized
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Unauthorized access"
  }
}
```

### 403 Forbidden
```json
{
  "error": {
    "code": "forbidden",
    "message": "Access forbidden"
  }
}
```

### 404 Not Found
```json
{
  "error": {
    "code": "not_found",
    "message": "Resource not found"
  }
}
```

### 500 Internal Server Error
```json
{
  "error": {
    "code": "internal_error",
    "message": "Internal server error"
  }
}
```
