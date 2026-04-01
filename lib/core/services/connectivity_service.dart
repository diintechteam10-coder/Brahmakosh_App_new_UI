import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  // Layer 1: Network connectivity (Wifi/Mobile)
  final RxBool isOffline = false.obs;
  
  // Layer 2: Actual internet access (Google/DNS lookup)
  final RxBool hasInternetAccess = true.obs;

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
      await _updateConnectionStatus(results);
    } catch (e) {
      debugPrint("🌐 ConnectivityService: Error checking connectivity: $e");
    }
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> results) async {
    // Layer 1 Check: Physical connection
    bool hasNetwork = results.isNotEmpty && results.any((result) => result != ConnectivityResult.none);
    isOffline.value = !hasNetwork;

    if (!hasNetwork) {
      hasInternetAccess.value = false;
      return;
    }

    // Layer 2 Check: Actual internet access
    hasInternetAccess.value = await checkRealInternetAccess();
  }

  /// Verifies actual internet access by performing a DNS lookup
  /// Returns true if successful, false otherwise
  Future<bool> checkRealInternetAccess() async {
    try {
      // Use a reliable host like google.com or apple.com
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      debugPrint("🌐 ConnectivityService: DNS lookup failed (No Internet)");
      return false;
    } on TimeoutException catch (_) {
      debugPrint("🌐 ConnectivityService: DNS lookup timed out");
      return false;
    } catch (e) {
      debugPrint("🌐 ConnectivityService: Error during internet check: $e");
      return false;
    }
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
