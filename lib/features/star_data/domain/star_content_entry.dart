import 'package:flutter/foundation.dart';

import '../../../providers/youtube_history_provider.dart';

@immutable
class StarContentEntry {
  const StarContentEntry({
    required this.id,
    required this.title,
    required this.channel,
    required this.occurredAt,
    required this.service,
    this.description,
    this.url,
    this.thumbnailUrl,
    this.durationText,
    this.viewsText,
    this.tags = const <String>[],
    this.sessionId,
    this.isLocalOnly = false,
  });

  final String id;
  final String title;
  final String channel;
  final DateTime occurredAt;
  final String service;
  final String? description;
  final String? url;
  final String? thumbnailUrl;
  final String? durationText;
  final String? viewsText;
  final List<String> tags;
  final String? sessionId;
  final bool isLocalOnly;

  String get uniqueKey {
    if (sessionId != null && sessionId!.isNotEmpty) {
      return '${sessionId!}|$title|${occurredAt.toIso8601String()}';
    }
    if (id.isNotEmpty) {
      return id;
    }
    return '$title|${occurredAt.toIso8601String()}';
  }

  StarContentEntry copyWith({
    String? id,
    String? title,
    String? channel,
    DateTime? occurredAt,
    String? service,
    String? description,
    String? url,
    String? thumbnailUrl,
    String? durationText,
    String? viewsText,
    List<String>? tags,
    String? sessionId,
    bool? isLocalOnly,
  }) {
    return StarContentEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      channel: channel ?? this.channel,
      occurredAt: occurredAt ?? this.occurredAt,
      service: service ?? this.service,
      description: description ?? this.description,
      url: url ?? this.url,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationText: durationText ?? this.durationText,
      viewsText: viewsText ?? this.viewsText,
      tags: tags ?? this.tags,
      sessionId: sessionId ?? this.sessionId,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
    );
  }

  static StarContentEntry fromSupabase(Map<String, dynamic> json) {
    final metadata = _normalizeMetadata(json['metadata']);
    final occurredAtRaw = json['occurred_at'] ?? json['created_at'];
    DateTime occurredAt;
    if (occurredAtRaw is String) {
      occurredAt = DateTime.tryParse(occurredAtRaw) ?? DateTime.now();
    } else if (occurredAtRaw is DateTime) {
      occurredAt = occurredAtRaw;
    } else {
      occurredAt = DateTime.now();
    }

    final tags = <String>[];
    if (json['tags'] is List) {
      tags.addAll(
        (json['tags'] as List)
            .whereType<String>()
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty),
      );
    }

    final service = (json['service'] as String?)?.toLowerCase() ?? 'youtube';

    return StarContentEntry(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      channel: metadata['channel'] as String? ?? '',
      occurredAt: occurredAt,
      service: service,
      description: json['description'] as String? ?? metadata['description'] as String?,
      url: json['url'] as String? ?? metadata['url'] as String?,
      thumbnailUrl: metadata['thumbnailUrl'] as String?,
      durationText: metadata['duration'] as String?,
      viewsText: metadata['views'] as String? ?? metadata['viewCount'] as String?,
      tags: tags,
      sessionId: metadata['sessionId'] as String?,
      isLocalOnly: false,
    );
  }

  static StarContentEntry fromHistoryItem(YouTubeHistoryItem item) {
    return StarContentEntry(
      id: 'local-${item.sessionId ?? item.title}-${item.addedAt.microsecondsSinceEpoch}',
      title: item.title,
      channel: item.channel,
      occurredAt: item.addedAt,
      service: 'youtube',
      description: item.displayViews,
      url: item.url,
      thumbnailUrl: item.thumbnailUrl,
      durationText: item.duration,
      viewsText: item.displayViews,
      tags: const <String>[],
      sessionId: item.sessionId,
      isLocalOnly: true,
    );
  }

  static Map<String, dynamic> _normalizeMetadata(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value as Map);
    }
    return const <String, dynamic>{};
  }
}
