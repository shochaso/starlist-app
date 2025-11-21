import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/youtube_history_provider.dart';
import '../../../src/models/enriched_link_result.dart';
import '../../../src/models/youtube_import_item.dart';
import '../../../src/services/openai_ocr_service.dart';
import '../../../src/services/youtube_api_link_enricher_service.dart';
import '../../../src/services/youtube_ocr_parser_service.dart';

final youtubeImportWorkflowProvider =
    StateNotifierProvider<YoutubeImportWorkflow, YoutubeImportWorkflowState>(
        (ref) {
  final historyNotifier = ref.read(youtubeHistoryProvider.notifier);
  return YoutubeImportWorkflow(historyNotifier: historyNotifier);
});

class YoutubeImportWorkflowState {
  const YoutubeImportWorkflowState({
    required this.items,
    required this.rawText,
    this.isOcrRunning = false,
    this.isLinkEnriching = false,
    this.isUploading = false,
    this.isPublishing = false,
    this.errorMessage,
    this.enrichProgress = 0,
    this.enrichTotal = 0,
    this.uploadCompleted = false,
    this.publishCompleted = false,
  });

  final List<YoutubeImportItem> items;
  final String rawText;
  final bool isOcrRunning;
  final bool isLinkEnriching;
  final bool isUploading;
  final bool isPublishing;
  final String? errorMessage;
  final int enrichProgress;
  final int enrichTotal;
  final bool uploadCompleted;
  final bool publishCompleted;

  YoutubeImportWorkflowState copyWith({
    List<YoutubeImportItem>? items,
    String? rawText,
    bool? isOcrRunning,
    bool? isLinkEnriching,
    bool? isUploading,
    bool? isPublishing,
    String? errorMessage,
    bool clearError = false,
    int? enrichProgress,
    int? enrichTotal,
    bool? uploadCompleted,
    bool? publishCompleted,
  }) {
    return YoutubeImportWorkflowState(
      items: items ?? this.items,
      rawText: rawText ?? this.rawText,
      isOcrRunning: isOcrRunning ?? this.isOcrRunning,
      isLinkEnriching: isLinkEnriching ?? this.isLinkEnriching,
      isUploading: isUploading ?? this.isUploading,
      isPublishing: isPublishing ?? this.isPublishing,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      enrichProgress: enrichProgress ?? this.enrichProgress,
      enrichTotal: enrichTotal ?? this.enrichTotal,
      uploadCompleted: uploadCompleted ?? this.uploadCompleted,
      publishCompleted: publishCompleted ?? this.publishCompleted,
    );
  }

  static const initial = YoutubeImportWorkflowState(items: [], rawText: '');
}

class YoutubeImportWorkflow extends StateNotifier<YoutubeImportWorkflowState> {
  YoutubeImportWorkflow({required YouTubeHistoryNotifier historyNotifier})
      : _historyNotifier = historyNotifier,
        super(YoutubeImportWorkflowState.initial);

  final YouTubeHistoryNotifier _historyNotifier;
  final OpenAiOcrService _ocrService = OpenAiOcrService();
  final YoutubeOcrParserService _parserService =
      const YoutubeOcrParserService();
  final YoutubeApiLinkEnricherService _linkEnricherService =
      YoutubeApiLinkEnricherService();

  Future<void> runOcr({
    required Uint8List imageBytes,
    required String mimeType,
  }) async {
    state = state.copyWith(isOcrRunning: true, clearError: true);
    try {
      final text =
          await _ocrService.runOcr(imageBytes: imageBytes, mimeType: mimeType);
      _parseText(text);
      if (state.items.isNotEmpty) {
        Future<void>.delayed(
          const Duration(milliseconds: 200),
          () => enrichLinks(all: true),
        );
      }
    } catch (error) {
      state = state.copyWith(
        isOcrRunning: false,
        errorMessage: 'OCR解析に失敗しました: $error',
      );
    }
  }

  void updateRawText(String text) {
    state = state.copyWith(rawText: text);
    _parseText(text);
  }

  void _parseText(String text) {
    final parsed = _parserService.parse(text);
    state = state.copyWith(
      items: parsed,
      rawText: text,
      isOcrRunning: false,
      clearError: true,
      uploadCompleted: false,
      publishCompleted: false,
    );
  }

