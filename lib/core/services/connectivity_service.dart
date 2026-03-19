import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Observable state for offline status
  final RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      _updateConnectionStatus(results);
    });
    
    // Check initial status after the app is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialStatus();
    });
  }

  Future<void> _checkInitialStatus() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint("🌐 ConnectivityService: Error checking connectivity: $e");
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    // Robust check for connection
    bool hasConnection = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
    
    // Update observable state
    isOffline.value = !hasConnection;
  }

  void refreshConnectivity() {
    _checkInitialStatus();
  }

  @override
  void onClose() {
    _connectivitySubscription.cancel();
    super.onClose();
  }
}
