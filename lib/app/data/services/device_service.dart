import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

/// فحص نوع الجهاز اللي التطبيق شغّال عليه
class DeviceService {
  DeviceService._();

  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// بترجع true لو التطبيق شغّال على جهاز حقيقي،
  /// و false لو شغّال على محاكي (Emulator / Simulator).
  static Future<bool> isRealDevice() async {
    if (kIsWeb) return true;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      }

      return true;
    } catch (_) {
      // لو حصل خطأ في القراءة منفضّلش نحجب التطبيق عن مستخدم حقيقي
      return true;
    }
  }
}
