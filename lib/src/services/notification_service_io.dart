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

/// 通知サービスクラス（IO実装）
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
      await _nativeInitialize();
      debugPrint('通知サービスの初期化が完了しました');
    } catch (e) {
      debugPrint('通知サービスの初期化時にエラーが発生しました: $e');
    }
  }
  
  // ネイティブ環境用の初期化
  Future<void> _nativeInitialize() async {
    try {
      await Firebase.initializeApp();
      final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
      
      if (Platform.isIOS) {
        await firebaseMessaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      
      final fcmToken = await firebaseMessaging.getToken();
      debugPrint('FCM Token: $fcmToken');
      
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iOSSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      final initSettings = InitializationSettings(android: androidSettings, iOS: iOSSettings);
      
      await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );
      
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      
      final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }
    } catch (e) {
      debugPrint('ネイティブ環境での通知サービスの初期化に失敗しました: $e');
      try {
        const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
        const iOSSettings = DarwinInitializationSettings(
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
  
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = _convertMessageToNotification(message);
    _showLocalNotification(notification);
    _notificationSubject.add(notification);
  }
  
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    final notification = _convertMessageToNotification(message);
    _notificationSubject.add(notification);
  }
  
  Future<void> _handleInitialMessage(RemoteMessage message) async {
    final notification = _convertMessageToNotification(message);
    _notificationSubject.add(notification);
  }
  
  NotificationModel _convertMessageToNotification(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;
    
    NotificationType type = NotificationType.system;
    if (data.containsKey('type')) {
      try {
        type = NotificationType.values.firstWhere(
          (e) => e.toString() == 'NotificationType.${data['type']}',
          orElse: () => NotificationType.system,
        );
      } catch (_) {}
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
  
  Future<void> _showLocalNotification(NotificationModel notification) async {
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
    _showLocalNotification(notification);
    _notificationSubject.add(notification);
  }
  
  Future<void> subscribeToTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(topic);
    } catch (e) {
      debugPrint('subscribeToTopic error: $e');
    }
  }
  
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    } catch (e) {
      debugPrint('unsubscribeFromTopic error: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('バックグラウンドメッセージ: ${message.messageId}');
  } catch (e) {
    debugPrint('バックグラウンドメッセージ処理失敗: $e');
  }
} 