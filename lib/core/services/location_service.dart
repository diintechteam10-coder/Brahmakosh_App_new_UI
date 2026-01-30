import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:brahmakosh/common/utils.dart';

class LocationService {
  /// Checks permissions and gets the current position.
  /// If permission is not granted, it shows a dialog to the user.
  static Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    Utils.print('Initial location permission: $permission');
    if (permission == LocationPermission.denied) {
      Utils.print('Permission denied, requesting permission');
      permission = await Geolocator.requestPermission();
      Utils.print('Permission after request: $permission');
      if (permission == LocationPermission.denied) {
        Utils.showToast('Location permissions are denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Utils.print('Permission denied forever');
      Utils.showToast(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      return null;
    }

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    Utils.print('Location service enabled: $serviceEnabled');
    if (!serviceEnabled) {
      Utils.print('Location service is disabled, showing settings dialog');
      bool? openSettings = await _showServiceDisabledDialog();
      if (openSettings == true) {
        await Geolocator.openLocationSettings();
      }
      return null;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Utils.print('Getting current position...');
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      Utils.print('Position obtained: ${pos.latitude}, ${pos.longitude}');
      return pos;
    } catch (e) {
      Utils.print('Error getting location: $e');
      return null;
    }
  }

  static Future<bool?> _showServiceDisabledDialog() async {
    Utils.print('Displaying service disabled dialog...');
    return await Get.dialog<bool>(
      barrierDismissible: false,
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
          'Location services are disabled on your device. Please enable them to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
