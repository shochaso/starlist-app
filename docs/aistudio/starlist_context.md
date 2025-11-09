## 1. ディレクトリ構成（概要）

```
lib/
└─ src/
   ├─ config/          # 環境変数ラッパー・プロバイダー定義
   ├─ core/            # 共通コンポーネント・テーマ・ルーティング
   ├─ data/            # 汎用モデルとリポジトリ
   ├─ features/        # 機能別モジュール（auth, ops, star, analytics 等）
   ├─ services/        # 共有サービス（telemetry, icon registry, parsers）
   ├─ providers/       # アプリ全体で共有する Riverpod プロバイダー
   └─ widgets/         # 汎用 UI

lib/features/          # 旧ディレクトリ（新旧 UI が混在）

assets/
├─ config/             # JSON 設定・サービスアイコンマップ
├─ icons/              # 共通アイコン（services/ サブディレクトリ含む）
├─ mockups/            # UI モック画像
└─ service_icons/      # 透過 PNG / SVG 群

supabase/
├─ functions/
│  ├─ exchange/        # Auth0 id_token → Supabase JWT 交換
│  ├─ ops-alert/       # 監視アラート集計/dryRun
│  ├─ ops-health/      # v_ops_5min + alert history の集約 API
│  ├─ ops-summary-email/ # 週次 OPS レポート生成
│  ├─ sign-url/        # Supabase Storage 署名 URL 発行
│  └─ telemetry/       # Flutter からの OPS メトリクス受付
└─ migrations/         # Postgres/RLS 定義

scripts/               # `run_chrome.sh`, seed スクリプト、CI 補助
server/src/            # NestJS (ingest, media, metrics, health)
docs/                  # プロジェクト仕様・運用・レポート
test/                  # Flutter/Dart テスト一式
```

---

## 2. モデル定義

### Star (lib/models/star.dart)
```dart
class Star {
  final String id;
  final String name;
  final List<String> platforms;
  final List<String> genres;
  final String rank;
  final int followers;
  final String imageUrl;
  final Map<String, GenreRating> genreRatings;
  final bool isVerified;
  final List<SocialAccount> socialAccounts;
  final String? description;
}

class GenreRating {
  final int level;
  final int points;
  final DateTime lastUpdated;
}

class SocialAccount {
  final String platform;
  final String username;
  final String url;
  final bool isVerified;
  final DateTime verifiedAt;
}
```

### User (lib/models/user.dart)
```dart
class User {
  final String id;
  final String name;
  final String email;
  final UserType type;        // star | fan
  final FanPlanType? fanPlanType; // free/light/standard/premium
  final String? profileImageUrl;
  final List<String>? platforms;
  final List<String>? genres;
  final DateTime createdAt;
}
```

### StarData ドメイン (lib/features/star_data/domain/star_data.dart)
```dart
class StarData {
  final String id;
  final StarDataCategory category;
  final String title;
  final String? description;
  final String serviceIcon;
  final Uri? url;
  final String? imageUrl;
  final DateTime createdAt;
  final StarDataVisibility visibility;
  final String? starComment;
  final Map<String, dynamic>? enrichedMetadata;
}

class StarProfile {
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final int? totalFollowers;
  final StarSnsLinks snsLinks;
}

class StarDataViewerAccess {
  final bool isLoggedIn;
  final bool canViewFollowersOnlyContent;
  final bool isOwner;
  final bool canToggleActions;
  final Map<StarDataCategory, int> categoryDigest;
}
```

### Ops Telemetry & Metrics (lib/src/features/ops/)
```dart
class OpsTelemetry {
  final String baseUrl;
  final String app;
  final String env;
  Future<bool> send({required String event, required bool ok, int? latencyMs, String? errCode, Map<String, dynamic>? extra});
}

class OpsMetric {
  final DateTime bucketStart;
  final String env;
  final String app;
  final String eventType;
  final int successCount;
  final int errorCount;
  final int? p95Ms;
}

class OpsKpiSummary {
  final int total;
  final int successCount;
  final int errorCount;
  final double errorRate;
  final int? latestP95Ms;
}

class OpsAlert {
  final String id;
  final String title;
  final String severity; // info | warning | critical
  final DateTime createdAt;
  final String description;
  final bool acknowledged;
}
```

