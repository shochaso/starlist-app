import 'dart:convert';
import 'dart:io';

String summarize(String input, {int maxLen = 200}) {
  final normalized = input
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .replaceAll(RegExp('[\t ]+'), ' ')
      .trim();
  if (normalized.length <= maxLen) return normalized;
  return '${normalized.substring(0, maxLen).trimRight()}…';
}

Future<void> ensureLogsDir(String path) async {
  final dir = Directory(path);
  if (!await dir.exists()) await dir.create(recursive: true);
}

Future<void> appendJsonLine(String filePath, Map<String, dynamic> data) async {
  final file = File(filePath);
  final sink = file.openWrite(mode: FileMode.append);
  sink.write(jsonEncode(data));
  sink.write('\n');
  await sink.flush();
  await sink.close();
}

Future<void> main(List<String> args) async {
  final input = args.isNotEmpty ? args.join(' ') : await stdin.transform(utf8.decoder).join();
  final summary = summarize(input);
  final timestamp = DateTime.now().toIso8601String();

  final logsDir = '${Directory.current.path}/logs';
  final historyPath = '$logsDir/prompt_history.json';
  await ensureLogsDir(logsDir);

  final record = <String, dynamic>{
    'timestamp': timestamp,
    'summary': summary,
  };

  await appendJsonLine(historyPath, record);
  stdout.writeln(jsonEncode(record));
  stdout.writeln('[Sync OK]');
}


