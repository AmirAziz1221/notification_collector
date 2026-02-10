import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/app_state.dart';
import 'collection_tab.dart';
import 'data_tab.dart';
import 'settings_tab.dart';

/// Main home screen with tab navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    CollectionTab(),
    DataTab(),
    SettingsTab(),
  ];

  @override
  void initState() {
    super.initState();
    _showPrivacyDisclaimer();
  }

  /// Show privacy disclaimer on first launch
  void _showPrivacyDisclaimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.privacy_tip, color: Colors.orange),
              SizedBox(width: 8),
              Text('Privacy Notice'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This app collects notification data for research purposes.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('What we collect:'),
                SizedBox(height: 8),
                Text('• Notification preview text (truncated messages)'),
                Text('• Full message content (where accessible)'),
                Text('• Sender information'),
                Text('• App package names'),
                Text('• Timestamps'),
                SizedBox(height: 12),
                Text(
                  'Data Usage:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Data is stored locally on your device'),
                Text('• You control when to export or upload data'),
                Text('• All data transmission is voluntary'),
                Text('• You can delete all data at any time'),
                SizedBox(height: 12),
                Text(
                  'Required Permissions:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Notification Access: To read notifications'),
                Text('• SMS Read: To access full SMS content'),
                Text('• Storage: To export CSV files'),
                SizedBox(height: 12),
                Text(
                  'Please ensure you have consent to collect this data and understand the privacy implications.',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('I Understand'),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Research'),
        actions: [
          Consumer<AppState>(
            builder: (context, state, _) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: state.isCollecting ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          state.isCollecting
                              ? Icons.fiber_manual_record
                              : Icons.stop,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          state.isCollecting ? 'Collecting' : 'Stopped',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Collection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_usage),
            label: 'Data',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
