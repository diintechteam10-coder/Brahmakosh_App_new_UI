import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../common/api_urls.dart';
import '../models/pooja_model.dart';
import 'package:flutter/foundation.dart';

class PoojaRepository {
  Future<List<PoojaModel>> fetchPoojas() async {
    try {
      if (kDebugMode) {
        print('Fetching poojas from: ${ApiUrls.poojaList}');
      }
      final response = await http.get(Uri.parse(ApiUrls.poojaList));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PoojaModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load poojas: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching poojas: $e');
      }
      rethrow;
    }
  }

  Future<PoojaModel> fetchPoojaDetail(String id) async {
    try {
      final url = '${ApiUrls.poojaList}/$id';
      if (kDebugMode) {
        print('Fetching pooja detail from: $url');
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        return PoojaModel.fromJson(data);
      } else {
        throw Exception('Failed to load pooja detail: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching pooja detail: $e');
      }
      rethrow;
    }
  }
}
