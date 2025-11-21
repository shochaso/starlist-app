class EnrichedLinkResult {
  const EnrichedLinkResult({
    required this.url,
    required this.score,
    required this.reason,
    this.thumbnailUrl,
    this.channelTitle,
  });

  factory EnrichedLinkResult.empty(String reason) => EnrichedLinkResult(
        url: null,
        score: 0,
        reason: reason,
      );

  final String? url;
  final double? score;
  final String? reason;
  final String? thumbnailUrl;
  final String? channelTitle;

  EnrichedLinkResult copyWith({
    String? url,
    double? score,
    String? reason,
    String? thumbnailUrl,
    String? channelTitle,
  }) {
    return EnrichedLinkResult(
      url: url ?? this.url,
      score: score ?? this.score,
      reason: reason ?? this.reason,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      channelTitle: channelTitle ?? this.channelTitle,
    );
  }
}