  void toggleSelect(String id) {
    final updated = state.items
        .map((item) =>
            item.id == id ? item.copyWith(selected: !item.selected) : item)
        .toList();
    state = state.copyWith(items: updated);
  }

  void togglePublic(String id) {
    final updated = state.items
        .map((item) =>
            item.id == id ? item.copyWith(isPublic: !item.isPublic) : item)
        .toList();
    state = state.copyWith(items: updated);
  }

  void selectAll(bool selectUnsavedOnly) {
    final hasUnsaved = state.items.any((item) => !item.isSaved);
    final updated = state.items.map((item) {
      if (hasUnsaved && !item.isSaved) {
        return item.copyWith(selected: selectUnsavedOnly);
      }
      if (!hasUnsaved) {
        return item.copyWith(isPublic: selectUnsavedOnly);
      }
      return item;
    }).toList();
    state = state.copyWith(items: updated);
  }

  Future<void> enrichLinks({bool all = false}) async {
    final targets = state.items
        .where((item) =>
            (all || item.selected) &&
            (item.videoUrl == null || item.videoUrl!.isEmpty))
        .toList();

    if (targets.isEmpty) return;

    state = state.copyWith(
      isLinkEnriching: true,
      enrichProgress: 0,
      enrichTotal: targets.length,
    );

    var processed = 0;
    for (final item in targets) {
      await _enrichSingle(item);
      processed++;
      state = state.copyWith(enrichProgress: processed);
    }

    state = state.copyWith(isLinkEnriching: false);
  }

  Future<void> _enrichSingle(YoutubeImportItem item) async {
    _updateItem(item.id, (current) => current.copyWith(isLinkLoading: true));
    try {
      final result = await _linkEnricherService.findBestMatch(
        title: item.title,
        channel: item.channel,
      );
      _updateItem(
        item.id,
        (current) => current.copyWith(
          isLinkLoading: false,
          videoUrl: result.url,
          matchScore: result.score,
          matchReason: result.reason,
          enrichError: result.url == null ? result.reason : null,
          thumbnailUrl: result.thumbnailUrl ?? current.thumbnailUrl,
        ),
      );
    } catch (error) {
      _updateItem(
        item.id,
        (current) => current.copyWith(
          isLinkLoading: false,
          enrichError: 'URL補完に失敗: $error',
        ),
      );
    }
  }

  Future<void> saveSelected() async {
    final toSave =
        state.items.where((item) => item.selected && !item.isSaved).toList();
    if (toSave.isEmpty) return;

    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final historyItems = toSave.map((item) => item.toHistoryItem()).toList();
      await _historyNotifier.addHistory(historyItems);
      final updated = state.items.map((item) {
        if (toSave.any((target) => target.id == item.id)) {
          return item.copyWith(isSaved: true, selected: false);
        }
        return item;
      }).toList();
      state = state.copyWith(
        items: updated,
        isUploading: false,
        uploadCompleted: true,
      );
    } catch (error) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: '保存時にエラー: $error',
      );
    }
  }

  Future<void> publishSelected() async {
    final toPublish = state.items.where((item) => item.isPublic).toList();
    if (toPublish.isEmpty) return;

    state = state.copyWith(isPublishing: true, clearError: true);
    try {
      // Placeholder for real publish logic.
      await Future<void>.delayed(const Duration(milliseconds: 500));
      state = state.copyWith(isPublishing: false, publishCompleted: true);
    } catch (error) {
      state = state.copyWith(
        isPublishing: false,
        errorMessage: '公開処理でエラー: $error',
      );
    }
  }

  void removeItem(String id) {
    final updated = state.items.where((item) => item.id != id).toList();
    state = state.copyWith(items: updated);
  }

  void clear() {
    state = YoutubeImportWorkflowState.initial;
  }

  void _updateItem(
    String id,
    YoutubeImportItem Function(YoutubeImportItem current) transform,
  ) {
    final updated = state.items
        .map((item) => item.id == id ? transform(item) : item)
        .toList();
    state = state.copyWith(items: updated);
  }

  List<Map<String, dynamic>> legacyExtractedVideos() {
    return state.items.map((item) => item.toMap()).toList();
  }
}
