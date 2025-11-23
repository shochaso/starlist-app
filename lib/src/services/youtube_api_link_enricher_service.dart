import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../config/environment_config.dart';
import '../models/enriched_link_result.dart';

class YoutubeApiLinkEnricherService {
  YoutubeApiLinkEnricherService({
    http.Client? httpClient,
    String? apiKey,
  })  : _client = httpClient ?? http.Client(),
        _apiKey = apiKey ?? EnvironmentConfig.youtubeApiKey;

  final http.Client _client;
  final String _apiKey;

  static const _endpoint = 'https://www.googleapis.com/youtube/v3/search';

  Future<EnrichedLinkResult> findBestMatch({
    required String title,
    required String channel,
    int maxResults = 5,
  }) async {
    if (_apiKey.isEmpty) {
      throw StateError('YOUTUBE_API_KEY is not configured.');
    }

    final sanitizedChannel = channel.trim();
    final bool hasEllipsis = sanitizedChannel.contains('…') || sanitizedChannel.contains('...');
    final bool hasReliableChannel =
        sanitizedChannel.isNotEmpty && sanitizedChannel.length >= 3 && !hasEllipsis;
    final query = hasReliableChannel ? '$title $sanitizedChannel'.trim() : title.trim();
    final uri = Uri.parse(_endpoint).replace(queryParameters: {
      'part': 'snippet',
      'type': 'video',
      'maxResults': '$maxResults',
      'q': query,
      'key': _apiKey,
      'safeSearch': 'none',
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception(
        'YouTube search failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['items'] as List<dynamic>? ?? [];
    if (items.isEmpty) {
      return EnrichedLinkResult.empty('No search results from YouTube API.');
    }

    EnrichedLinkResult bestResult = EnrichedLinkResult.empty('Low confidence');
    double bestScore = 0;

    for (final item in items) {
      final map = item as Map<String, dynamic>;
      final snippet = map['snippet'] as Map<String, dynamic>? ?? {};
      final id = map['id'] as Map<String, dynamic>? ?? {};
      final videoId = id['videoId'] as String?;
      if (videoId == null) continue;

      final candidateTitle = (snippet['title'] as String? ?? '').trim();
      final candidateChannel =
          (snippet['channelTitle'] as String? ?? '').trim();

      final titleScore = _scoreStrings(candidateTitle, title);
      final channelScore =
          hasReliableChannel ? _scoreStrings(candidateChannel, sanitizedChannel) : 0;
      final combined = hasReliableChannel
          ? (titleScore * 0.7) + (channelScore * 0.3)
          : titleScore;

      if (combined > bestScore) {
        bestScore = combined;
        final url = 'https://www.youtube.com/watch?v=$videoId';
        final reason = hasReliableChannel
            ? 'Matched title ${(titleScore * 100).round()}% / channel ${(channelScore * 100).round()}%.'
            : 'Matched by title ${(titleScore * 100).round()}% (channel omitted due to low confidence).';
        bestResult = EnrichedLinkResult(
          url: url,
          score: combined,
          reason: reason,
          thumbnailUrl: (snippet['thumbnails'] is Map<String, dynamic>)
              ? ((snippet['thumbnails'] as Map<String, dynamic>)['high']
                      as Map<String, dynamic>? ??
                  {})['url'] as String?
              : null,
          channelTitle: candidateChannel,
        );
      }
    }

    if (bestScore < 0.25) {
      return EnrichedLinkResult.empty(
        'No confident match (best score ${(bestScore * 100).round()}%).',
      );
    }

    return bestResult;
  }

  double _scoreStrings(String a, String b) {
    if (a.isEmpty || b.isEmpty) return 0;
    final normalizedA = _normalize(a);
    final normalizedB = _normalize(b);
    if (normalizedA == normalizedB) return 1.0;

    final tokensA = normalizedA.split(' ').where((t) => t.isNotEmpty).toSet();
    final tokensB = normalizedB.split(' ').where((t) => t.isNotEmpty).toSet();
    if (tokensA.isEmpty || tokensB.isEmpty) return 0;

    final intersection = tokensA.intersection(tokensB).length;
    final union = tokensA.union(tokensB).length;
    return union == 0 ? 0 : intersection / union;
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
