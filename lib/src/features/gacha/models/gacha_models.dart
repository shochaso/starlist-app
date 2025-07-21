import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'gacha_models.freezed.dart';

/// ガチャの結果を表すクラス
@freezed
class GachaResult with _$GachaResult {
  /// ポイント獲得
  const factory GachaResult.point({
    required int amount,
  }) = PointResult;

  /// チケット獲得
  const factory GachaResult.ticket({
    required String ticketType,
    required String displayName,
    @JsonKey(ignore: true) required Color color,
  }) = TicketResult;
}

/// ガチャの状態を表すクラス
@freezed
class GachaState with _$GachaState {
  /// 初期状態
  const factory GachaState.initial() = _Initial;

  /// ガチャ実行中（アニメーション表示）
  const factory GachaState.loading() = _Loading;

  /// ガチャ成功（結果表示）
  const factory GachaState.success(GachaResult result) = _Success;

  /// エラー状態
  const factory GachaState.error(String message) = _Error;
}