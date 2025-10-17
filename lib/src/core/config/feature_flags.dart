/// Feature flag toggles that can be overridden via compile-time environment variables.
class FeatureFlags {
  const FeatureFlags._();

  /// Enable mixing tag-only search results when `STARLIST_FF_TAG_ONLY=true` is supplied.
  static const bool enableTagOnlySearch = const String.fromEnvironment(
          'STARLIST_FF_TAG_ONLY',
          defaultValue: 'false') ==
      'true';

  /// Hide service icons on the import screens when launching with `--dart-define=HIDE_IMPORT_ICONS=true`.
  static const bool hideImportIcons = const String.fromEnvironment(
          'HIDE_IMPORT_ICONS',
          defaultValue: 'false') ==
      'true';

  /// Hide sample media (thumbnails, placeholders, decorative backgrounds) when launching with
  /// `--dart-define=HIDE_SAMPLE_MEDIA=true`.
  static const bool hideSampleMedia = const String.fromEnvironment(
          'HIDE_SAMPLE_MEDIA',
          defaultValue: 'false') ==
      'true';

  /// Hide sample cards when launching with `--dart-define=HIDE_SAMPLE_CARDS=true`.
  static const bool hideSampleCards = const String.fromEnvironment(
          'HIDE_SAMPLE_CARDS',
          defaultValue: 'false') ==
      'true';
}
