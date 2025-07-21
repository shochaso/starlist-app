import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gacha_models_simple.dart';
import '../domain/draw_gacha_usecase.dart';
import '../services/gacha_sound_service.dart';

/// ガチャのビューモデル
class GachaViewModel extends StateNotifier<GachaState> {
  final DrawGachaUsecase _drawGachaUsecase;
  final GachaSoundService _soundService;

  GachaViewModel(this._drawGachaUsecase, this._soundService) : super(GachaStateFactory.initial);

  /// ガチャを引く
  Future<void> draw() async {
    // ローディング中かどうかを別の方法でチェック
    bool isLoading = false;
    state.when(
      initial: () => isLoading = false,
      loading: () => isLoading = true,
      success: (_) => isLoading = false,
      error: (_) => isLoading = false,
    );
    
    if (isLoading) return; // 実行中は重複実行を防ぐ

    state = GachaStateFactory.loading;
    
    // ガチャの音効果シーケンスを開始
    _soundService.playGachaSequence();

    try {
      // ガチャアニメーションの時間を考慮した実行
      await Future.delayed(const Duration(milliseconds: 3500)); // アニメーション時間
      final result = await _drawGachaUsecase.execute();
      state = GachaStateFactory.success(result);
    } catch (e) {
      state = GachaStateFactory.error(e.toString());
    }
  }

  /// 状態をリセット
  void reset() {
    state = GachaStateFactory.initial;
  }
}