### YouTube/Parsed Video Models
```dart
class YouTubeVideo {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final DateTime publishedAt;
  final String channelId;
  final String channelTitle;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final Duration duration;
}

/// OCR から抽出した動画（ParsedVideo相当）
class VideoData {
  final String title;
  final String channel;
  final String? duration;
  final String? viewedAt;
  final String? viewCount;
  final double confidence;
}
```

### ServiceIconRegistry (lib/services/service_icon_registry.dart)
```dart
class ServiceIconRegistry {
  static Future<void> init();
  static Map<String, String> get icons;
  static Widget iconFor(String key, {double size = 24, IconData? fallback});
  static Widget? iconForOrNull(String? key, {double size = 24});
  static String? pathFor(String key);
  static void clearCache();
  static Map<String, String> debugAutoMap();
}
```

---

## 3. Provider設計

### ops_metrics_provider (lib/src/features/ops/providers/ops_metrics_provider.dart)
- `OpsMetricsFilter` (`env`, `app`, `eventType`, `sinceMinutes`) を `StateNotifier` で管理。
- `opsMetricsSeriesProvider` = `AutoDisposeAsyncNotifier<List<OpsMetric>>`
  - 30秒ごとの `Timer` で `_scheduleRefresh()`
  - 重複フェッチ防止 (フィルタと最終ハッシュを比較、5秒ウィンドウ内はスキップ)
  - `manualRefresh()` で強制リフレッシュ
  - `OPS_MOCK` フラグでダミー系列を生成
- `opsRecentAlertsProvider` は Edge `ops-alert` を置き換えるまではモックリストを返却
- `opsMetricsAuthErrorProvider` (StateProvider<bool>) で 401/403 UI の赤枠制御

### current_user_provider (lib/providers/user_provider.dart)
- `UserInfoNotifier extends StateNotifier<UserInfo>`
  - `loadFromSupabase()` で `profiles` テーブルを fetch
  - `Supabase.instance.client.auth.onAuthStateChange` を監視し、ログアウト時は `state = UserInfo(...)` でクリア
  - 共有メソッド: `_initializeUserState()`, `_setLoggedOut()`

### supabaseClientProvider (lib/src/config/providers.dart)
```dart
final supabaseClientProvider = riverpod.Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
```

### YouTubeHistoryNotifier (lib/providers/youtube_history_provider.dart)
- `StateNotifier<List<YouTubeHistoryItem>>`
- `addHistory(List<YouTubeHistoryItem>)` でセッションIDの自動付与・Supabase挿入
- `clearHistory`, `removeHistoryItem`, `removeHistoryGroup`, `getLatestHistory()`, `getGroupedHistory()`
- `YouTubeHistoryGroup` モデルで UI 集計

### Link Enricher Provider (planned / server counterpart)
- スマートレシート・OCR結果を `enrichItemsBasic()` で JAN/thumbnail を補完（NestJS `enrich.processor.ts`）
- Flutter では `link_enricher_provider` 調達予定：BullMQ キューへ投入し、結果を `media_items` からポーリングする設計（ドキュメント参照）

### Auth / External Providers
- `external_auth_provider.dart` wraps LINE/Auth0 flows before hitting `supabase/functions/exchange`.
- `theme_provider_enhanced.dart` (under `lib/src/providers/`) toggles light/dark and persists to `SharedPreferences`.

---

## 4. Edge Functions / API 契約

### telemetry (`POST /functions/v1/telemetry`)
```json
// Request
{
  "app": "starlist",
  "env": "prod",
  "event": "search.sla_missed",
  "ok": false,
  "latency_ms": 1200,
  "err_code": "timeout",
  "extra": { "query": "YOASOBI" }
}
// Response (201)
{ "ok": true }
```

### ops-alert (`GET|POST /functions/v1/ops-alert`)
```json
// Query: /ops-alert?dry_run=true&minutes=30
{
  "ok": true,
  "dryRun": true,
  "period_minutes": 30,
  "metrics": {
    "total": 420,
    "failures": 21,
    "failure_rate": "5.00",
    "p95_latency_ms": 780
  },
  "alerts": [
    {
      "type": "p95_latency",
      "message": "High p95 latency: 780ms",
      "value": 780,
      "threshold": 500
    }
  ]
}
```

