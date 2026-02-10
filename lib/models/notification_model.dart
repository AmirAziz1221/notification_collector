/// Model class representing a collected notification
/// Stores both truncated preview and full message content
class NotificationModel {
  final int? id;
  final String packageName;
  final String senderName;
  final String truncatedMessage; // Preview text shown in notification bar
  final String fullMessage; // Full message content (or NOT_AVAILABLE)
  final String messageType; // SMS, WhatsApp, Telegram, etc.
  final int timestamp;

  NotificationModel({
    this.id,
    required this.packageName,
    required this.senderName,
    required this.truncatedMessage,
    required this.fullMessage,
    required this.messageType,
    required this.timestamp,
  });

  /// Convert from database map
  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] as int?,
      packageName: map['package_name'] as String,
      senderName: map['sender_name'] as String,
      truncatedMessage: map['truncated_message'] as String,
      fullMessage: map['full_message'] as String,
      messageType: map['message_type'] as String,
      timestamp: map['timestamp'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'package_name': packageName,
      'sender_name': senderName,
      'truncated_message': truncatedMessage,
      'full_message': fullMessage,
      'message_type': messageType,
      'timestamp': timestamp,
    };
  }

  /// Get formatted timestamp
  String get formattedTimestamp {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  /// Check if full message is available
  bool get hasFullMessage => fullMessage != 'NOT_AVAILABLE';

  @override
  String toString() {
    return 'NotificationModel{id: $id, type: $messageType, sender: $senderName, '
        'truncated: ${truncatedMessage.substring(0, truncatedMessage.length > 30 ? 30 : truncatedMessage.length)}..., '
        'hasFullMessage: $hasFullMessage}';
  }
}
