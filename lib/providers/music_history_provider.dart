import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../src/services/spotify_playlist_parser.dart';

typedef MusicTrack = SpotifyTrack;

class MusicHistoryItem {
  final String serviceId;
  final String serviceName;
  final String title;
  final String artist;
  final String? album;
  final String? duration;
  final DateTime addedAt;
  final String sessionId;
  final double confidence;
  final Map<String, dynamic> extra;

  MusicHistoryItem({
    required this.serviceId,
    required this.serviceName,
    required this.title,
    required this.artist,
    required this.addedAt,
    required this.sessionId,
    required this.confidence,
    this.album,
    this.duration,
    this.extra = const {},
  });

  factory MusicHistoryItem.fromTrack({
    required MusicTrack track,
    required String serviceId,
    required String serviceName,
    required DateTime addedAt,
    required String sessionId,
  }) {
    return MusicHistoryItem(
      serviceId: serviceId,
      serviceName: serviceName,
      title: track.title,
      artist: track.artist,
      album: track.album,
      duration: track.duration,
      addedAt: addedAt,
      sessionId: sessionId,
      confidence: track.confidence,
      extra: {
        'addedAtRaw': track.addedAt,
        'trackNumber': track.trackNumber,
      }..removeWhere((key, value) => value == null),
    );
  }
}

class MusicHistoryNotifier
    extends StateNotifier<Map<String, List<MusicHistoryItem>>> {
  MusicHistoryNotifier() : super(const {});

  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> addTracks(
      String serviceId, List<MusicHistoryItem> tracks) async {
    if (tracks.isEmpty) {
      return;
    }

    await _persistTracks(serviceId, tracks);

    final existing = List<MusicHistoryItem>.from(state[serviceId] ?? const []);
    existing.insertAll(0, tracks);

    state = {
      ...state,
      serviceId: existing.take(200).toList(),
    };
  }

  Future<void> refreshFromSupabase({String? serviceId}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    // Use universal .filter(...) to avoid builder-type differences across versions
    var query = _supabase
        .from('contents')
        .select()
        .eq('author_id', userId)
        .eq('category', 'music');

    if (serviceId != null) {
      query = query.eq('service', serviceId);
    }

    final response = await query
        .order('occurred_at', ascending: false)
        .limit(200);

    final Map<String, List<MusicHistoryItem>> grouped = {};
    for (final row in response) {
      final item = _fromSupabaseRow(row);
      grouped.putIfAbsent(item.serviceId, () => []).add(item);
    }

    state = {
      ...state,
      if (serviceId != null)
        serviceId: grouped[serviceId] ?? const []
      else
        ...grouped,
    };
  }

  List<MusicHistoryItem> getTracks(String serviceId) {
    return state[serviceId] ?? const [];
  }

  Future<void> _persistTracks(
    String serviceId,
    List<MusicHistoryItem> tracks,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    final payloads = tracks.map((track) {
      final metadata = {
        'artist': track.artist,
        'album': track.album,
        'duration': track.duration,
        'serviceName': track.serviceName,
        'sessionId': track.sessionId,
        ...track.extra,
      };

      return {
        'author_id': userId,
        'title': track.title,
        'description':
            '${track.artist}${track.album != null ? ' - ${track.album}' : ''}',
        'type': 'text',
        'url': null,
        'metadata': metadata,
        'ingest_mode': 'full',
        'confidence': track.confidence,
        'tags': [
          'music',
          track.serviceId,
          track.artist,
        ],
        'occurred_at': track.addedAt.toIso8601String(),
        'category': 'music',
        'service': serviceId,
        'is_published': false,
      };
    }).toList();

    if (payloads.isEmpty) {
      return;
    }

    try {
      await _supabase.from('contents').insert(payloads);
    } catch (e) {
      // ローカル状態は保持しつつ、永続化エラーはログ出力
      // ignore: avoid_print
      print('MusicHistoryNotifier: persist error -> $e');
    }
  }

  MusicHistoryItem _fromSupabaseRow(Map<String, dynamic> row) {
    final metadata = Map<String, dynamic>.from(row['metadata'] ?? {});
    final serviceId = (row['service'] as String?) ?? 'unknown_service';
    return MusicHistoryItem(
      serviceId: serviceId,
      serviceName:
          metadata['serviceName'] as String? ?? serviceId.toUpperCase(),
      title: (row['title'] as String?) ?? 'Unknown Title',
      artist: (metadata['artist'] as String?) ?? 'Unknown Artist',
      album: metadata['album'] as String?,
      duration: metadata['duration'] as String?,
      addedAt: row['occurred_at'] != null
          ? DateTime.parse(row['occurred_at'] as String)
          : DateTime.tryParse(row['created_at'] as String? ?? '') ??
              DateTime.now(),
      sessionId: metadata['sessionId'] as String? ?? row['id'] as String,
      confidence: (row['confidence'] as num?)?.toDouble() ?? 0.0,
      extra: metadata,
    );
  }
}

final musicHistoryProvider = StateNotifierProvider<MusicHistoryNotifier,
    Map<String, List<MusicHistoryItem>>>((ref) {
  return MusicHistoryNotifier();
});
