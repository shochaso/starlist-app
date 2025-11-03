# AI Scheduler Model：スケジュール自動連携設計

## 📋 概要

**AI Scheduler Model** は、スター・ファンのスケジュールを自動的に管理し、最適なタイミングで投稿・イベント・タスクを提案するシステムです。**Google Calendar API**、**Supabase**、**AI分析エンジン**を統合し、個人の行動パターンを学習して空き時間を最適化します。

---

## 🎯 目的

### スター向け
- **投稿タイミングの最適化**: ファンの活動時間帯に合わせて投稿
- **空き時間の有効活用**: スケジュールの隙間に適切なタスクを提案
- **イベント計画**: ファン交流イベントの最適な日時を提案

### ファン向け
- **推しスケジュールの追跡**: 推しの投稿・配信予定を自動通知
- **推し活時間の確保**: 自分のスケジュールに推し活時間を自動ブロック
- **リマインダー**: 推しの誕生日・記念日を事前通知

---

## 🏗️ アーキテクチャ

### システム構成

```
┌─────────────────────┐
│  Google Calendar    │ ← ユーザーのスケジュール
└──────────┬──────────┘
           │ API
           ↓
┌─────────────────────┐
│   Calendar Sync     │ ← 定期的に同期
│     Service         │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Supabase DB       │ ← スケジュールデータ保存
│  (schedules table)  │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   AI Analyzer       │ ← パターン分析・提案生成
│  (Edge Function)    │
└──────────┬──────────┘
           │
           ↓
┌─────────────────────┐
│   Flutter UI        │ ← 提案表示・スケジュール編集
└─────────────────────┘
```

---

## 📊 データモデル

### Supabase テーブル設計

#### schedules テーブル
```sql
CREATE TABLE schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  category TEXT, -- 'work', 'personal', 'starlist_post', 'fan_event'
  google_calendar_id TEXT, -- Google Calendar との紐付け
  is_recurring BOOLEAN DEFAULT false,
  recurrence_rule TEXT, -- iCal形式
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_schedules_user_time ON schedules(user_id, start_time);
CREATE INDEX idx_schedules_category ON schedules(user_id, category);
```

#### ai_schedule_suggestions テーブル
```sql
CREATE TABLE ai_schedule_suggestions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  suggested_time TIMESTAMPTZ NOT NULL,
  activity_type TEXT NOT NULL, -- 'post', 'event', 'task'
  title TEXT NOT NULL,
  reason TEXT, -- AI による提案理由
  confidence_score FLOAT, -- 0.0 ~ 1.0
  is_accepted BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## 🔌 Google Calendar API 連携

### 1. 認証設定

#### OAuth 2.0 フロー
```dart
// lib/services/google_calendar_service.dart
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/auth_io.dart';

class GoogleCalendarService {
  static const _scopes = [CalendarApi.calendarScope];

