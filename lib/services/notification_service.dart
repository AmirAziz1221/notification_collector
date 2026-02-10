import 'package:flutter/services.dart';
import '../models/notification_model.dart';
import '../database/database_helper.dart';
import 'api_service.dart';

/// Service for managing notification collection
class NotificationService {
  static const platform = MethodChannel('notification_collector_channel');
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiService? _apiService;

  bool _isCollecting = false;
  Function(NotificationModel)? _onNotificationReceived;

  NotificationService({ApiService? apiService}) : _apiService = apiService {
    _setupMethodCallHandler();
  }

  bool get isCollecting => _isCollecting;

  /// Setup method call handler to receive notifications from native code
  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onNotificationReceived') {
        await _handleNotificationReceived(call.arguments);
      }
    });
  }

  /// Handle notification received from native service
  Future<void> _handleNotificationReceived(dynamic arguments) async {
    try {
      final Map<String, dynamic> data = Map<String, dynamic>.from(arguments);

      final notification = NotificationModel(
        packageName: data['packageName'] as String,
        senderName: data['senderName'] as String,
        truncatedMessage: data['truncatedMessage'] as String,
        fullMessage: data['fullMessage'] as String,
        messageType: data['messageType'] as String,
        timestamp: data['timestamp'] as int,
      );

      // Save to local database
      await _dbHelper.insertNotification(notification);

      // Upload to server if API service is configured
      if (_apiService != null) {
        _apiService!.uploadNotification(notification);
      }

      // Notify listeners
      _onNotificationReceived?.call(notification);

      print('Notification collected: ${notification.toString()}');
    } catch (e) {
      print('Error handling notification: $e');
    }
  }

  /// Set callback for when notifications are received
  void setOnNotificationReceived(Function(NotificationModel) callback) {
    _onNotificationReceived = callback;
  }

  /// Start collecting notifications
  void startCollection() {
    _isCollecting = true;
    print('Notification collection started');
  }

  /// Stop collecting notifications
  void stopCollection() {
    _isCollecting = false;
    print('Notification collection stopped');
  }

  /// Get all stored notifications
  Future<List<NotificationModel>> getAllNotifications() async {
    return await _dbHelper.getAllNotifications();
  }

  /// Get notification statistics
  Future<Map<String, int>> getStatistics() async {
    return await _dbHelper.getStatistics();
  }

  /// Upload all notifications to server
  Future<Map<String, dynamic>> uploadAllToServer() async {
    if (_apiService == null) {
      return {
        'success': false,
        'uploaded': 0,
        'message': 'API service not configured',
      };
    }

    final notifications = await getAllNotifications();
    if (notifications.isEmpty) {
      return {
        'success': true,
        'uploaded': 0,
        'message': 'No notifications to upload',
      };
    }

    return await _apiService!.uploadNotificationsBatch(notifications);
  }

  /// Clear all local data
  Future<void> clearAllData() async {
    await _dbHelper.deleteAllNotifications();
  }
}
