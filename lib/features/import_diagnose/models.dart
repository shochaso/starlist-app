import 'package:flutter/foundation.dart';

@immutable
class ImportDiagnoseState {
  const ImportDiagnoseState({
    required this.ocr,
    required this.enrichHits,
    this.lastAnalyzed,
    this.alertMessage,
  });

  const ImportDiagnoseState.empty()
      : ocr = const OcrResult.empty(),
        enrichHits = 0,
        lastAnalyzed = null,
        alertMessage = null;

  factory ImportDiagnoseState.sample() {
    return ImportDiagnoseState(
      ocr: const OcrResult(
        imageUrl: 'https://cdn.starry.social/import/sample_receipt.jpg',
        text: 'スターバックス\nアイスラテ 430\nチーズケーキ 520\n合計 950',
        confidence: 0.82,
        status: 'completed',
        storagePath: 'private/originals/sample_receipt.jpg',
      ),
      enrichHits: 2,
      lastAnalyzed: DateTime.now(),
    );
  }

  factory ImportDiagnoseState.fromJson(Map<String, dynamic> json) {
    final parsed = Map<String, dynamic>.from(json);
    final ocrJson = Map<String, dynamic>.from(
        (parsed['ocr'] as Map<String, dynamic>?) ?? parsed);
    if (!ocrJson.containsKey('storage_path')) {
      for (final key in ['storage_path', 'storagePath', 'path', 'resource']) {
        final value = parsed[key];
        if (value is String && value.isNotEmpty) {
          ocrJson[key] = value;
          break;
        }
      }
    }
    final analyzedAt = parsed['analyzed_at'] ?? ocrJson['analyzed_at'];
    final enrich = parsed['enrich'];
    final enrichHits = () {
      if (parsed['enrich_hits'] is num) {
        return (parsed['enrich_hits'] as num).toInt();
      }
      if (parsed['enrich_hits_count'] is num) {
        return (parsed['enrich_hits_count'] as num).toInt();
      }
      if (enrich is Map<String, dynamic>) {
        final hits = enrich['hits'];
        if (hits is num) {
          return hits.toInt();
        }
      }
      return 0;
    }();
    return ImportDiagnoseState(
      ocr: OcrResult.fromJson(ocrJson),
      enrichHits: enrichHits,
      lastAnalyzed: analyzedAt != null
          ? DateTime.tryParse(analyzedAt.toString())
          : null,
      alertMessage: parsed['message'] as String? ??
          (parsed['error'] as String?) ??
          (parsed['warning'] as String?),
    );
  }

  final OcrResult ocr;
  final int enrichHits;
  final DateTime? lastAnalyzed;
  final String? alertMessage;

  String get originalImageUrl => ocr.imageUrl;
  String get ocrText => ocr.text;
  double get confidence => ocr.confidence;
  String get status => ocr.status;
  String get storagePath => ocr.storagePath;

  ImportDiagnoseState copyWith({
    OcrResult? ocr,
    int? enrichHits,
    DateTime? lastAnalyzed,
    String? alertMessage,
  }) {
    return ImportDiagnoseState(
      ocr: ocr ?? this.ocr,
      enrichHits: enrichHits ?? this.enrichHits,
      lastAnalyzed: lastAnalyzed ?? this.lastAnalyzed,
      alertMessage: alertMessage ?? this.alertMessage,
    );
  }
}

@immutable
class OcrResult {
  const OcrResult({
    required this.imageUrl,
    required this.text,
    required this.confidence,
    required this.status,
    required this.storagePath,
  });

  const OcrResult.empty()
      : imageUrl = '',
        text = '',
        confidence = 0,
        status = 'pending',
        storagePath = '';

  factory OcrResult.fromJson(Map<String, dynamic> json) {
    return OcrResult(
      imageUrl: json['image_url'] as String? ??
          json['imageUrl'] as String? ??
          json['signed_url'] as String? ??
          '',
      text: json['text'] as String? ??
          json['ocr_text'] as String? ??
          json['content'] as String? ??
          '',
      confidence: (json['confidence'] as num?)?.toDouble() ??
          (json['score'] as num?)?.toDouble() ??
          0,
      status: (json['status'] as String?)?.toLowerCase() ?? 'pending',
      storagePath: _extractPath(json),
    );
  }

  final String imageUrl;
  final String text;
  final double confidence;
  final String status;
  final String storagePath;

  bool get isCompleted => status == 'completed' || status == 'done';
  bool get isPending => status == 'pending' || status == 'processing';

  OcrResult copyWith({
    String? imageUrl,
    String? text,
    double? confidence,
    String? status,
    String? storagePath,
  }) {
    return OcrResult(
      imageUrl: imageUrl ?? this.imageUrl,
      text: text ?? this.text,
      confidence: confidence ?? this.confidence,
      status: status ?? this.status,
      storagePath: storagePath ?? this.storagePath,
    );
  }

  static String _extractPath(Map<String, dynamic> json) {
    for (final key in ['storage_path', 'storagePath', 'path', 'resource']) {
      final value = json[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