  Future<AuthClient> authenticate() async {
    final credentials = ServiceAccountCredentials.fromJson({
      'client_id': '...',
      'client_secret': '...',
    });

    return await clientViaServiceAccount(credentials, _scopes);
  }
}
```

### 2. イベント取得

```dart
Future<List<Event>> fetchUpcomingEvents({int maxResults = 50}) async {
  final client = await authenticate();
  final calendar = CalendarApi(client);

  final now = DateTime.now().toUtc();
  final events = await calendar.events.list(
    'primary',
    timeMin: now,
    maxResults: maxResults,
    singleEvents: true,
    orderBy: 'startTime',
  );

  return events.items ?? [];
}
```

### 3. Supabaseへの同期

```dart
Future<void> syncToSupabase(String userId, List<Event> events) async {
  final supabase = Supabase.instance.client;

  for (final event in events) {
    await supabase.from('schedules').upsert({
      'user_id': userId,
      'title': event.summary,
      'description': event.description,
      'start_time': event.start?.dateTime?.toIso8601String(),
      'end_time': event.end?.dateTime?.toIso8601String(),
      'google_calendar_id': event.id,
      'category': _detectCategory(event.summary),
    });
  }
}
```

---

## 🤖 AI空き時間最適化アルゴリズム

### 1. 空き時間検出

```dart
class FreeTimeDetector {
  /// スケジュールの隙間を検出
  List<TimeSlot> detectFreeSlots({
    required List<Schedule> schedules,
    required DateTime startDate,
    required DateTime endDate,
    int minDurationMinutes = 30,
  }) {
    final freeSlots = <TimeSlot>[];
    var currentTime = startDate;

    // スケジュールを時系列でソート
    schedules.sort((a, b) => a.startTime.compareTo(b.startTime));

    for (final schedule in schedules) {
      // 現在時刻と次のイベント開始の間に空きがあるか
      if (schedule.startTime.difference(currentTime).inMinutes >= minDurationMinutes) {
        freeSlots.add(TimeSlot(
          start: currentTime,
          end: schedule.startTime,
        ));
      }
      currentTime = schedule.endTime;
    }

    // 最後のイベント後の空き時間
    if (endDate.difference(currentTime).inMinutes >= minDurationMinutes) {
      freeSlots.add(TimeSlot(
        start: currentTime,
        end: endDate,
      ));
    }

    return freeSlots;
  }
}
```

### 2. 最適タスク配置

```dart
class TaskScheduler {
  /// 空き時間に最適なタスクを配置
  Future<List<ScheduleSuggestion>> suggestOptimalSchedule({
    required String userId,
    required List<TimeSlot> freeSlots,
  }) async {
    final suggestions = <ScheduleSuggestion>[];
    final userContext = await _collectUserContext(userId);

    for (final slot in freeSlots) {
      final duration = slot.duration;

      // AI が最適なタスクを提案
      final task = await _analyzeOptimalTask(
        userContext: userContext,
        availableDuration: duration,
        timeOfDay: slot.start.hour,
      );

      if (task != null) {
        suggestions.add(ScheduleSuggestion(
          timeSlot: slot,
          task: task,
          reason: task.reason,
          confidenceScore: task.confidence,
        ));
      }
    }

    return suggestions;
  }

  /// AI による最適タスク分析
  Future<TaskSuggestion?> _analyzeOptimalTask({
    required Map<String, dynamic> userContext,
    required Duration availableDuration,
    required int timeOfDay,
  }) async {
    // Supabase Edge Function 経由で AI に問い合わせ
    final response = await supabase.functions.invoke(
      'ai-schedule-optimizer',
      body: {
        'context': userContext,
        'duration_minutes': availableDuration.inMinutes,
        'time_of_day': timeOfDay,
      },
    );

    return TaskSuggestion.fromJson(response.data);
  }
}
```

---

## 🧠 行動パターン学習

### 1. アクティビティ分析

```dart
class ActivityPatternAnalyzer {
  /// ユーザーの行動パターンを分析
  Future<ActivityPattern> analyzePattern(String userId) async {
    final posts = await _getPostHistory(userId);
    final views = await _getViewingHistory(userId);

    return ActivityPattern(
      // 曜日別の活動傾向
      weekdayPattern: _analyzeWeekdayTrend(posts, views),
      // 時間帯別の活動傾向
      hourlyPattern: _analyzeHourlyTrend(posts, views),
      // カテゴリ別の活動頻度
      categoryFrequency: _analyzeCategoryFrequency(posts, views),
    );
  }

