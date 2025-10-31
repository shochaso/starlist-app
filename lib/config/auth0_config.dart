/// Auth0 configuration for LINE login (via external identity provider).
/// Values are supplied at build time via `--dart-define`.
library;

const String kAuth0Domain = String.fromEnvironment(
  'AUTH0_DOMAIN',
  defaultValue: '',
);

const String kAuth0ClientId = String.fromEnvironment(
  'AUTH0_CLIENT_ID',
  defaultValue: '',
);

const String kAuth0RedirectUri = String.fromEnvironment(
  'AUTH0_REDIRECT_URI',
  defaultValue: '',
);

/// `true` when both domainとclient id が設定されている場合に有効になる。
bool get kAuth0Enabled => kAuth0Domain.isNotEmpty && kAuth0ClientId.isNotEmpty;
