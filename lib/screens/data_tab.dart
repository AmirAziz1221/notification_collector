import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_state.dart';
import '../models/notification_model.dart';

/// Tab for viewing and exporting collected data
class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return Column(
          children: [
            // Action Bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () => _exportToCsv(context, state),
                          icon: const Icon(Icons.file_download),
                          label: const Text('Export CSV'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () => _uploadToServer(context, state),
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Upload'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: state.isLoading
                        ? null
                        : () => _clearData(context, state),
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    label: const Text(
                      'Clear All Data',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),

            // Data List
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.notifications.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No data collected yet',
                                style:
                                    TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start collection to see notifications here',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () => state.refresh(),
                          child: ListView.builder(
                            itemCount: state.notifications.length,
                            itemBuilder: (context, index) {
                              final notification = state.notifications[index];
                              return _buildNotificationCard(
                                  context, notification);
                            },
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationCard(
      BuildContext context, NotificationModel notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(notification.messageType),
          child: Text(
            notification.messageType.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          notification.senderName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Preview: ${notification.truncatedMessage}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  notification.hasFullMessage
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 14,
                  color: notification.hasFullMessage
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 4),
                Text(
                  notification.hasFullMessage
                      ? 'Full message available'
                      : 'Preview only',
                  style: TextStyle(
                    fontSize: 11,
                    color: notification.hasFullMessage
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Type', notification.messageType),
                _buildDetailRow('Package', notification.packageName),
                _buildDetailRow('Time', notification.formattedTimestamp),
                const Divider(),
                _buildMessageSection(
                  'Truncated Message (Preview)',
                  notification.truncatedMessage,
                  context,
                ),
                const SizedBox(height: 12),
                _buildMessageSection(
                  'Full Message',
                  notification.fullMessage,
                  context,
                  isFullMessage: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageSection(
    String title,
    String message,
    BuildContext context, {
    bool isFullMessage = false,
  }) {
    final isNotAvailable = message == 'NOT_AVAILABLE';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isNotAvailable ? Colors.grey.shade100 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isNotAvailable ? Colors.grey : Colors.blue.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              if (!isNotAvailable)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              fontStyle: isNotAvailable ? FontStyle.italic : FontStyle.normal,
              color: isNotAvailable ? Colors.grey : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'SMS':
        return Colors.green;
      case 'WhatsApp':
        return Colors.teal;
      case 'Telegram':
        return Colors.blue;
      case 'Messenger':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _exportToCsv(BuildContext context, AppState state) async {
    final filePath = await state.exportToCsv();

    if (!context.mounted) return;

    if (filePath != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Export Successful'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('CSV file has been saved to:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SelectableText(
                  filePath,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export CSV'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadToServer(BuildContext context, AppState state) async {
    if (state.serverUrl == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Server Not Configured'),
          content: const Text(
            'Please configure the server URL in Settings before uploading.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final result = await state.uploadToServer();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result['success'] ? Icons.check_circle : Icons.error,
              color: result['success'] ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(result['success'] ? 'Upload Successful' : 'Upload Failed'),
          ],
        ),
        content: Text(result['message']),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearData(BuildContext context, AppState state) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data?'),
          ],
        ),
        content: const Text(
          'This will permanently delete all collected notification data. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await state.clearAllData();

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All data cleared')),
      );
    }
  }
}