  Map<int, double> _analyzeWeekdayTrend(
    List<Post> posts,
    List<ViewingHistory> views,
  ) {
    final counts = <int, int>{};

    for (final post in posts) {
      final weekday = post.createdAt.weekday;
      counts[weekday] = (counts[weekday] ?? 0) + 1;
    }

    // 正規化（0.0 ~ 1.0）
    final max = counts.values.reduce((a, b) => a > b ? a : b);
    return counts.map((k, v) => MapEntry(k, v / max));
  }
}
```

### 2. 最適投稿時間予測

```dart
class OptimalPostTimePredictor {
  /// ファンの活動時間帯を分析し、最適な投稿時間を予測
  Future<DateTime> predictOptimalPostTime({
    required String starId,
    required DateTime targetDate,
  }) async {
    // ファンの活動パターンを取得
    final fans = await _getStarFans(starId);
    final fanActivities = await _getFanActivities(fans);

    // 最もアクティブな時間帯を検出
    final hourlyActivity = _calculateHourlyActivity(fanActivities);
    final peakHour = hourlyActivity.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // スターのスケジュールを確認
    final starSchedule = await _getSchedule(starId, targetDate);
    final freeSlots = FreeTimeDetector().detectFreeSlots(
      schedules: starSchedule,
      startDate: targetDate,
      endDate: targetDate.add(Duration(days: 1)),
    );

    // ピーク時間帯に最も近い空き時間を選択
    final optimalSlot = _findClosestSlot(freeSlots, peakHour);

    return optimalSlot.start;
  }
}
```

---

## 🔄 スター/ファンのスケジュール同期

### 1. スター → ファン同期

#### イベント公開設定
```dart
class StarEventPublisher {
  /// スターのイベントを公開（ファンが購読可能）
  Future<void> publishEvent({
    required String starId,
    required Schedule event,
    bool isPublic = true,
  }) async {
    await supabase.from('star_public_events').insert({
      'star_id': starId,
      'title': event.title,
      'start_time': event.startTime.toIso8601String(),
      'end_time': event.endTime.toIso8601String(),
      'is_public': isPublic,
      'event_type': event.category, // 'live', 'post', 'event'
    });
  }
}
```

#### ファンのカレンダーに追加
```dart
class FanCalendarSync {
  /// 推しのイベントをファンのカレンダーに同期
  Future<void> syncStarEvents({
    required String fanId,
    required String starId,
  }) async {
    final starEvents = await supabase
        .from('star_public_events')
        .select()
        .eq('star_id', starId)
        .eq('is_public', true)
        .gte('start_time', DateTime.now().toIso8601String());

    for (final event in starEvents) {
      // Google Calendar に追加
      await _addToGoogleCalendar(fanId, event);

      // Supabase にも記録
      await supabase.from('fan_subscribed_events').insert({
        'fan_id': fanId,
        'star_id': starId,
        'event_id': event['id'],
        'reminder_minutes': 30, // 30分前に通知
      });
    }
  }
}
```

### 2. リアルタイム更新

```dart
class RealtimeScheduleSync {
  StreamSubscription? _subscription;

