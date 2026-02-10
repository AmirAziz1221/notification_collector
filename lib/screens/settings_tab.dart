import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../viewmodels/app_state.dart';

/// Tab for app settings and configuration
class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final TextEditingController _serverUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrlController.text = prefs.getString('server_url') ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', _serverUrlController.text);

    if (!mounted) return;

    final state = Provider.of<AppState>(context, listen: false);
    state.setServerUrl(_serverUrlController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Server Configuration Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Configuration',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Configure FastAPI backend server for data upload',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _serverUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Server URL',
                          hintText: 'http://192.168.1.100:8000',
                          prefixIcon: Icon(Icons.cloud),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveSettings,
                              icon: const Icon(Icons.save),
                              label: const Text('Save Settings'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () async {
                              state.setServerUrl(_serverUrlController.text);
                              final connected =
                                  await state.checkServerConnection();

                              if (!context.mounted) return;

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Row(
                                    children: [
                                      Icon(
                                        connected
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: connected
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(connected ? 'Connected' : 'Failed'),
                                    ],
                                  ),
                                  content: Text(
                                    connected
                                        ? 'Successfully connected to server'
                                        : 'Could not connect to server. Please check the URL.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.wifi_tethering),
                            label: const Text('Test'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Export Location Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Export Location',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<String>(
                        future: state.getExportDirectoryPath(),
                        builder: (context, snapshot) {
                          return Row(
                            children: [
                              const Icon(Icons.folder, color: Colors.blue),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'CSV files will be saved to:',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      snapshot.data ?? 'Loading...',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // App Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(),
                      _buildInfoRow('App Name', 'Notification Collector'),
                      _buildInfoRow('Version', '1.0.0'),
                      _buildInfoRow('Purpose', 'Research Data Collection'),
                      const SizedBox(height: 12),
                      const Text(
                        'Database Schema',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• id (INTEGER PRIMARY KEY)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            Text('• package_name (TEXT)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            Text('• sender_name (TEXT)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            Text('• truncated_message (TEXT)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            Text('• full_message (TEXT)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            Text('• message_type (TEXT)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                            Text('• timestamp (INTEGER)',
                                style: TextStyle(
                                    fontSize: 11, fontFamily: 'monospace')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Privacy Notice
              Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.privacy_tip, color: Colors.orange),
                          SizedBox(width: 8),
                          Text(
                            'Privacy & Data Protection',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text(
                        '• All data is stored locally on your device\n'
                        '• You have full control over when to export/upload\n'
                        '• No automatic data transmission\n'
                        '• Data can be deleted at any time\n'
                        '• Use only for authorized research purposes\n'
                        '• Ensure compliance with privacy regulations',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _serverUrlController.dispose();
    super.dispose();
  }
}