### ops-health (`GET /functions/v1/ops-health?period=6h&app=flutter_web`)
```json
{
  "ok": true,
  "period": "6h",
  "aggregations": [
    {
      "app": "flutter_web",
      "env": "prod",
      "event": "search",
      "uptime_percent": 99.2,
      "mean_p95_ms": 640,
      "alert_count": 2,
      "alert_trend": "stable"
    }
  ]
}
```

### ops-summary-email (`POST /functions/v1/ops-summary-email`)
```json
// Request
{ "dryRun": true, "period": "7d" }
// Response
{
  "ok": true,
  "dryRun": true,
  "report_week": "2025-W45",
  "preview": "<!DOCTYPE html>...STARLIST OPS Weekly Summary...",
  "metrics": {
    "uptime_percent": 99.85,
    "mean_p95_ms": 420,
    "alert_count": 3,
    "alert_trend": "↑",
    "alert_change": 1
  }
}
```

### sign-url (`POST /functions/v1/sign-url`)
```json
// Request
{ "mode": "path", "path": "uploads/private/abc123.png", "expiresIn": 900 }
// Response
{ "url": "https://...signed", "ttl": 900 }
```

### exchange (`POST /functions/v1/exchange`)
```json
// Request
{ "id_token": "eyJhbGciOi..." }
// Response
{ "supabase_jwt": "eyJhbGciOiJIUzI1NiIs...", "expires_in": 600 }
```

---

## 5. 共通定数・環境変数

| Key | 用途 |
| --- | --- |
| `SUPABASE_URL` (.env / dart-define) | Supabase プロジェクト URL。Edge Functions でも使用。 |
| `SUPABASE_ANON_KEY` | Flutter クライアントの匿名キー。 |
| `SUPABASE_SECRET_KEY` | サーバー処理用。 |
| `YOUTUBE_API_KEY` | YouTube Data API 連携。 |
| `APP_ENV` | `development / staging / production` スイッチ。 |
| `ASSETS_CDN_ORIGIN` | 画像/CDN のベース URL。 |
| `BUCKET_PUBLIC_ICONS`, `BUCKET_PRIVATE_ORIGINALS` | Storage バケット識別。 |
| `SIGNED_URL_TTL_SECONDS` | 署名 URL の TTL。 |
| `APP_BUILD_VERSION` | ビルド番号表示に利用。 |
| `API_BASE` (`docAiApiBase`) | Document AI プロキシ。 |
| `FAILURE_RATE_THRESHOLD`, `P95_LATENCY_THRESHOLD` | Edge `ops-alert` の閾値。 |
| `CORS_ALLOW_*` | `exchange` 関数の CORS ポリシー。 |
| `AUTH0_DOMAIN`, `SUPABASE_JWT_SECRET` | Token 交換用。 |

---

## 6. UI階層構造

### StarlistMainScreen (lib/screens/starlist_main_screen.dart)
```
Scaffold
├─ Custom AppBar (gradient title, actions: gacha, notifications)
├─ Drawer (AnimatedSwitcher)
│   ├─ User banner (role badge)
│   ├─ Primary nav items (Home/Search/DataImport/Mylist/Profile)
│   ├─ Conditional Star block (Data Import, Dashboard, OPS Dashboard)
│   ├─ Conditional Fan block (Subscription, Star Points)
│   └─ Quick actions (Theme toggle, Login status)
└─ Body (tabbed)
    ├─ Tab 0: Home feed (YouTube history, posts, trending, ads)
    ├─ Tab 1: SearchScreen
    ├─ Tab 2: DataImportScreen
    ├─ Tab 3: MylistScreen
    └─ Tab 4: ProfileScreen
```

### StarDataViewPage (lib/features/star_data/presentation/star_data_view_page.dart)
```
Scaffold
└─ SafeArea
    └─ CustomScrollView
        ├─ Sliver: StarHeader (avatar, counts)
        ├─ Sliver: StarActionBar (Follow/Share/Report)
        ├─ Sliver: StarFilterBar (categories)
        ├─ Sliver: LinearProgressIndicator (when refreshing)
        ├─ StarDataGrid (cards: image, metadata, paywall guard)
        ├─ Sliver: CircularProgressIndicator (infinite scroll)
        └─ Sliver: Spacer
```

