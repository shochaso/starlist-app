import '../models/youtube_import_item.dart';

class YoutubeOcrParserService {
  const YoutubeOcrParserService();

  List<YoutubeImportItem> parse(String rawText) {
    final trimmed = rawText.trim();
    if (trimmed.isEmpty) return [];

    final lines = trimmed
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return [];

    var startIndex = lines.indexWhere((line) {
      final isPreamble = RegExp(
              r'^(here are|sure, here|Sure, |Here are|以下に|はい、)',
              caseSensitive: false)
          .hasMatch(line);
      final isHeaderLike = line.endsWith(':');
      return !isPreamble && !isHeaderLike && line.length > 5;
    });

    if (startIndex == -1) {
      final hasPreamble = lines.any((line) => RegExp(
              r'^(here are|sure, here|Sure, |Here are|以下に|はい、)',
              caseSensitive: false)
          .hasMatch(line));
      if (hasPreamble) {
        return [];
      }
      startIndex = 0;
    }

    final parsedItems = <YoutubeImportItem>[];
    final relevantLines = lines.sublist(startIndex);

    for (var i = 0; i < relevantLines.length; i++) {
      var currentLine =
          relevantLines[i].replaceFirst(RegExp(r'^[\*\-\d\.]+\s*'), '').trim();
      if (currentLine.isEmpty) continue;

      final dashIndex = currentLine.lastIndexOf(' - ');
      if (dashIndex > 0 && dashIndex < currentLine.length - 3) {
        final title = currentLine.substring(0, dashIndex).trim();
        final channel = currentLine.substring(dashIndex + 3).trim();
        parsedItems.add(
          YoutubeImportItem(
            id: _stableId(title, channel),
            title: title,
            channel: channel,
            confidence: 0.95,
            selected: false,
            isPublic: false,
            isSaved: false,
            isLinkLoading: false,
          ),
        );
        continue;
      }

      final title = currentLine;
      var channel = '';

      if (i + 1 < relevantLines.length) {
        final nextLine = relevantLines[i + 1];
        final isNextLineAnotherTitle =
            RegExp(r'^[\*\-\d\.]+\s*').hasMatch(nextLine) ||
                nextLine.contains(' - ');
        if (!isNextLineAnotherTitle) {
          channel = nextLine;
          const splitters = ['・', '•', '—', '視聴回数', '回視聴'];
          for (final splitter in splitters) {
            if (channel.contains(splitter)) {
              channel = channel.split(splitter).first.trim();
              break;
            }
          }
          channel = channel.replaceFirst(RegExp(r'^[\*\-\d\.]+\s*'), '').trim();
          i++;
        }
      }

      parsedItems.add(
        YoutubeImportItem(
          id: _stableId(title, channel),
          title: title,
          channel: channel,
          confidence: 0.9,
          selected: false,
          isPublic: false,
          isSaved: false,
          isLinkLoading: false,
        ),
      );
    }

    return parsedItems
        .where((item) => !_preamblePattern.hasMatch(item.title))
        .toList();
  }

  static String _stableId(String title, String channel) =>
      '${title.trim()}|${channel.trim()}'.toLowerCase();

  static final _preamblePattern = RegExp(
      r'^(here are|sure, here|Sure, |Here are|以下に|はい、)',
      caseSensitive: false);
}
