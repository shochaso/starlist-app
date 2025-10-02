import 'package:flutter/material.dart';

import 'tokens.dart';

extension TokensContext on BuildContext {
  AppTokens get tokens {
    final tokens = Theme.of(this).extension<AppTokens>();
    assert(tokens != null, 'AppTokens not found on Theme');
    return tokens!;
  }
}
