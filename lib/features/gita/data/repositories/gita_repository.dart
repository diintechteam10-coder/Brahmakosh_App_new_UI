import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../common/api_services.dart';
import '../../../../common/api_urls.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/chapter_model.dart';
import '../models/verse_model.dart';

class GitaRepository {
  static const String keyChapters = 'gita_chapters_cache';
  static const String keyVersesPrefix = 'gita_verses_chapter_';
  // Verse details might be too many to cache individually effectively or we cache them by ID.
  // The user requirement says "use local storage before fetching into 2nd and 3rd screen".

  /// Fetch Chapters
  Future<List<ChapterModel>> getChapters() async {
    // 1. Try Cache
    try {
      final String? cachedJson = StorageService.getString(keyChapters);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> listProxy = jsonDecode(cachedJson);
        return listProxy.map((e) => ChapterModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error reading chapters cache: $e');
    }

    // 2. Fetch API
    List<ChapterModel> chapters = [];
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";

    await callWebApiGet(
      null,
      ApiUrls.gitaChapters,
      token: token,
      showLoader: false,
      shouldLogoutOn401: false,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          chapters = data.map((e) => ChapterModel.fromJson(e)).toList();

          // 3. Update Cache
          StorageService.setString(keyChapters, jsonEncode(data));
        }
      },
      onError: (e) {
        throw e;
      },
    );

    return chapters;
  }

  /// Fetch Verses by Chapter Number
  Future<List<VerseModel>> getVerses(int chapterNumber) async {
    final String cacheKey = '$keyVersesPrefix$chapterNumber';

    // 1. Try Cache
    try {
      final String? cachedJson = StorageService.getString(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        final List<dynamic> listProxy = jsonDecode(cachedJson);
        return listProxy.map((e) => VerseModel.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('Error reading verses cache: $e');
    }

    // 2. Fetch API
    List<VerseModel> verses = [];
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
    final url =
        '${ApiUrls.gitaVerses}/$chapterNumber?status=published&isActive=true';

    await callWebApiGet(
      null,
      url,
      token: token,
      showLoader: false,
      shouldLogoutOn401: false,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          final List<dynamic> data = body['data'];
          verses = data.map((e) => VerseModel.fromJson(e)).toList();

          // 3. Update Cache
          StorageService.setString(cacheKey, jsonEncode(data));
        }
      },
      onError: (e) {
        throw e;
      },
    );

    return verses;
  }

  /// Fetch Verse Detail
  Future<VerseModel?> getVerseDetail(String verseId) async {
    // For detail, we might check if we already have it in the list cache?
    // But the user specifically asked to use the 3rd API for the 3rd screen.
    // Also "use local storage before fetching into 2nd and 3rd screen".
    // I can cache individual verses or just rely on the list cache if the list has full details.
    // If the list has full details, I can just pass the object.
    // BUT, the prompt says "fetch data from local storage so that data will load smoothly".
    // I will implement caching for this call too.

    final String cacheKey = 'gita_verse_$verseId';

    // 1. Try Cache
    try {
      final String? cachedJson = StorageService.getString(cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return VerseModel.fromJson(jsonDecode(cachedJson));
      }
    } catch (e) {
      debugPrint('Error reading verse detail cache: $e');
    }

    VerseModel? verse;
    final token = StorageService.getString(AppConstants.keyAuthToken) ?? "";
    final url = '${ApiUrls.gitaVerseDetail}/$verseId';

    await callWebApiGet(
      null,
      url,
      token: token,
      showLoader: false,
      shouldLogoutOn401: false,
      onResponse: (response) {
        final body = jsonDecode(response.body);
        // API response structure for single item usually implies data is the object or data contains the object
        // User provided: "this is 3 rd api ... which will use _id ... and which will give me Get single Shlokas"
        // Assuming response format similar to others: { success: true, data: { ... } }
        if (body['success'] == true && body['data'] != null) {
          final dynamic data = body['data'];
          // Check if data is list or map. Sometimes APIs return list of 1.
          if (data is List) {
            if (data.isNotEmpty) {
              verse = VerseModel.fromJson(data.first);
              StorageService.setString(cacheKey, jsonEncode(data.first));
            }
          } else {
            verse = VerseModel.fromJson(data);
            StorageService.setString(cacheKey, jsonEncode(data));
          }
        }
      },
      onError: (e) {
        throw e;
      },
    );

    return verse;
  }
}
