import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

@immutable
class SnsLinkState {
  final String xUsername;
  final String instagramUsername;
  final String youtubeUrl;
  final String tiktokUsername;
  final String websiteUrl;

  const SnsLinkState({
    this.xUsername = '',
    this.instagramUsername = '',
    this.youtubeUrl = '',
    this.tiktokUsername = '',
    this.websiteUrl = '',
  });

  SnsLinkState copyWith({
    String? xUsername,
    String? instagramUsername,
    String? youtubeUrl,
    String? tiktokUsername,
    String? websiteUrl,
  }) {
    return SnsLinkState(
      xUsername: xUsername ?? this.xUsername,
      instagramUsername: instagramUsername ?? this.instagramUsername,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      tiktokUsername: tiktokUsername ?? this.tiktokUsername,
      websiteUrl: websiteUrl ?? this.websiteUrl,
    );
  }
}

class SnsLinkNotifier extends StateNotifier<SnsLinkState> {
  SnsLinkNotifier() : super(const SnsLinkState());

  void updateX(String value) => state = state.copyWith(xUsername: value);
  void updateInstagram(String value) => state = state.copyWith(instagramUsername: value);
  void updateYoutube(String value) => state = state.copyWith(youtubeUrl: value);
  void updateTiktok(String value) => state = state.copyWith(tiktokUsername: value);
  void updateWebsite(String value) => state = state.copyWith(websiteUrl: value);
}

final snsLinkProvider = StateNotifierProvider<SnsLinkNotifier, SnsLinkState>((ref) {
  return SnsLinkNotifier();
}); 