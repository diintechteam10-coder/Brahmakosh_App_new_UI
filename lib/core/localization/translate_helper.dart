import 'dart:convert';
import 'package:get/get.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';

class TranslateHelper {
  static const String _cacheKey = 'dynamic_translation_cache_hi_v2';
  static Map<String, String>? _cache;
  static final Map<String, Future<String>> _ongoingRequests = {};

  /// Initializes the cache from local storage.
  static void _initCache() {
    if (_cache != null) return;
    
    // Load from persistent storage
    final cachedData = StorageService.getString(_cacheKey);
    if (cachedData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cachedData);
        _cache = decoded.map((key, value) => MapEntry(key, value.toString()));
        print('⚡ TranslateHelper: Loaded ${_cache!.length} items from persistent cache');
      } catch (e) {
        _cache = {};
      }
    } else {
      _cache = {};
    }
  }

  /// Saves the cache to local storage.
  static void _saveCache() {
    if (_cache == null) return;
    StorageService.setString(_cacheKey, jsonEncode(_cache));
  }

  /// Normalizes the key for lookup
  static String _normalize(String text) => text.trim().toLowerCase();

  /// Translates [text] to Hindi if the current locale is Hindi.
  /// Priority: Static Dictionary -> Memory Cache -> Ongoing Request -> API
  static Future<String> translate(String? text) async {
    if (text == null || text.trim().isEmpty) return '';
    
    // Only translate if the current locale is Hindi
    if (Get.locale?.languageCode != 'hi') {
      return text;
    }

    // 1. Static Dictionary Check (FASTEST)
    final localValue = text.tr;
    if (localValue != text) {
      return localValue;
    }

    // 1b. Try lowercase dictionary check
    final lowerText = text.toLowerCase();
    final lowerLocal = lowerText.tr;
    if (lowerLocal != lowerText) {
      return lowerLocal;
    }

    _initCache();
    final key = _normalize(text);

    // 2. Memory Cache Check
    if (_cache!.containsKey(key)) {
      return _cache![key]!;
    }

    // 3. Prevent Duplicate Concurrent Requests
    if (_ongoingRequests.containsKey(key)) {
      print('⏳ TranslateHelper: Waiting for ongoing request for "$text"');
      return await _ongoingRequests[key]!;
    }

    // 4. API Call
    print('🚀 TranslateHelper: API Hit for "$text"');
    final translationFuture = _performTranslation(text, key);
    _ongoingRequests[key] = translationFuture;

    try {
      final result = await translationFuture;
      _ongoingRequests.remove(key);
      return result;
    } catch (e) {
      _ongoingRequests.remove(key);
      return text;
    }
  }

  static Future<String> _performTranslation(String original, String key) async {
    try {
      final translated = await TranslationService.translateText(
        text: original,
        targetLanguage: 'hi',
      );
      
      if (translated.isNotEmpty && translated != original) {
        _cache![key] = translated;
        _saveCache();
      }
      return translated;
    } catch (e) {
      print('❌ TranslateHelper Error: $e');
      return original;
    }
  }

  /// Translates a list of strings to Hindi.
  static Future<List<String>> translateList(List<String>? texts) async {
    if (texts == null || texts.isEmpty) return [];
    
    if (Get.locale?.languageCode != 'hi') {
      return texts;
    }

    List<String> results = List.filled(texts.length, '');
    List<int> missingIndices = [];
    List<String> missingTexts = [];

    for (int i = 0; i < texts.length; i++) {
      final t = texts[i];
      if (t.isEmpty) {
        results[i] = '';
        continue;
      }

      // Check Static Dictionary
      final local = t.tr;
      if (local != t) {
        results[i] = local;
        continue;
      }

      _initCache();
      final key = _normalize(t);

      // Check Cache
      if (_cache!.containsKey(key)) {
        results[i] = _cache![key]!;
        continue;
      }

      // Check Ongoing
      if (_ongoingRequests.containsKey(key)) {
        // We handle this by adding to missing and letting the logic wait later, 
        // but for list it's easier to just call translate individually for these edge cases or wait here.
        results[i] = await translate(t); 
        continue;
      }

      missingIndices.add(i);
      missingTexts.add(t);
    }

    if (missingIndices.isEmpty) return results;

    try {
      print('🚀 TranslateHelper: Batch API Hit for ${missingTexts.length} items');
      final translatedList = await TranslationService.translateBatch(
        texts: missingTexts,
        targetLanguage: 'hi',
      );

      for (int i = 0; i < missingIndices.length; i++) {
        final original = missingTexts[i];
        final translated = translatedList[i];
        final key = _normalize(original);
        
        results[missingIndices[i]] = translated;
        
        if (translated.isNotEmpty && translated != original) {
          _cache![key] = translated;
        }
      }
      _saveCache();
      
      return results;
    } catch (e) {
      print('❌ TranslateHelper Batch Error: $e');
      for (int i = 0; i < missingIndices.length; i++) {
        results[missingIndices[i]] = missingTexts[i];
      }
      return results;
    }
  }
}

