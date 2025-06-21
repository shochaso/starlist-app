import 'package:flutter/material.dart';

/// 広告を表すモデルクラス
class AdModel {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String targetUrl;
  final String advertiserName;
  final AdType type;
  final AdSize size;
  final List<String> targetUserTypes; // 表示対象のユーザータイプ（無料、スタンダードなど）
  final double cpmRate; // 1000インプレッションあたりの単価（円）
  final double cpcRate; // クリックあたりの単価（円）

  AdModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.targetUrl,
    required this.advertiserName,
    required this.type,
    required this.size,
    required this.targetUserTypes,
    required this.cpmRate,
    required this.cpcRate,
  });

  /// JSON形式のデータからAdModelオブジェクトを生成するファクトリメソッド
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      targetUrl: json['targetUrl'] ?? '',
      advertiserName: json['advertiserName'] ?? '',
      type: _parseAdType(json['type']),
      size: _parseAdSize(json['size']),
      targetUserTypes: List<String>.from(json['targetUserTypes'] ?? []),
      cpmRate: (json['cpmRate'] ?? 0.0).toDouble(),
      cpcRate: (json['cpcRate'] ?? 0.0).toDouble(),
    );
  }

  /// オブジェクトをJSON形式に変換するメソッド
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'targetUrl': targetUrl,
      'advertiserName': advertiserName,
      'type': type.toString().split('.').last,
      'size': size.toString().split('.').last,
      'targetUserTypes': targetUserTypes,
      'cpmRate': cpmRate,
      'cpcRate': cpcRate,
    };
  }

  /// 特定のユーザータイプに広告を表示すべきかどうかを判定するメソッド
  bool shouldShowToUserType(String userType) {
    return targetUserTypes.contains(userType);
  }

  /// インプレッション収益を計算するメソッド
  double calculateImpressionRevenue(int impressions) {
    return (cpmRate * impressions) / 1000;
  }

  /// クリック収益を計算するメソッド
  double calculateClickRevenue(int clicks) {
    return cpcRate * clicks;
  }

  /// 広告タイプの文字列をAdType列挙型に変換するヘルパーメソッド
  static AdType _parseAdType(String? typeStr) {
    if (typeStr == 'banner') return AdType.banner;
    if (typeStr == 'interstitial') return AdType.interstitial;
    if (typeStr == 'native') return AdType.native;
    if (typeStr == 'video') return AdType.video;
    return AdType.banner; // デフォルト
  }

  /// 広告サイズの文字列をAdSize列挙型に変換するヘルパーメソッド
  static AdSize _parseAdSize(String? sizeStr) {
    if (sizeStr == 'small') return AdSize.small;
    if (sizeStr == 'medium') return AdSize.medium;
    if (sizeStr == 'large') return AdSize.large;
    if (sizeStr == 'fullScreen') return AdSize.fullScreen;
    return AdSize.medium; // デフォルト
  }
}

/// 広告タイプの列挙型
enum AdType {
  banner,      // バナー広告
  interstitial, // 全画面広告
  native,      // ネイティブ広告
  video        // 動画広告
}

/// 広告サイズの列挙型
enum AdSize {
  small,      // 小サイズ
  medium,     // 中サイズ
  large,      // 大サイズ
  fullScreen  // 全画面
}

/// ユーザータイプの定数
class UserType {
  static const String free = 'free';           // 無料ユーザー
  static const String standard = 'standard';   // スタンダード会員
  static const String premium = 'premium';     // プレミアム会員
  static const String star = 'star';           // スター
}
