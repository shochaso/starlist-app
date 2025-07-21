import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// ガチャの音効果とハプティックフィードバックを管理するサービス
class GachaSoundService {
  static final GachaSoundService _instance = GachaSoundService._internal();
  factory GachaSoundService() => _instance;
  GachaSoundService._internal();

  /// レバーを引く時の効果音とバイブレーション
  Future<void> playLeverPull() async {
    if (!kIsWeb) {
      // モバイルの場合のみハプティックフィードバック
      await HapticFeedback.mediumImpact();
    }
    
    // Webでは音効果のAPIを使用（実装例）
    if (kIsWeb) {
      _playWebSound('lever_pull');
    }
  }

  /// マシンが動作する時の効果音とバイブレーション
  Future<void> playMachineOperation() async {
    if (!kIsWeb) {
      await HapticFeedback.heavyImpact();
      
      // 連続的な振動パターン
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.lightImpact();
    }
    
    if (kIsWeb) {
      _playWebSound('machine_operation');
    }
  }

  /// カプセルが落ちる時の効果音
  Future<void> playCapsuleDrop() async {
    if (!kIsWeb) {
      await HapticFeedback.lightImpact();
    }
    
    if (kIsWeb) {
      _playWebSound('capsule_drop');
    }
  }

  /// カプセルが開く時の効果音
  Future<void> playCapsuleOpen() async {
    if (!kIsWeb) {
      await HapticFeedback.selectionClick();
    }
    
    if (kIsWeb) {
      _playWebSound('capsule_open');
    }
  }

  /// 結果発表時の効果音とバイブレーション
  Future<void> playResultReveal() async {
    if (!kIsWeb) {
      // 成功時の特別な振動パターン
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 150));
      await HapticFeedback.lightImpact();
    }
    
    if (kIsWeb) {
      _playWebSound('result_reveal');
    }
  }

  /// お祝い時の効果音
  Future<void> playCelebration() async {
    if (kIsWeb) {
      _playWebSound('celebration');
    }
  }

  /// Web用の音効果再生（実装例）
  void _playWebSound(String soundType) {
    // Web Audio API を使用した音効果の実装
    // 実際の実装では適切な音声ファイルを用意し、
    // Web Audio API または HTML5 Audio を使用して再生する
    
    if (kDebugMode) {
      print('Playing web sound: $soundType');
    }
    
    // 実装例：HTMLの audio 要素を使用
    // final audio = html.AudioElement();
    // audio.src = 'assets/sounds/$soundType.mp3';
    // audio.play();
  }

  /// ガチャ全体の音効果シーケンス
  Future<void> playGachaSequence() async {
    // レバーを引く
    await playLeverPull();
    await Future.delayed(const Duration(milliseconds: 500));
    
    // マシン動作
    await playMachineOperation();
    await Future.delayed(const Duration(milliseconds: 800));
    
    // カプセル落下
    await playCapsuleDrop();
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // カプセル開封
    await playCapsuleOpen();
    await Future.delayed(const Duration(milliseconds: 600));
    
    // 結果発表
    await playResultReveal();
    await Future.delayed(const Duration(milliseconds: 800));
    
    // お祝い
    await playCelebration();
  }

  /// 設定に基づく音効果の有効/無効切り替え
  bool _soundEnabled = true;
  bool _hapticEnabled = true;

  bool get soundEnabled => _soundEnabled;
  bool get hapticEnabled => _hapticEnabled;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setHapticEnabled(bool enabled) {
    _hapticEnabled = enabled;
  }
}

/// ガチャ音効果の種類
enum GachaSoundType {
  leverPull('lever_pull'),
  machineOperation('machine_operation'),
  capsuleDrop('capsule_drop'),
  capsuleOpen('capsule_open'),
  resultReveal('result_reveal'),
  celebration('celebration');

  const GachaSoundType(this.fileName);
  final String fileName;
}