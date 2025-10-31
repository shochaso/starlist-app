const String kEnv = String.fromEnvironment('ENV', defaultValue: 'development');
const bool kHideImportIcons =
    bool.fromEnvironment('HIDE_IMPORT_ICONS', defaultValue: false);
const bool kCfBypassLocal =
    bool.fromEnvironment('CF_BYPASS_LOCAL', defaultValue: false);
const bool kForceGenericServiceIcons = bool.fromEnvironment(
  'FORCE_GENERIC_SERVICE_ICONS',
  defaultValue: false,
);
