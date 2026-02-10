import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/permission_handler.dart';
import '../services/csv_exporter.dart';
import '../services/api_service.dart';

/// Application state provider (ViewModel in MVVM)
class AppState extends ChangeNotifier {
  final NotificationService _notificationService;
  final PermissionHandler _permissionHandler;
  final CsvExporter _csvExporter;

  List<NotificationModel> _notifications = [];
  Map<String, int> _statistics = {};
  bool _isCollecting = false;
  bool _isLoading = false;
  String? _serverUrl;
  bool _serverConnected = false;

  AppState({String? serverUrl})
      : _serverUrl = serverUrl,
        _notificationService = NotificationService(
          apiService: serverUrl != null ? ApiService(baseUrl: serverUrl) : null,
        ),
        _permissionHandler = PermissionHandler(),
        _csvExporter = CsvExporter() {
    _init();
  }

  // Getters
  List<NotificationModel> get notifications => _notifications;
  Map<String, int> get statistics => _statistics;
  bool get isCollecting => _isCollecting;
  bool get isLoading => _isLoading;
  String? get serverUrl => _serverUrl;
  bool get serverConnected => _serverConnected;

  /// Initialize app state
  Future<void> _init() async {
    _notificationService.setOnNotificationReceived((notification) {
      _notifications.insert(0, notification);
      _updateStatistics();
      notifyListeners();
    });

    await loadNotifications();
  }

  /// Load notifications from database
  Future<void> loadNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      _notifications = await _notificationService.getAllNotifications();
      await _updateStatistics();
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update statistics
  Future<void> _updateStatistics() async {
    try {
      _statistics = await _notificationService.getStatistics();
    } catch (e) {
      print('Error updating statistics: $e');
    }
  }

  /// Check permissions status
  Future<Map<String, bool>> checkPermissions() async {
    return await _permissionHandler.checkAllPermissions();
  }

  /// Request all permissions
  Future<void> requestPermissions() async {
    await _permissionHandler.requestAllPermissions();
    notifyListeners();
  }

  /// Request notification access
  Future<void> requestNotificationAccess() async {
    await _permissionHandler.requestNotificationAccess();
  }

  /// Start notification collection
  void startCollection() {
    _notificationService.startCollection();
    _isCollecting = true;
    notifyListeners();
  }

  /// Stop notification collection
  void stopCollection() {
    _notificationService.stopCollection();
    _isCollecting = false;
    notifyListeners();
  }

  /// Export to CSV
  Future<String?> exportToCsv() async {
    _isLoading = true;
    notifyListeners();

    try {
      final filePath = await _csvExporter.exportToCsv(_notifications);
      return filePath;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get export directory path
  Future<String> getExportDirectoryPath() async {
    return await _csvExporter.getExportDirectoryPath();
  }

  /// Upload to server
  Future<Map<String, dynamic>> uploadToServer() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _notificationService.uploadAllToServer();
      if (result['success']) {
        _serverConnected = true;
      }
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Set server URL
  void setServerUrl(String url) {
    _serverUrl = url;
    notifyListeners();
  }

  /// Check server connection
  Future<bool> checkServerConnection() async {
    if (_serverUrl == null) return false;

    final apiService = ApiService(baseUrl: _serverUrl!);
    _serverConnected = await apiService.checkServerHealth();
    notifyListeners();
    return _serverConnected;
  }

  /// Clear all data
  Future<void> clearAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.clearAllData();
      _notifications.clear();
      _statistics.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadNotifications();
  }
}
