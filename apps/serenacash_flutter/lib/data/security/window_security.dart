/// Keeps the app window out of screenshots, screen recordings and the recent-apps thumbnail
/// (Android FLAG_SECURE). Turned on together with the app lock.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class WindowSecurity {
  Future<void> setSecure(bool secure);
}

final windowSecurityProvider = Provider<WindowSecurity>(
  (_) => const PlatformWindowSecurity(),
);

class PlatformWindowSecurity implements WindowSecurity {
  const PlatformWindowSecurity();
  static const _channel = MethodChannel('br.com.serenacash.mobile/window');

  @override
  Future<void> setSecure(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      // No native side on this platform (iOS hides the snapshot by other means; tests have none).
    } on PlatformException {
      // The window flag is a hardening measure; failing to set it must not lock the user out.
    }
  }
}
