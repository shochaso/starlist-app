import 'dart:convert';
import 'dart:io';

const _legacyPatterns = <String>[
  'assets/icons/services/seven',
  'assets/icons/services/family',
  'assets/icons/services/lawson',
  'assets/icons/services/daily',
  'assets/icons/services/ministop',
  'assets/service_icons/seven',
  'assets/service_icons/family',
  'assets/service_icons/lawson',
  'assets/service_icons/daily',
  'assets/service_icons/ministop',
];

void main(List<String> args) {
  final manifestPath = args.isNotEmpty
      ? args.first
      : 'build/flutter_assets/AssetManifest.json';
  final file = File(manifestPath);
  if (!file.existsSync()) {
    stderr.writeln('AssetManifest not found at $manifestPath');
    exit(0);
  }

  final content = file.readAsStringSync();
  final offenders = <String>[];
  for (final pattern in _legacyPatterns) {
    if (content.contains(pattern)) {
      offenders.add(pattern);
    }
  }

  if (offenders.isNotEmpty) {
    stderr.writeln('Legacy convenience icons detected in AssetManifest:');
    for (final offender in offenders) {
      stderr.writeln(' - $offender');
    }
    exit(1);
  }

  try {
    jsonDecode(content);
  } catch (error) {
    stderr.writeln('Failed to decode AssetManifest: $error');
    exit(1);
  }

  stdout.writeln('No legacy convenience icons detected.');
}
