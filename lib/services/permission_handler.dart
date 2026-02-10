import 'package:permission_handler/permission_handler.dart';
import 'package:android_intent_plus/android_intent.dart';

/// Service for handling runtime permissions
class PermissionHandler {
  /// Check if notification access permission is granted
  Future<bool> hasNotificationAccess() async {
    return await Permission.notification.isGranted;
  }

  /// Request notification access permission
  Future<void> requestNotificationAccess() async {
    const intent = AndroidIntent(
      action: 'android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS',
    );
    await intent.launch();
  }

  /// Check if SMS read permission is granted
  Future<bool> hasSmsPermission() async {
    return await Permission.sms.isGranted;
  }

  /// Request SMS read permission
  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Check if storage permission is granted
  Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  /// Request storage permission
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Check all required permissions
  Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'notification': await hasNotificationAccess(),
      'sms': await hasSmsPermission(),
      'storage': await hasStoragePermission(),
    };
  }

  /// Request all required permissions
  Future<void> requestAllPermissions() async {
    if (!await hasSmsPermission()) {
      await requestSmsPermission();
    }

    if (!await hasStoragePermission()) {
      await requestStoragePermission();
    }
  }
}
