import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricHardwareBridge {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const MethodChannel _nativeChannel = MethodChannel('com.paypulse.engine/secure_enclave');

  static Future<bool> verifyBiometrics({required String reason}) async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isDeviceSupported) {
        return true;
      }

      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}