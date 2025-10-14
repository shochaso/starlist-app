/// Feature flag toggles that can be overridden via compile-time environment variables.
class FeatureFlags {
  const FeatureFlags._();

  /// Enable mixing tag-only search results when `STARLIST_FF_TAG_ONLY=true` is supplied.
  static const bool enableTagOnlySearch =
      const String.fromEnvironment('STARLIST_FF_TAG_ONLY', defaultValue: 'false') == 'true';
}
