import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../core/utils/logger.dart';

// Service to monitor network connectivity state
// Provides current status and stream of connectivity changes
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  
  // Stream controller for connectivity changes
  final _connectivityController = StreamController<bool>.broadcast();
  
  // Current connectivity state
  bool _isOnline = false;
  
  // Subscription to connectivity changes
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService() {
    _init();
  }

  // INITIALIZATION

  // Initialize connectivity monitoring
  Future<void> _init() async {
    // Check initial connectivity state
    await _checkConnectivity();
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        AppLogger.e('Connectivity stream error', err: error);
      },
    );
  }

  // CONNECTIVITY STATE

  // Get current online/offline state
  bool get isOnline => _isOnline;

  // Get stream of connectivity changes
  // Emits true when online, false when offline
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  // Check current connectivity and update state
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return _isOnline;
  }

  // INTERNAL

  // Check connectivity and update internal state
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectivityState(results);
    } catch (e) {
      AppLogger.e('Failed to check connectivity', err: e);
      _updateConnectivityState([ConnectivityResult.none]);
    }
  }

  // Handle connectivity change events
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _updateConnectivityState(results);
  }

  // Update connectivity state based on results
  void _updateConnectivityState(List<ConnectivityResult> results) {
    // Check if any result indicates online connectivity
    final wasOnline = _isOnline;
    _isOnline = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);

    // Log state change
    if (_isOnline != wasOnline) {
      AppLogger.d('Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"} — ${results.map((r) => r.name).join(", ")}');
      _connectivityController.add(_isOnline);
    }
  }

  // DISPOSE

  // Clean up resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}
