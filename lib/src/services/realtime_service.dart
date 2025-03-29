import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// リアルタイムイベントのタイプ
enum RealtimeEventType {
  insert,
  update,
  delete,
}

/// リアルタイムイベントモデル
class RealtimeEvent<T> {
  final RealtimeEventType eventType;
  final T? data;
  final String table;
  
  RealtimeEvent({
    required this.eventType,
    this.data,
    required this.table,
  });
}

/// リアルタイムデータの変換関数の型定義
typedef DataConverter<T> = T Function(Map<String, dynamic> json);

/// ユーザープレゼンスの状態
class UserPresence {
  final String userId;
  final DateTime onlineAt;
  final Map<String, dynamic>? userInfo;
  
  UserPresence({
    required this.userId,
    required this.onlineAt,
    this.userInfo,
  });
  
  factory UserPresence.fromJson(Map<String, dynamic> json) {
    return UserPresence(
      userId: json['user_id'],
      onlineAt: DateTime.parse(json['online_at']),
      userInfo: json['user_info'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'online_at': onlineAt.toIso8601String(),
      'user_info': userInfo,
    };
  }
}

/// Supabaseリアルタイム更新サービス
class RealtimeService {
  final SupabaseClient _client;
  final Map<String, StreamController<RealtimeEvent>> _controllers = {};
  final Map<String, RealtimeChannel> _channels = {};
  final Map<String, StreamController<List<UserPresence>>> _presenceControllers = {};
  
  RealtimeService(this._client);
  
  /// テーブルの変更をリアルタイムでリッスンする
  /// 
  /// [table] リッスンするテーブル名
  /// [primaryKey] データの主キー（通常は 'id'）
  /// [converter] JSONからモデルへの変換関数
  /// [filter] フィルタリング条件（PostgreSQLのWHERE句）
  Stream<RealtimeEvent<T>> listenToTable<T>({
    required String table,
    required String primaryKey,
    required DataConverter<T> converter,
    String? filter,
  }) {
    // 固有のチャンネル名を生成
    final channelName = 'public:$table${filter != null ? ':$filter' : ''}';
    
    // 既存のチャンネルがあればそれを再利用
    if (_controllers.containsKey(channelName)) {
      return _controllers[channelName]!.stream as Stream<RealtimeEvent<T>>;
    }
    
    // 新しいStreamControllerを作成
    final controller = StreamController<RealtimeEvent<T>>.broadcast();
    
    // StreamControllerが閉じられたときのクリーンアップ
    controller.onCancel = () {
      if (!controller.hasListener) {
        _controllers.remove(channelName);
        _channels[channelName]?.unsubscribe();
        _channels.remove(channelName);
        controller.close();
      }
    };
    
    _controllers[channelName] = controller as StreamController<RealtimeEvent>;
    
    // リアルタイムチャンネルを作成
    final channel = _client.channel(channelName);
    
    // テーブル変更をサブスクライブ
    channel
      .on(
        RealtimeListenTypes.postgresChanges,
        ChannelFilter(
          event: '*',
          schema: 'public',
          table: table,
          filter: filter,
        ),
        (payload, [ref]) {
          try {
            final eventTypeStr = payload['eventType'] as String;
            RealtimeEventType eventType;
            
            switch (eventTypeStr) {
              case 'INSERT':
                eventType = RealtimeEventType.insert;
                break;
              case 'UPDATE':
                eventType = RealtimeEventType.update;
                break;
              case 'DELETE':
                eventType = RealtimeEventType.delete;
                break;
              default:
                debugPrint('不明なイベントタイプ: $eventTypeStr');
                return;
            }
            
            // payloadからデータを取得してモデルに変換
            final newData = payload['new'] as Map<String, dynamic>?;
            final oldData = payload['old'] as Map<String, dynamic>?;
            
            // 削除イベントの場合はoldからデータを取得
            final data = eventType == RealtimeEventType.delete
                ? (oldData != null ? converter(oldData) : null)
                : (newData != null ? converter(newData) : null);
            
            // イベントをストリームに流す
            controller.add(RealtimeEvent<T>(
              eventType: eventType,
              data: data,
              table: table,
            ));
          } catch (e) {
            debugPrint('リアルタイムイベントの処理中にエラーが発生しました: $e');
          }
        },
      )
      .subscribe();
    
    _channels[channelName] = channel;
    
    return controller.stream;
  }
  
