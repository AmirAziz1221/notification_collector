import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/notification_model.dart';

/// Service for exporting notification data to CSV format
class CsvExporter {
  /// Export notifications to CSV file
  Future<String?> exportToCsv(List<NotificationModel> notifications) async {
    try {
      if (notifications.isEmpty) {
        print('No notifications to export');
        return null;
      }

      // Create CSV data with headers
      List<List<dynamic>> csvData = [
        [
          'ID',
          'Package Name',
          'Sender Name',
          'Truncated Message (Preview)',
          'Full Message',
          'Message Type',
          'Timestamp',
          'Date Time',
          'Has Full Message'
        ]
      ];

      // Add notification data rows
      for (var notification in notifications) {
        csvData.add([
          notification.id ?? '',
          notification.packageName,
          notification.senderName,
          notification.truncatedMessage,
          notification.fullMessage,
          notification.messageType,
          notification.timestamp,
          notification.formattedTimestamp,
          notification.hasFullMessage ? 'Yes' : 'No',
        ]);
      }

      // Convert to CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // Get directory to save file
      final directory = await _getExportDirectory();
      if (directory == null) {
        print('Could not access storage directory');
        return null;
      }

      // Create filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'notification_dataset_$timestamp.csv';
      final filePath = '${directory.path}/$fileName';

      // Write to file
      final file = File(filePath);
      await file.writeAsString(csv);

      print('CSV exported successfully to: $filePath');
      return filePath;
    } catch (e) {
      print('Error exporting to CSV: $e');
      return null;
    }
  }

  /// Get appropriate directory for export
  Future<Directory?> _getExportDirectory() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final paths = directory.path.split('/');
        final idx = paths.indexOf('Android');
        if (idx != -1) {
          final basePath = paths.sublist(0, idx).join('/');
          final downloadsPath = '$basePath/Download/NotificationCollector';
          final downloadsDir = Directory(downloadsPath);

          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }

          return downloadsDir;
        }
      }

      return await getApplicationDocumentsDirectory();
    } catch (e) {
      print('Error getting export directory: $e');
      return await getApplicationDocumentsDirectory();
    }
  }

  /// Get export directory path for display
  Future<String> getExportDirectoryPath() async {
    final dir = await _getExportDirectory();
    return dir?.path ?? 'Unknown';
  }
}
