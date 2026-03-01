import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../common/api_services.dart';
import '../../../common/api_urls.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/storage_service.dart';
import '../models/sankalp_model.dart';
import '../models/sankalp_progress_model.dart';

class SankalpRepository {
  Future<List<SankalpModel>> fetchAvailableSankalps() async {
    List<SankalpModel> sankalps = [];
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    // We use a completer or just return the list from the callback
    // But callWebApiGet is void/dynamic and uses callbacks.
    // I'll wrap it in a clean Future.

    // Actually callWebApiGet returns 'responseJson' dynamic or throws.
    // Use the onResponse callback to parse.

    /* 
       The response structure for /api/sankalp is:
       {
           "success": true,
           "data": [ ... ],
           "count": 5
       }
    */

    await callWebApiGet(
      null, // TickerProvider is optinal, avoiding UI loader here if handled by Bloc
      ApiUrls.sankalpList,
      token: token,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          sankalps = (body['data'] as List)
              .map((e) => SankalpModel.fromJson(e))
              .toList();
        }
      },
      showLoader: false,
      hideLoader: false,
    );

    return sankalps;
  }

  Future<List<UserSankalpModel>> fetchUserSankalps() async {
    List<UserSankalpModel> userSankalps = [];
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    /*
      Response for /api/user-sankalp/my-sankalpas:
      {
          "success": true,
          "data": [ ... ],
          "count": 1
      }
    */

    await callWebApiGet(
      null,
      ApiUrls.userSankalps,
      token: token,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        debugPrint("=== USER SANKALPS API RAW RESPONSE: ${response.body}");
        if (body['success'] == true && body['data'] != null) {
          userSankalps = (body['data'] as List)
              .map((e) => UserSankalpModel.fromJson(e))
              .toList();
        }
      },
      showLoader: false,
      hideLoader: false,
    );

    return userSankalps;
  }

  Future<UserSankalpModel?> joinSankalp({
    required String sankalpId,
    required int customDays,
    required String reminderTime,
  }) async {
    UserSankalpModel? result;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    /*
      Request: { 
        "sankalpId": "...",
        "customDays": 21,
        "reminderTime": "09:00"
      }
      Response:
      {
          "success": true,
          "message": "Successfully joined sankalp",
          "data": { ... }
      }
    */

    await callWebApi(
      null,
      ApiUrls.joinSankalp,
      {
        'sankalpId': sankalpId,
        'customDays': customDays,
        'reminderTime': reminderTime,
      },
      token: token,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          result = UserSankalpModel.fromJson(body['data']);
        }
      },
      showLoader: false,
      hideLoader: false,
    );

    return result;
  }

  Future<Map<String, dynamic>> reportDailyStatus(
    String userSankalpId,
    String status,
  ) async {
    Map<String, dynamic> result = {
      'success': false,
      'message': 'Failed to report status',
    };
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    await callWebApi(
      null,
      '${ApiUrls.userSankalpBase}/$userSankalpId/report',
      {'status': status},
      token: token,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        if (body['success'] == true) {
          result = {
            'success': true,
            'message': body['message'] ?? 'Report submitted successfully',
            'data': body['data'],
          };
        } else {
          result['message'] = body['message'] ?? 'Failed to report status';
        }
      },
      showLoader: true, // Show loader for user action
      hideLoader: true,
    );

    return result;
  }

  Future<SankalpModel?> fetchSankalpDetail(String sankalpId) async {
    SankalpModel? sankalp;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    if (sankalpId.isEmpty) {
      debugPrint("Error: fetchSankalpDetail called with empty sankalpId");
      return null;
    }

    await callWebApiGet(
      null,
      '${ApiUrls.sankalpList}/$sankalpId',
      token: token,
      onResponse: (response) {
        debugPrint(
          "fetchSankalpDetail response: ${response.statusCode} ${response.body}",
        );
        try {
          final body = jsonDecode(response.body);
          if (body['success'] == true && body['data'] != null) {
            // Validate data type to prevent cast errors
            if (body['data'] is Map<String, dynamic>) {
              sankalp = SankalpModel.fromJson(body['data']);
            } else {
              debugPrint(
                "Error: fetchSankalpDetail expected Map but got ${body['data'].runtimeType}",
              );
            }
          } else {
            debugPrint(
              "Error: fetchSankalpDetail success was false or data null. Body: $body",
            );
          }
        } catch (e) {
          debugPrint("Error parsing fetchSankalpDetail response: $e");
        }
      },
      showLoader: false,
      hideLoader: false,
    );

    return sankalp;
  }

  Future<SankalpProgressModel?> fetchSankalpProgress(
    String userSankalpId,
  ) async {
    SankalpProgressModel? progress;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    if (userSankalpId.isEmpty) {
      debugPrint("Error: fetchSankalpProgress called with empty userSankalpId");
      return null;
    }

    // API: /api/user-sankalp/:id/progress
    await callWebApiGet(
      null,
      '${ApiUrls.userSankalpBase}/$userSankalpId/progress',
      token: token,
      onResponse: (response) {
        try {
          final body = jsonDecode(response.body);
          debugPrint("=== PROGRESS API RAW RESPONSE: ${response.body}");
          if (body['success'] == true && body['data'] != null) {
            progress = SankalpProgressModel.fromJson(body['data']);
          } else {
            debugPrint("Error fetching progress: ${body['message']}");
          }
        } catch (e) {
          debugPrint("Error parsing progress response: $e");
        }
      },
      showLoader: false,
      hideLoader: false,
    );

    return progress;
  }
}
