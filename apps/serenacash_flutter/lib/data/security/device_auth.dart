/// Confirmation by the device itself (fingerprint, face or the screen lock), with the reason of a
/// failure kept apart: "you cancelled", "nothing is set up on this phone" and "the sensor is
/// locked for now" need different words and different next steps.
library;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

enum DeviceAuthStatus {
  /// The device confirmed the person.
  confirmed,

  /// The device tried and did not recognise the person.
  failed,

  /// The person (or the system) closed the prompt.
  canceled,

  /// No screen lock and no biometrics are set up on the device.
  notSetUp,

  /// The device has no biometric sensor and no screen lock to fall back on.
  noHardware,

  /// Too many attempts: the system refuses biometrics for a while.
  lockedOut,

  /// The prompt could not be shown (no screen to show it on, another prompt open, platform error).
  unavailable,
}

abstract interface class DeviceAuth {
  /// Whether a fingerprint or a face is enrolled. Only used to describe the option on screen.
  Future<bool> hasBiometrics();

  Future<DeviceAuthStatus> confirm(String reason);

  /// Opens the system screen where a screen lock or a fingerprint is set up. False when it cannot.
  Future<bool> openSecuritySettings();
}

final deviceAuthProvider = Provider<DeviceAuth>(
  (_) => LocalDeviceAuth(LocalAuthentication()),
);

/// Maps the plugin's error code (by name, so a code added by a newer plugin version falls into
/// "unavailable" instead of breaking the build).
DeviceAuthStatus deviceAuthStatusFor(String code) => switch (code) {
  'userCanceled' ||
  'systemCanceled' ||
  'timeout' ||
  'userRequestedFallback' => DeviceAuthStatus.canceled,
  'noCredentialsSet' || 'noBiometricsEnrolled' => DeviceAuthStatus.notSetUp,
  'noBiometricHardware' => DeviceAuthStatus.noHardware,
  'temporaryLockout' || 'biometricLockout' => DeviceAuthStatus.lockedOut,
  _ => DeviceAuthStatus.unavailable,
};

class LocalDeviceAuth implements DeviceAuth {
  LocalDeviceAuth(this._auth);
  final LocalAuthentication _auth;
  static const _channel = MethodChannel('br.com.serenacash.mobile/window');

  @override
  Future<bool> hasBiometrics() async {
    try {
      if (!await _auth.isDeviceSupported()) return false;
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<DeviceAuthStatus> confirm(String reason) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        // The screen lock (PIN, pattern, password) is accepted too: the question is whether the
        // owner of the phone is holding it, not which sensor answered.
        biometricOnly: false,
      );
      return ok ? DeviceAuthStatus.confirmed : DeviceAuthStatus.failed;
    } on LocalAuthException catch (e) {
      return deviceAuthStatusFor(e.code.name);
    } catch (_) {
      return DeviceAuthStatus.unavailable;
    }
  }

  @override
  Future<bool> openSecuritySettings() async {
    try {
      return await _channel.invokeMethod<bool>('openSecuritySettings') ?? false;
    } on MissingPluginException {
      return false;
    } on PlatformException {
      return false;
    }
  }
}
