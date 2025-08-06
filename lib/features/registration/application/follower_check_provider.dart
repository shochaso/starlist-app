import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// SNSの種類を定義
enum SnsType { x, instagram, youtube, tiktok, twitch, other }

@immutable
class FollowerCheckState {
  final Map<SnsType, int> followerCounts;
  final int totalFollowers;
  final int reachedTier;
  final String feedbackMessage;
  final Color tierColor;
  final bool isTierJustReached;

  const FollowerCheckState({
    this.followerCounts = const {},
    this.totalFollowers = 0,
    this.reachedTier = 0,
    this.feedbackMessage = '目標まであと 1,000 人',
    this.tierColor = Colors.grey,
    this.isTierJustReached = false,
  });

  FollowerCheckState copyWith({
    Map<SnsType, int>? followerCounts,
    int? totalFollowers,
    int? reachedTier,
    String? feedbackMessage,
    Color? tierColor,
    bool? isTierJustReached,
  }) {
    return FollowerCheckState(
      followerCounts: followerCounts ?? this.followerCounts,
      totalFollowers: totalFollowers ?? this.totalFollowers,
      reachedTier: reachedTier ?? this.reachedTier,
      feedbackMessage: feedbackMessage ?? this.feedbackMessage,
      tierColor: tierColor ?? this.tierColor,
      isTierJustReached: isTierJustReached ?? this.isTierJustReached,
    );
  }
}

class FollowerCheckNotifier extends StateNotifier<FollowerCheckState> {
  FollowerCheckNotifier() : super(const FollowerCheckState());

  void updateFollowerCount(SnsType sns, int count) {
    final newCounts = Map<SnsType, int>.from(state.followerCounts);
    newCounts[sns] = count;

    final previousTier = state.reachedTier;
    final newTotal = newCounts.values.fold(0, (sum, item) => sum + item);

    int newTier = 0;
    String newMessage = '';
    Color newColor = Colors.grey;

    if (newTotal >= 1000000) {
      newTier = 1000000;
      newMessage = 'メガスター！圧倒的な存在感です！';
      newColor = const Color(0xFF8A2BE2); // Purple for gradient start
    } else if (newTotal >= 100000) {
      newTier = 100000;
      newMessage = 'スーパースターの誕生です！';
      newColor = const Color(0xFF8A2BE2); // Purple
    } else if (newTotal >= 10000) {
      newTier = 10000;
      newMessage = 'ゴールドスター級の輝きです！';
      newColor = const Color(0xFFFFD700); // Gold
    } else if (newTotal >= 1000) {
      newTier = 1000;
      newMessage = '素晴らしい！Starlistへようこそ！';
      newColor = const Color(0xFF34C759); // Green
    } else {
      newTier = 0;
      final remaining = 1000 - newTotal;
      newMessage = '目標まであと ${remaining.toStringAsFixed(0)} 人';
      newColor = Colors.grey[400]!;
    }
    
    // Check if a new tier was just reached
    final tierJustReached = newTier > previousTier;

    state = state.copyWith(
      followerCounts: newCounts,
      totalFollowers: newTotal,
      reachedTier: newTier,
      feedbackMessage: newMessage,
      tierColor: newColor,
      isTierJustReached: tierJustReached,
    );
  }

  void confettiAnimationCompleted() {
    state = state.copyWith(isTierJustReached: false);
  }
}

final followerCheckProvider =
    StateNotifierProvider<FollowerCheckNotifier, FollowerCheckState>((ref) {
  return FollowerCheckNotifier();
}); 