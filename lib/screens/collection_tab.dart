import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_state.dart';

/// Tab for controlling notification collection
class CollectionTab extends StatelessWidget {
  const CollectionTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Status Card
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        state.isCollecting
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        size: 64,
                        color: state.isCollecting ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        state.isCollecting
                            ? 'Collection Active'
                            : 'Collection Stopped',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.isCollecting
                            ? 'Collecting notification data...'
                            : 'Press START to begin collecting',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Control Button
              ElevatedButton.icon(
                onPressed: state.isCollecting
                    ? () => state.stopCollection()
                    : () => state.startCollection(),
                icon: Icon(state.isCollecting ? Icons.stop : Icons.play_arrow),
                label: Text(state.isCollecting
                    ? 'STOP COLLECTION'
                    : 'START COLLECTION'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor:
                      state.isCollecting ? Colors.red : Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 24),

              // Statistics Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildStatItem(
                        'Total Notifications',
                        state.statistics['total']?.toString() ?? '0',
                        Icons.notifications,
                      ),
                      _buildStatItem(
                        'With Full Message',
                        state.statistics['with_full_message']?.toString() ??
                            '0',
                        Icons.check_circle,
                        Colors.green,
                      ),
                      _buildStatItem(
                        'Preview Only',
                        state.statistics['without_full_message']?.toString() ??
                            '0',
                        Icons.cancel,
                        Colors.orange,
                      ),
                      const Divider(),
                      _buildStatItem(
                        'SMS Messages',
                        state.statistics['SMS']?.toString() ?? '0',
                        Icons.sms,
                      ),
                      _buildStatItem(
                        'WhatsApp Messages',
                        state.statistics['WhatsApp']?.toString() ?? '0',
                        Icons.chat,
                      ),
                      _buildStatItem(
                        'Other Messages',
                        state.statistics['Other']?.toString() ?? '0',
                        Icons.apps,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Permissions Status
              FutureBuilder<Map<String, bool>>(
                future: state.checkPermissions(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  final permissions = snapshot.data!;
                  final allGranted = permissions.values.every((v) => v);

                  return Card(
                    color: allGranted
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                allGranted ? Icons.check_circle : Icons.warning,
                                color:
                                    allGranted ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Permissions',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const Divider(),
                          _buildPermissionItem(
                            'Notification Access',
                            permissions['notification'] ?? false,
                          ),
                          _buildPermissionItem(
                            'SMS Read',
                            permissions['sms'] ?? false,
                          ),
                          _buildPermissionItem(
                            'Storage',
                            permissions['storage'] ?? false,
                          ),
                          if (!allGranted) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await state.requestPermissions();
                                if (!permissions['notification']!) {
                                  await state.requestNotificationAccess();
                                }
                              },
                              icon: const Icon(Icons.security),
                              label: const Text('Grant Permissions'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      [Color? color]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String label, bool granted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: granted ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}