### OpsDashboardPage (lib/src/features/ops/pages/ops_dashboard_page.dart)
```
Scaffold
├─ AppBar ("OPS Dashboard", manual refresh icon)
└─ RefreshIndicator
    └─ ListView
        ├─ _FilterRow (env/app/event dropdowns + duration + refresh button)
        ├─ AutoRefreshIndicator (30s spinner)
        ├─ KPI Row (cards with Semantics + tooltips)
        ├─ MetricsCharts (LineChart for p95, stacked BarChart for success/error)
        ├─ AlertsCard (recent alerts list, fallback text)
        ├─ _EmptyState / _ErrorState (CTA buttons)
        └─ Loading skeleton cards
```

---

## 7. 主要関数シグネチャ

```dart
Future<bool> OpsTelemetry.send({
  required String event,
  required bool ok,
  int? latencyMs,
  String? errCode,
  Map<String, dynamic>? extra,
});

Future<void> OpsMetricsSeriesNotifier.manualRefresh();
Future<List<OpsMetric>> OpsMetricsSeriesNotifier._refreshWithFilter(
  OpsMetricsFilter filter, { bool force = false });

Future<StarDataPage> StarDataRepository.fetchStarData({
  required String username,
  StarDataCategory? category,
  String? cursor,
});

Future<void> YouTubeHistoryNotifier.addHistory(List<YouTubeHistoryItem> newItems);
void YouTubeHistoryNotifier.clearHistory();
List<YouTubeHistoryGroup> YouTubeHistoryNotifier.getGroupedHistory();

Future<void> UserInfoNotifier.loadFromSupabase();
void UserInfoNotifier.setUser(UserInfo user);
void UserInfoNotifier.clearUser();

Widget ServiceIconRegistry.iconFor(String key, {double size = 24, IconData? fallback});
Widget? ServiceIconRegistry.iconForOrNull(String? key, {double size = 24});

Future<Response> telemetry(req);          // Deno serve handler (Edge)
Future<Response> opsAlert(req);           // Aggregates metrics + thresholds
Future<Response> opsHealth(req);          // Authenticated uptime summary
Future<Response> opsSummaryEmail(req);    // Weekly HTML email generator
Future<Response> signUrl(req);            // Storage URL signer with ACL
Future<Response> exchange(req);           // Auth0 ⇨ Supabase JWT
```

---

## 8. ドメイン定義・文脈情報

- **Starlist とは**  
  README/STARLIST_OVERVIEW によると、スター（YouTuber/アーティスト/インフルエンサー）が日常の消費行動（視聴履歴、購買、音楽、SNS）を記録・共有し、ファンが閲覧・応援できる Web/Flutter プラットフォーム。  
  - 日常データ（コンテンツ/購入履歴）を軸に新しいマネタイズ手段を提供。  
  - ファンは階層型サブスクで限定コンテンツやコメント機能を利用。  
  - 監査イベント (`auth.*`, `rls.*`, `ops.subscription.*`) を Edge Telemetry に流し、ダッシュボード/レポートで可視化。

- **技術構成**  
  - **Frontend**: Flutter + Riverpod。Web/デスクトップ/モバイル共通。  
  - **Backend**: NestJS (`server/src`) で ingest/media/metrics jobs。  
  - **Supabase**: Postgres + RLS + Edge Functions (`exchange`, `sign-url`, `telemetry`, `ops-*`).  
  - **Cloud**: Cloud Run (DocAI proxy), Auth0/LINE (token exchange), Stripe (payments).  
  - **Monitoring**: OPS Dashboard (Day6) + Alert Automation (Day7) + Weekly Summary Email (Day9 roadmap).  

- **Docs 背景**  
  - `docs/docs/COMMON_DOCS_INDEX.md` … 全資料リンク。  
  - `docs/ops/OPS-TELEMETRY-SYNC-001.md` … Telemetry 仕様・監査イベント命名。  
  - `docs/reports/DAY6_SOT_DIFFS.md` / `DAY7_SOT_DIFFS.md` … OPS ダッシュボード/アラート実装記録。  
  - 将来: `OPS-SUMMARY-AUTOMATION-001.md` で週次レポート設計（Cron `ops-weekly-summary`, HTML email template, Flutter settings toggle）。

---

**Missing Sections**  
現時点で `link_enricher_provider` の Flutter 実装は未確認（NestJS enrich service のみ）。利用する場合は `server/src/ingest/services/enrich.service.ts` と BullMQ Processor を参照し、Flutter 側の Provider/API 契約を定義してください。
