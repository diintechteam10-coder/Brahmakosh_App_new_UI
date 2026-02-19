import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/api_urls.dart';
import '../models/swapna_model.dart';
import '../models/dream_request_model.dart';
import 'dart:developer';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';

class SwapnaRepository {
  Future<String?> _getToken() async {
    // START: Fix for token retrieval
    // final prefs = await SharedPreferences.getInstance();
    // return prefs.getString('auth_token');

    // Using StorageService to ensure consistency with the rest of the app
    // and using the correct key from AppConstants
    return StorageService.getString(AppConstants.keyAuthToken);
    // END: Fix for token retrieval
  }

  // Fetch all Swapna Symbols
  Future<List<SwapnaModel>> fetchSwapnaList() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.swapnaDecoder),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Swapna List Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => SwapnaModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load swapna list');
      }
    } catch (e) {
      throw Exception('Error fetching swapna list: $e');
    }
  }

  // Fetch Single Swapna Detail
  Future<SwapnaModel> fetchSwapnaDetail(String id) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.swapnaDecoder}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SwapnaModel.fromJson(data);
      } else {
        throw Exception('Failed to load swapna detail');
      }
    } catch (e) {
      throw Exception('Error fetching swapna detail: $e');
    }
  }

  // Create Dream Request
  Future<DreamRequestModel> createDreamRequest({
    required String dreamSymbol,
    required String additionalDetails,
    required String clientId,
  }) async {
    print("SwapnaRepository: createDreamRequest called");
    final token = await _getToken();
    print("SwapnaRepository: Token retrieved: ${token != null ? 'Yes' : 'No'}");

    try {
      final url = Uri.parse(ApiUrls.dreamRequests);
      print("SwapnaRepository: URL: $url");

      final body = json.encode({
        'dreamSymbol': dreamSymbol,
        'additionalDetails': additionalDetails,
        'clientId': clientId,
      });
      print("SwapnaRepository: Body: $body");

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body,
      );

      print('SwapnaRepository: Response Status: ${response.statusCode}');
      print('SwapnaRepository: Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        // The API returns { message: "...", data: { ... } }
        return DreamRequestModel.fromJson(data['data']);
      } else {
        print('SwapnaRepository: Failed with status ${response.statusCode}');
        throw Exception('Failed to create dream request');
      }
    } catch (e) {
      print('SwapnaRepository: Exception caught: $e');
      throw Exception('Error creating dream request: $e');
    }
  }

  // Fetch User Dream Requests
  Future<List<DreamRequestModel>> fetchDreamRequests() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse(ApiUrls.dreamRequests),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      log('Dream Requests Response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => DreamRequestModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load dream requests');
      }
    } catch (e) {
      throw Exception('Error fetching dream requests: $e');
    }
  }

  // Fetch Single Dream Request Detail
  Future<DreamRequestModel> fetchDreamRequestDetail(String id) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiUrls.dreamRequests}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DreamRequestModel.fromJson(data);
      } else {
        throw Exception('Failed to load dream request detail');
      }
    } catch (e) {
      throw Exception('Error fetching dream request detail: $e');
    }
  }
}
