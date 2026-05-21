import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';


class VulkanLoader {
  static const MethodChannel _channel = MethodChannel('com.xodos/vulkan_loader');

  /// Load a custom Vulkan driver via adrenotools.
  static Future<bool> loadCustomDriver({
    required String driverDir,
    required String driverName,
    required String hooksDir,
  }) async {
    try {
      final result = await _channel.invokeMethod('loadCustomDriver', {
        'driverDir': driverDir,
        'driverName': driverName,
        'hooksDir': hooksDir,
      });
      return result == true;
    } catch (e) {
      debugPrint('VulkanLoader error: $e');
      return false;
    }
  }

  /// Revert to system driver.
  static Future<bool> loadSystemDriver() async {
    try {
      final result = await _channel.invokeMethod('loadSystemDriver');
      return result == true;
    } catch (e) {
      debugPrint('VulkanLoader error: $e');
      return false;
    }
  }
}