  /// スケジュール変更をリアルタイムで監視
  void watchScheduleChanges(String userId) {
    _subscription = supabase
        .from('schedules')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .listen((schedules) {
          // UI更新
          _notifyScheduleChange(schedules);
        });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
```

---

## 📈 AIによる空き時間最適化

### 1. コンテキスト収集

```dart
class ScheduleContextCollector {
  Future<Map<String, dynamic>> collectContext(String userId) async {
    return {
      'schedules': await _getSchedules(userId),
      'past_posts': await _getPostHistory(userId),
      'viewing_pattern': await _getViewingPattern(userId),
      'task_backlog': await _getTaskBacklog(userId),
      'fan_activity': await _getFanActivityPattern(userId),
    };
  }
}
```

### 2. Supabase Edge Function（AI処理）

```typescript
// supabase/functions/ai-schedule-optimizer/index.ts
import { serve } from 'https://deno.land/std/http/server.ts';
import { createClient } from '@supabase/supabase-js';

serve(async (req) => {
  const { context, duration_minutes, time_of_day } = await req.json();

  // AI に問い合わせ（Claude API）
  const aiResponse = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'x-api-key': Deno.env.get('ANTHROPIC_API_KEY'),
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    body: JSON.stringify({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: `
ユーザーコンテキスト: ${JSON.stringify(context)}
空き時間: ${duration_minutes}分
時間帯: ${time_of_day}時

この空き時間に最適なタスクを提案してください。
- タスクタイプ（投稿作成/ファン交流/データ整理）
- タイトル
- 理由
- 信頼度スコア（0.0〜1.0）
をJSON形式で返してください。
          `,
        },
      ],
    }),
  });

  const aiResult = await aiResponse.json();
  const suggestion = JSON.parse(aiResult.content[0].text);

  return new Response(JSON.stringify(suggestion), {
    headers: { 'Content-Type': 'application/json' },
  });
});
```

### 3. 提案の優先順位付け

```dart
class SuggestionPrioritizer {
  /// 複数の提案を優先順位付け
  List<ScheduleSuggestion> prioritize(List<ScheduleSuggestion> suggestions) {
    return suggestions
      ..sort((a, b) {
        // 1. 信頼度スコアが高い順
        final scoreCompare = b.confidenceScore.compareTo(a.confidenceScore);
        if (scoreCompare != 0) return scoreCompare;

        // 2. 期限が近い順
        final deadlineCompare = (a.deadline ?? DateTime(2099))
            .compareTo(b.deadline ?? DateTime(2099));
        if (deadlineCompare != 0) return deadlineCompare;

        // 3. カテゴリの重要度
        final categoryPriority = {
          'starlist_post': 3,
          'fan_event': 2,
          'task': 1,
        };
        return (categoryPriority[b.category] ?? 0)
            .compareTo(categoryPriority[a.category] ?? 0);
      });
  }
}
```

---

## 🎨 UI実装

### 1. スケジュールビュー

```dart
class AiScheduleScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(schedulesProvider);
    final suggestions = ref.watch(scheduleSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('AI スケジュール')),
      body: Column(
        children: [
          // カレンダービュー
          CalendarView(schedules: schedules),

          // AI提案セクション
          Expanded(
            child: ListView(
              children: [
                _buildSuggestionSection('💡 今日の提案', suggestions.today),
                _buildSuggestionSection('📅 今週の提案', suggestions.thisWeek),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _syncWithGoogleCalendar(),
        child: Icon(Icons.sync),
      ),
    );
  }

  Widget _buildSuggestionSection(String title, List<ScheduleSuggestion> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(title, style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          )),
        ),
        ...items.map((suggestion) => ScheduleSuggestionCard(
          suggestion: suggestion,
          onAccept: () => _acceptSuggestion(suggestion),
          onDismiss: () => _dismissSuggestion(suggestion),
        )),
      ],
    );
  }
}
```

### 2. 提案カード

```dart
class ScheduleSuggestionCard extends StatelessWidget {
  final ScheduleSuggestion suggestion;
  final VoidCallback onAccept;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ヘッダー
            Row(
              children: [
                Icon(_getCategoryIcon(suggestion.category)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 信頼度インジケーター
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _getConfidenceColor(suggestion.confidenceScore),
                  child: Text(
                    '${(suggestion.confidenceScore * 100).toInt()}%',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // 時間
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  '${DateFormat('HH:mm').format(suggestion.suggestedTime)} (${suggestion.duration}分)',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 8),

            // 理由
            Text(
              suggestion.reason,
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 16),

            // アクションボタン
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: Text('却下'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccept,
                  child: Text('承認'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🔔 通知・リマインダー

### 1. Firebase Cloud Messaging 連携

```dart
class ScheduleNotificationService {
  /// スケジュール30分前に通知
  Future<void> scheduleReminder(Schedule event) async {
    final notificationTime = event.startTime.subtract(Duration(minutes: 30));

    await FirebaseMessaging.instance.scheduleNotification(
      id: event.id.hashCode,
      title: '間もなく: ${event.title}',
      body: '${DateFormat('HH:mm').format(event.startTime)}から開始します',
      scheduledTime: notificationTime,
      payload: jsonEncode({'event_id': event.id}),
    );
  }

  /// AI提案の通知
  Future<void> notifySuggestion(ScheduleSuggestion suggestion) async {
    await FirebaseMessaging.instance.sendNotification(
      title: '💡 AI秘書からの提案',
      body: suggestion.title,
      data: {'suggestion_id': suggestion.id},
    );
  }
}
```

---

## 📊 分析ダッシュボード

### 1. スケジュール効率分析

```dart
class ScheduleEfficiencyAnalyzer {
  /// スケジュールの効率性を分析
  Future<EfficiencyReport> analyzeEfficiency(String userId) async {
    final schedules = await _getSchedules(userId, days: 30);
    final completedTasks = await _getCompletedTasks(userId, days: 30);

    return EfficiencyReport(
      // 空き時間の活用率
      freeTimeUtilization: _calculateFreeTimeUtilization(schedules),
      // タスク完了率
      taskCompletionRate: completedTasks.length / schedules.length,
      // カテゴリ別時間配分
      categoryDistribution: _analyzeCategoryDistribution(schedules),
      // AI提案の採用率
      suggestionAcceptanceRate: await _getSuggestionAcceptanceRate(userId),
    );
  }
}
```

### 2. ダッシュボードUI

```dart
class ScheduleEfficiencyDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final report = ref.watch(efficiencyReportProvider);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📊 スケジュール効率分析', style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
            SizedBox(height: 20),

            // 空き時間活用率
            _buildMetric(
              icon: Icons.trending_up,
              label: '空き時間活用率',
              value: '${(report.freeTimeUtilization * 100).toInt()}%',
              color: Colors.green,
            ),

            // タスク完了率
            _buildMetric(
              icon: Icons.check_circle,
              label: 'タスク完了率',
              value: '${(report.taskCompletionRate * 100).toInt()}%',
              color: Colors.blue,
            ),

            // AI提案採用率
            _buildMetric(
              icon: Icons.lightbulb,
              label: 'AI提案採用率',
              value: '${(report.suggestionAcceptanceRate * 100).toInt()}%',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 STARLIST統合ポイント

### 1. スターダッシュボード統合

```dart
class StarDashboardScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          // AI秘書サマリー
          AiSecretarySummaryCard(),

          // スケジュール提案
          AiScheduleSuggestionSection(),

          // 活動データカード（Notionライク）
          DataCard(
            title: '今週の視聴データ',
            category: 'viewing',
            content: ViewingDataWidget(),
          ),

          DataCard(
            title: '投稿予定',
            category: 'post',
            content: PostScheduleWidget(),
          ),

          // 効率分析
          ScheduleEfficiencyDashboard(),
        ],
      ),
    );
  }
}
```

### 2. ファン購読機能

```dart
class FanStarScheduleSubscription extends ConsumerWidget {
  final String starId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscribed = ref.watch(starScheduleSubscriptionProvider(starId));

