import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

/// Service for communicating with FastAPI backend
class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  /// Upload a single notification to the backend
  Future<bool> uploadNotification(NotificationModel notification) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/notifications'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'package_name': notification.packageName,
              'sender_name': notification.senderName,
              'truncated_message': notification.truncatedMessage,
              'full_message': notification.fullMessage,
              'message_type': notification.messageType,
              'timestamp': notification.timestamp,
            }),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error uploading notification: $e');
      return false;
    }
  }

  /// Upload multiple notifications in batch
  Future<Map<String, dynamic>> uploadNotificationsBatch(
    List<NotificationModel> notifications,
  ) async {
    try {
      final notificationsData = notifications
          .map((n) => {
                'package_name': n.packageName,
                'sender_name': n.senderName,
                'truncated_message': n.truncatedMessage,
                'full_message': n.fullMessage,
                'message_type': n.messageType,
                'timestamp': n.timestamp,
              })
          .toList();

      final response = await http
          .post(
            Uri.parse('$baseUrl/notifications/batch'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'notifications': notificationsData}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'uploaded': data['uploaded'] ?? notifications.length,
          'message': data['message'] ?? 'Upload successful',
        };
      } else {
        return {
          'success': false,
          'uploaded': 0,
          'message': 'Upload failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'uploaded': 0,
        'message': 'Upload error: $e',
      };
    }
  }

  /// Check server health
  Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
