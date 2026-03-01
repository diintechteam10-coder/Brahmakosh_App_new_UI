import 'dart:convert';

import 'package:brahmakosh/common/api_services.dart';
import 'package:brahmakosh/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/common_imports.dart';
import '../../../common/utils.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel() {
    Utils.print("DashboardViewModel created");
    print("DashboardViewModel created (standard print)");
  }

  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

  void changeTab(int index) {
    if (_currentIndex == index) return;

    _currentIndex = index;
    notifyListeners();
  }

  bool _locationCalled = false;
  String? _userLocationAddress;
  String? get userLocationAddress => _userLocationAddress;

  Future<void> initLocationUpdate(
    TickerProvider? tickerProvider, {
    bool forceRefresh = false,
  }) async {
    print('initLocationUpdate called (standard print)');
    Utils.print(
      'initLocationUpdate called, current _locationCalled: $_locationCalled, force: $forceRefresh',
    );
    // if (_locationCalled && !forceRefresh) return;
    // _locationCalled = true;

    // Load cached location if available
    _userLocationAddress = StorageService.getString(
      AppConstants.keyUserLocation,
    );

    // Clear corrupted cache if found
    if (_userLocationAddress == ", " || _userLocationAddress == "") {
      _userLocationAddress = "Detecting location...";
    }

    try {
      print('DEBUG: Starting current location fetch...');
      Utils.print('Fetching current location...');
      Position? position = await LocationService.getCurrentLocation();
      print('DEBUG: Current position result: $position');
      Utils.print('LocationService.getCurrentLocation result: $position');
      if (position != null) {
        print('DEBUG: Updating location on server...');
        Utils.print(
          'Updating user location on server: ${position.latitude}, ${position.longitude}',
        );
        await updateUserLocation(
          tickerProvider,
          position.latitude,
          position.longitude,
        );

        // Fetch reverse geocode address
        print('DEBUG: Calling getReverseGeocode...');
        Utils.print('Fetching reverse geocode...');
        final locResult = await getReverseGeocode(
          tickerProvider,
          position.latitude,
          position.longitude,
        );

        print(
          'DEBUG: getReverseGeocode call finished. Result success: ${locResult?.success}',
        );
        Utils.print('Reverse Geocode Model Success: ${locResult?.success}');

        Utils.print(
          'Reverse geocode result: ${jsonEncode(locResult?.toJson())}',
        );

        final loc = locResult?.data?.location;
        if (loc?.city != null &&
            loc!.city!.isNotEmpty &&
            loc.state != null &&
            loc.state!.isNotEmpty) {
          _userLocationAddress = "${loc.city}, ${loc.state}";
          await StorageService.setString(
            AppConstants.keyUserLocation,
            _userLocationAddress!,
          );

          Utils.print(
            'Location address updated to City, State: $_userLocationAddress',
          );
          notifyListeners();
        } else if (loc?.formattedAddress != null &&
            loc!.formattedAddress!.isNotEmpty) {
          // If city/state are empty but we have a formattedAddress
          // Check if it's a Plus Code (starts with alphanumeric-plus-alphanumeric)
          bool isPlusCode = RegExp(
            r'^[A-Z0-9]{4,8}\+[A-Z0-9]{2,3}',
          ).hasMatch(loc.formattedAddress!);

          if (isPlusCode) {
            // Fallback if city/state are empty and we only have a plus code
            // You can try to show something else or just the coordinates
            _userLocationAddress = "India"; // Generic fallback
          } else {
            _userLocationAddress = loc.formattedAddress;
          }

          await StorageService.setString(
            AppConstants.keyUserLocation,
            _userLocationAddress!,
          );
          Utils.print(
            'Location address updated using formattedAddress: $_userLocationAddress',
          );
          notifyListeners();
        } else {
          Utils.print(
            'No valid address fields found (city: "${loc?.city}", state: "${loc?.state}", formatted: "${loc?.formattedAddress}")',
          );
          _userLocationAddress = "Location active"; // Generic status
          notifyListeners();
        }
      } else {
        Utils.print('Position is null, update skipped.');
      }
    } catch (e) {
      Utils.print("Error in initLocationUpdate: $e");
    }
  }
}
