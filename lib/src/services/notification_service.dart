import 'package:flutter/foundation.dart';
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
  
  const NotificationModel({
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
  final BehaviorSubject<NotificationModel?> _subject = BehaviorSubject<NotificationModel?>();
  Stream<NotificationModel?> get notificationStream => _subject.stream;
  NotificationService._internal();
  
  Future<void> init() async {
      if (kIsWeb) {
      Future.delayed(const Duration(seconds: 1), () {
        _subject.add(NotificationModel(
          id: 'web-hello',
          title: 'Starlist Web',
          body: 'Webではブラウザ通知の代わりにメッセージを表示します',
          type: NotificationType.system,
          createdAt: DateTime.now(),
        ));
      });
    }
  }

  void showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.system,
    Map<String, dynamic>? data,
  }) {
    _subject.add(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data,
      createdAt: DateTime.now(),
    ));
  }
} 
