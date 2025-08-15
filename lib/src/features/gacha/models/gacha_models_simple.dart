import 'package:flutter/material.dart';

/// ガチャの結果を表すクラス（Freezed無し版）
abstract class GachaResult {
  const GachaResult();
  
  T when<T>({
    required T Function(int amount) point,
    required T Function(String ticketType, String displayName, Color color) ticket,
  });
}

/// ポイント獲得結果
class PointResult extends GachaResult {
  final int amount;
  
  const PointResult({required this.amount});
  
  @override
  T when<T>({
    required T Function(int amount) point,
    required T Function(String ticketType, String displayName, Color color) ticket,
  }) {
    return point(amount);
  }
}

/// チケット獲得結果
class TicketResult extends GachaResult {
  final String ticketType;
  final String displayName;
  final Color color;
  
  const TicketResult({
    required this.ticketType,
    required this.displayName,
    required this.color,
  });
  
  @override
  T when<T>({
    required T Function(int amount) point,
    required T Function(String ticketType, String displayName, Color color) ticket,
  }) {
    return ticket(ticketType, displayName, color);
  }
}

/// ガチャの状態を表すクラス（Freezed無し版）
abstract class GachaState {
  const GachaState();
  
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(GachaResult result, int previousBalance, int newBalance) success,
    required T Function(String message) error,
  });
}

/// 初期状態
class _Initial extends GachaState {
  const _Initial();
  
  @override
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(GachaResult result, int previousBalance, int newBalance) success,
    required T Function(String message) error,
  }) {
    return initial();
  }
}

/// ローディング状態
class _Loading extends GachaState {
  const _Loading();
  
  @override
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(GachaResult result, int previousBalance, int newBalance) success,
    required T Function(String message) error,
  }) {
    return loading();
  }
}

/// 成功状態
class _Success extends GachaState {
  final GachaResult result;
  final int previousBalance;
  final int newBalance;
  
  const _Success(this.result, this.previousBalance, this.newBalance);
  
  @override
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(GachaResult result, int previousBalance, int newBalance) success,
    required T Function(String message) error,
  }) {
    return success(result, previousBalance, newBalance);
  }
}

/// エラー状態
class _Error extends GachaState {
  final String message;
  
  const _Error(this.message);
  
  @override
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(GachaResult result, int previousBalance, int newBalance) success,
    required T Function(String message) error,
  }) {
    return error(message);
  }
}

/// ガチャ状態のファクトリーメソッド
class GachaStateFactory {
  static const GachaState initial = _Initial();
  static const GachaState loading = _Loading();
  static GachaState success(GachaResult result, int previousBalance, int newBalance) => _Success(result, previousBalance, newBalance);
  static GachaState error(String message) => _Error(message);
}