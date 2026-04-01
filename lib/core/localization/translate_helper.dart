import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import '../services/translation_service.dart';
import '../services/storage_service.dart';

class TranslateHelper {
  static const String _cachePrefix = 'dynamic_translation_v2_';
  static Map<String, String>? _cache;
  static final Map<String, Future<String>> _ongoingRequests = {};
  
  // Accumulator Queue for Batch API
  static final Map<String, Completer<String>> _queue = {};
  static Timer? _debounce;
  static const Duration _debounceDuration = Duration(milliseconds: 50);

  /// Returns the current language code (e.g., 'hi')
  static String get _currentLang => Get.locale?.languageCode ?? 'en';

  /// Returns the persistent cache key for the current language
  static String get _langCacheKey => '$_cachePrefix$_currentLang';

  /// Initializes the cache from local storage.
  static void _initCache() {
    if (_cache != null && StorageService.getString('last_lang') == _currentLang) return;
    
    // Load from persistent storage
    final cachedData = StorageService.getString(_langCacheKey);
    if (cachedData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cachedData);
        _cache = decoded.map((key, value) => MapEntry(key, value.toString()));
        print('⚡ TranslateHelper: Loaded ${_cache!.length} items from persistent cache ($_currentLang)');
      } catch (e) {
        _cache = {};
      }
    } else {
      _cache = {};
    }
    StorageService.setString('last_lang', _currentLang);
  }

  /// Saves the cache to local storage.
  static void _saveCache() {
    if (_cache == null) return;
    StorageService.setString(_langCacheKey, jsonEncode(_cache));
  }

  /// Normalizes the key for lookup
  static String _normalize(String text) => text.trim().toLowerCase();

  /// Smart Dictionary Lookup: Tries multiple formats in GetX Translations
  static String? _tryStaticTranslate(String text) {
    // 1. Exact match
    final exact = text.tr;
    if (exact != text) return exact;

    // 2. Snake case (e.g., "Puja Vidhi" -> "puja_vidhi")
    final snake = text.trim().replaceAll(' ', '_').toLowerCase();
    final snakeTr = snake.tr;
    if (snakeTr != snake) return snakeTr;

    // 3. Lowercase
    final lower = text.trim().toLowerCase();
    final lowerTr = lower.tr;
    if (lowerTr != lower) return lowerTr;

    return null;
  }

  /// Translates [text] to the current language.
  /// Strategy: Static (.tr) → Memory Cache → Persistent Cache → Ongoing Requests → Accumulator/Batch API
  static Future<String> translate(String? text) async {
    if (text == null || text.trim().isEmpty) return '';
    
    // Default language is English, no translation needed if app is in English
    if (_currentLang == 'en') {
      return text;
    }

    // 1. Smart Dictionary Check (Static)
    final staticValue = _tryStaticTranslate(text);
    if (staticValue != null) {
      return staticValue;
    }

    _initCache();
    final key = _normalize(text);

    // 2. Memory/Persistent Cache Check
    if (_cache!.containsKey(key)) {
      return _cache![key]!;
    }

    // 3. Prevent Duplicate Concurrent Requests
    if (_ongoingRequests.containsKey(key)) {
      return await _ongoingRequests[key]!;
    }

    // 4. Batch Accumulator (The Accumulator)
    if (_queue.containsKey(key)) {
      return _queue[key]!.future;
    }

    final completer = Completer<String>();
    _queue[key] = completer;

    _scheduleBatch();

    return completer.future;
  }

  static void _scheduleBatch() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => _processQueue());
  }

  static Future<void> _processQueue() async {
    if (_queue.isEmpty) return;

    final Map<String, Completer<String>> currentQueue = Map.from(_queue);
    _queue.clear();

    final List<String> textsToTranslate = currentQueue.keys.toList();
    final String targetLang = _currentLang;

    print('🚀 TranslateHelper: Accumulator triggering Batch API (Size: ${textsToTranslate.length})');

    try {
      final List<String> results = await TranslationService.translateBatch(
        texts: textsToTranslate,
        targetLanguage: targetLang,
      );

      for (int i = 0; i < textsToTranslate.length; i++) {
        final original = textsToTranslate[i];
        final translated = (i < results.length) ? results[i] : original;
        
        // Cache and complete
        if (translated.isNotEmpty && translated != original) {
          _cache![original] = translated;
        }
        currentQueue[original]?.complete(translated);
      }
      _saveCache();
    } catch (e) {
      print('❌ TranslateHelper Batch Error: $e');
      // Fallback: complete all with original text
      for (final entry in currentQueue.entries) {
        if (!entry.value.isCompleted) {
          entry.value.complete(entry.key);
        }
      }
    }
  }

  /// Translates a list of strings efficiently.
  static Future<List<String>> translateList(List<String>? texts) async {
    if (texts == null || texts.isEmpty) return [];
    
    // Parallelize with the and batch accumulator
    final futures = texts.map((t) => translate(t)).toList();
    return await Future.wait(futures);
  }
}