    return SwitchListTile(
      title: Text('スケジュール購読'),
      subtitle: Text('推しの投稿・配信予定をカレンダーに追加'),
      value: isSubscribed,
      onChanged: (value) async {
        if (value) {
          await ref.read(fanCalendarSyncProvider).syncStarEvents(
            fanId: currentUserId,
            starId: starId,
          );
        } else {
          await _unsubscribe(starId);
        }
      },
    );
  }
}
```

---

## 🧪 テスト戦略

### 1. ユニットテスト

```dart
void main() {
  group('FreeTimeDetector', () {
    test('空き時間を正しく検出', () {
      final schedules = [
        Schedule(
          startTime: DateTime(2025, 10, 15, 10, 0),
          endTime: DateTime(2025, 10, 15, 11, 0),
        ),
        Schedule(
          startTime: DateTime(2025, 10, 15, 14, 0),
          endTime: DateTime(2025, 10, 15, 15, 0),
        ),
      ];

      final detector = FreeTimeDetector();
      final freeSlots = detector.detectFreeSlots(
        schedules: schedules,
        startDate: DateTime(2025, 10, 15, 9, 0),
        endDate: DateTime(2025, 10, 15, 18, 0),
      );

      expect(freeSlots.length, 3); // 9-10, 11-14, 15-18
      expect(freeSlots[0].start.hour, 9);
      expect(freeSlots[1].duration.inHours, 3);
    });
  });
}
```

### 2. 統合テスト

```dart
void main() {
  testWidgets('AI提案を承認するとカレンダーに追加される', (tester) async {
    await tester.pumpWidget(MyApp());

    // 提案カードを探す
    final suggestionCard = find.byType(ScheduleSuggestionCard);
    expect(suggestionCard, findsOneWidget);

    // 承認ボタンをタップ
    await tester.tap(find.text('承認'));
    await tester.pumpAndSettle();

    // カレンダーに追加されたか確認
    final schedule = await supabase
        .from('schedules')
        .select()
        .eq('title', 'AI提案：投稿作成')
        .single();

    expect(schedule, isNotNull);
  });
}
```

---

## 🚀 実装チェックリスト

### 基盤
- [ ] Google Calendar API 認証設定
- [ ] Supabase テーブル作成（schedules, ai_schedule_suggestions）
- [ ] Edge Function デプロイ（ai-schedule-optimizer）

### データ同期
- [ ] CalendarSyncService 実装
- [ ] RealtimeScheduleSync 実装
- [ ] FanCalendarSync 実装

### AI分析
- [ ] ActivityPatternAnalyzer 実装
- [ ] OptimalPostTimePredictor 実装
- [ ] SuggestionPrioritizer 実装

### UI
- [ ] AiScheduleScreen 実装
- [ ] ScheduleSuggestionCard 実装
- [ ] ScheduleEfficiencyDashboard 実装

### 通知
- [ ] ScheduleNotificationService 実装
- [ ] Firebase Cloud Messaging 設定
- [ ] プッシュ通知テスト

### テスト
- [ ] ユニットテスト（カバレッジ80%以上）
- [ ] 統合テスト
- [ ] E2Eテスト（カレンダー同期フロー）

---

## 📚 次のステップ

1. **ai_content_advisor.md** の作成（投稿提案AIの詳細設計）
2. **ai_data_bridge.md** の作成（MCP接続技術詳細）
3. **PoC実装開始**（スター向けスケジュール最適化）

---

**作成日**: 2025年10月15日  
**最終更新**: 2025年10月15日  
**バージョン**: 1.0.0  
**担当**: AI開発チーム（ティム＋マイン＋Claude）

