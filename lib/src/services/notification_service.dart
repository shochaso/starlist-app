import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';

/// 通知の種類
enum NotificationType {
  newContent,      // 新しいコンテンツ
  newComment,      // 新しいコメント
  newFollower,     // 新しいフォロワー
  contentLiked,    // コンテンツがいいねされた
  commentLiked,    // コメントがいいねされた
  system,          // システム通知
}

/// 通知データモデル
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final bool isRead;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    required this.createdAt,
    this.isRead = false,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type']}',
        orElse: () => NotificationType.system,
      ),
      data: json['data'],
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] ?? false,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString().split('.').last,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
    };
  }
  
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}

/// 通知サービスクラス
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<NotificationModel?> _notificationSubject = BehaviorSubject<NotificationModel?>();
  
  Stream<NotificationModel?> get notificationStream => _notificationSubject.stream;
  
  NotificationService._internal();
  
  /// 通知サービスの初期化
  Future<void> init() async {
    debugPrint('通知サービスの初期化を開始します...');
    try {
      if (kIsWeb) {
        await _webInitialize();
      } else {
        await _nativeInitialize();
      }
      debugPrint('通知サービスの初期化が完了しました');
    } catch (e) {
      debugPrint('通知サービスの初期化時にエラーが発生しました: $e');
      // エラーが発生しても最低限の機能は提供する
    }
  }
  
  // Web環境用の初期化
  Future<void> _webInitialize() async {
    try {
      debugPrint('Web環境用の通知サービスを初期化します');
      // Web環境ではFirebaseMessagingを使用せず、シンプルな通知のみを実装
      
      // 通知イベントをシミュレートするためのダミーデータ（開発用）
      Future.delayed(const Duration(seconds: 2), () {
        debugPrint('Webデモ通知を発行します');
        _notificationSubject.add(NotificationModel(
          id: 'web-notification-1',
          title: 'Webアプリへようこそ',
          body: 'このブラウザ版ではプッシュ通知の代わりにこのメッセージが表示されます',
          type: NotificationType.system,
          createdAt: DateTime.now(),
        ));
      });
    } catch (e) {
      debugPrint('Web環境での通知サービスの初期化に失敗しました: $e');
    }
  }
  
  // ネイティブ環境用の初期化
  Future<void> _nativeInitialize() async {
    try {
      // Firebaseの初期化を確認
      await Firebase.initializeApp();
      
      // Firebase Messagingのインスタンスを取得
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      
      // iOS用の通知許可設定
      if (Platform.isIOS) {
        await firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      // FCMトークンの取得とログ出力（デバッグ用）
      final fcmToken = await firebaseMessaging.getToken();
      debugPrint('FCM Token: $fcmToken');
      
      // ローカル通知の初期化
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      final iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final initSettings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
      
      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
      
      // バックグラウンドメッセージハンドラの設定
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // フォアグラウンドメッセージハンドラの設定
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      
      // 通知タップ時のハンドラの設定
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      // 起動時に通知からアプリが開かれた場合の処理
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('ネイティブ環境での通知サービスの初期化に失敗しました: $e');
      // エラーが発生した場合でも最低限の機能は提供する
      // ローカル通知だけでも設定を試みる
      try {
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        final iOSSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        final initSettings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
        
        await _flutterLocalNotificationsPlugin.initialize(
          initSettings,
          onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
        );
      } catch (e) {
        debugPrint('ローカル通知の初期化にも失敗しました: $e');
      }
    }
  }
  
  // ローカル通知タップ時の処理
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    if (response.payload != null) {
      final data = json.decode(response.payload!);
      final notification = NotificationModel(
        id: response.id.toString(),
        title: data['title'] ?? '',
        body: data['body'] ?? '',
        type: NotificationType.values.firstWhere(
          (e) => e.toString() == 'NotificationType.${data['type']}',
          orElse: () => NotificationType.system,
        ),
        data: data,
        createdAt: DateTime.now(),
      );
      _notificationSubject.add(notification);
    }
  }
  
  // フォアグラウンドでのメッセージ受信時の処理
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = _convertMessageToNotification(message);
    _showLocalNotification(notification);
    _notificationSubject.add(notification);
  }
  
  // アプリがバックグラウンドで通知がタップされた場合の処理
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    final notification = _convertMessageToNotification(message);
    _notificationSubject.add(notification);
  }
  
  // アプリが起動されていない状態で通知がタップされた場合の処理
  Future<void> _handleInitialMessage(RemoteMessage message) async {
    final notification = _convertMessageToNotification(message);
    _notificationSubject.add(notification);
  }
  
  // FCMメッセージを通知モデルに変換
  NotificationModel _convertMessageToNotification(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    
    // 通知の種類を判定
    NotificationType type = NotificationType.system;
    if (data.containsKey('type')) {
      try {
        type = NotificationType.values.firstWhere(
          (e) => e.toString() == 'NotificationType.${data['type']}',
          orElse: () => NotificationType.system,
        );
      } catch (e) {
        debugPrint('通知タイプの変換に失敗しました: $e');
      }
    }
    
    return NotificationModel(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification?.title ?? data['title'] ?? 'Starlist',
      body: notification?.body ?? data['body'] ?? '',
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
  }
  
  // ローカル通知を表示
  Future<void> _showLocalNotification(NotificationModel notification) async {
    // プラットフォームチェックを追加
    if (kIsWeb) {
      // Web環境ではローカル通知はサポートされていないので何もしない
      debugPrint('Web環境ではローカル通知は表示されません: ${notification.title}');
      return;
    }
    
    try {
      const androidDetails = AndroidNotificationDetails(
        'starlist_channel',
        'Starlist Notifications',
        channelDescription: 'Notifications from Starlist app',
        importance: Importance.high,
        priority: Priority.high,
      );
      
      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );
      
      await _flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        notificationDetails,
        payload: json.encode(notification.toJson()),
      );
    } catch (e) {
      debugPrint('ローカル通知の表示に失敗しました: $e');
    }
  }
  
  // 通知を発行（アプリ内で直接通知を表示する場合に使用）
  void showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.system,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    );
    
    if (!kIsWeb) {
      _showLocalNotification(notification);
    }
    
    _notificationSubject.add(notification);
  }
  
  // トピックへのサブスクライブ（例: 特定のユーザーの更新通知）
  Future<void> subscribeToTopic(String topic) async {
    if (kIsWeb) {
      debugPrint('Web環境ではトピックへのサブスクライブはサポートされていません: $topic');
      return;
    }
    
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
      debugPrint('トピックへのサブスクライブが完了しました: $topic');
    } catch (e) {
      debugPrint('トピックへのサブスクライブに失敗しました: $e');
    }
  }
  
  // トピックからのサブスクライブ解除
  Future<void> unsubscribeFromTopic(String topic) async {
    if (kIsWeb) {
      debugPrint('Web環境ではトピックからのサブスクライブ解除はサポートされていません: $topic');
      return;
    }
    
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      debugPrint('トピックからのサブスクライブ解除が完了しました: $topic');
    } catch (e) {
      debugPrint('トピックからのサブスクライブ解除に失敗しました: $e');
    }
  }
}

// バックグラウンドで通知を受け取った時の処理
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // この関数は別のIsolateで実行されるので、アプリのグローバル状態にアクセスできません
  // FCMメッセージの保存や最小限の処理だけを行い、起動時に完全に処理するのがベストプラクティス
  try {
    await Firebase.initializeApp();
    debugPrint('バックグラウンドメッセージを受信しました: ${message.messageId}');
  } catch (e) {
    debugPrint('バックグラウンドメッセージの処理に失敗しました: $e');
  }
} 