  /// 特定のユーザーをフォローしているユーザー向けのリアルタイム更新
  /// 
  /// [userId] フォローされているユーザーID
  /// [tableName] 監視するテーブル名
  /// [converter] JSONからモデルへの変換関数
  Stream<RealtimeEvent<T>> listenToUserUpdates<T>({
    required String userId,
    required String tableName,
    required DataConverter<T> converter,
  }) {
    return listenToTable<T>(
      table: tableName,
      primaryKey: 'id',
      converter: converter,
      filter: 'user_id=eq.$userId',
    );
  }
  
  /// コメントのリアルタイム更新
  /// 
  /// [contentId] コンテンツID
  /// [converter] JSONからコメントモデルへの変換関数
  Stream<RealtimeEvent<T>> listenToComments<T>({
    required String contentId,
    required DataConverter<T> converter,
  }) {
    return listenToTable<T>(
      table: 'comments',
      primaryKey: 'id',
      converter: converter,
      filter: 'content_id=eq.$contentId',
    );
  }
  
  /// フォロー関係のリアルタイム更新
  /// 
  /// [userId] ユーザーID
  /// [converter] JSONからフォローモデルへの変換関数
  Stream<RealtimeEvent<T>> listenToFollows<T>({
    required String userId,
    required DataConverter<T> converter,
  }) {
    return listenToTable<T>(
      table: 'follows',
      primaryKey: 'id',
      converter: converter,
      filter: 'followed_id=eq.$userId',
    );
  }
  
  /// チャンネルプレゼンス機能（オンラインユーザー）
  /// 
  /// [roomId] 部屋やグループのID
  /// [userId] 現在のユーザーID
  /// [userInfo] ユーザーに関する追加情報
  Stream<List<UserPresence>> joinRoom({
    required String roomId,
    required String userId,
    Map<String, dynamic>? userInfo,
  }) {
    final channelName = 'presence:$roomId';
    
    // 既存のコントローラーがあればそれを再利用
    if (_presenceControllers.containsKey(channelName)) {
      return _presenceControllers[channelName]!.stream;
    }
    
    // 新しいStreamControllerを作成
    final controller = StreamController<List<UserPresence>>.broadcast();
    
    // StreamControllerが閉じられたときのクリーンアップ
    controller.onCancel = () {
      if (!controller.hasListener) {
        _presenceControllers.remove(channelName);
        _channels[channelName]?.unsubscribe();
        _channels.remove(channelName);
        controller.close();
      }
    };
    
    _presenceControllers[channelName] = controller;
    
    // プレゼンスチャンネルを作成
    final channel = _client.channel(channelName);
    
    // プレゼンスの変更をサブスクライブ
    channel.on(RealtimeListenTypes.presence, ChannelFilter(event: 'sync'), (payload, [ref]) {
      try {
        final joins = payload['joins'] as Map<String, dynamic>?;
        final leaves = payload['leaves'] as Map<String, dynamic>?;
        
        // 現在のオンラインユーザーリストを更新
        final onlineUsers = <UserPresence>[];
        
        // 参加または更新されたユーザーを追加
        if (joins != null) {
          for (final entry in joins.entries) {
            final presenceData = entry.value as Map<String, dynamic>;
            onlineUsers.add(UserPresence(
              userId: presenceData['user_id'],
              onlineAt: DateTime.parse(presenceData['online_at']),
              userInfo: presenceData['user_info'],
            ));
          }
        }
        
        // 離脱したユーザーの情報は含まれない
        
        // 更新されたリストをストリームに流す
        controller.add(onlineUsers);
      } catch (e) {
        debugPrint('プレゼンスイベントの処理中にエラーが発生しました: $e');
      }
    }).subscribe(
      (status, [error]) async {
        if (status == 'SUBSCRIBED') {
          // 自分自身をプレゼンスに追加
          await channel.track({
            'user_id': userId,
            'online_at': DateTime.now().toIso8601String(),
            'user_info': userInfo,
          });
        }
      },
    );
    
    _channels[channelName] = channel;
    
    return controller.stream;
  }
  
  /// チャンネルからの退室
  Future<void> leaveRoom(String roomId) async {
    final channelName = 'presence:$roomId';
    final channel = _channels[channelName];
    
    if (channel != null) {
      try {
        await channel.untrack();
        await channel.unsubscribe();
        _channels.remove(channelName);
      } catch (e) {
        debugPrint('ルームからの退出に失敗しました: $e');
      }
    }
  }
  
  /// すべてのチャンネルをクリーンアップ
  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
    
    for (final controller in _presenceControllers.values) {
      controller.close();
    }
    
    for (final channel in _channels.values) {
      channel.unsubscribe();
    }
    
    _controllers.clear();
    _presenceControllers.clear();
    _channels.clear();
  }
} 