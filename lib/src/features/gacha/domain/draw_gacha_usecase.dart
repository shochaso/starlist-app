import '../data/gacha_repository.dart';
import '../models/gacha_models_simple.dart';

/// ガチャを引くユースケース
class DrawGachaUsecase {
  final GachaRepository _repository;

  DrawGachaUsecase(this._repository);

  Future<GachaResult> execute() async {
    try {
      return await _repository.drawGacha();
    } catch (e) {
      throw Exception('ガチャの実行に失敗しました: $e');
    }
  }
}