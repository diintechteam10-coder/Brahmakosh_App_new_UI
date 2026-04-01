import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class TranslationService {
  static const String _baseUrl =
      'https://translation.googleapis.com/language/translate/v2';

  /// Translates [text] to [targetLanguage] (e.g., 'hi' for Hindi).
  /// Requires a valid Google Translate API Key in [AppConstants.googleTranslateApiKey].
  static Future<String> translateText({
    required String text,
    required String targetLanguage,
  }) async {
    final apiKey = AppConstants.googleTranslateApiKey;

    if (apiKey.isEmpty) {
      return text;
    }

    try {
      final url = '$_baseUrl?key=$apiKey';
      print('🚀 Google Translate API Hit: $url');
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translatedText =
            data['data']['translations'][0]['translatedText'];
        return translatedText;
      } else {
        print('Translation Error: ${response.statusCode} - ${response.body}');
        return text;
      }
    } catch (e) {
      print('Translation Exception: $e');
      return text;
    }
  }

  /// Translates a list of strings [texts] to [targetLanguage].
  static Future<List<String>> translateBatch({
    required List<String> texts,
    required String targetLanguage,
  }) async {
    final apiKey = AppConstants.googleTranslateApiKey;

    if (apiKey.isEmpty) {
      return texts;
    }

    try {
      final url = '$_baseUrl?key=$apiKey';
      print('🚀 Google Translate Batch API Hit: $url');
      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({
          'q': texts,
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translations = data['data']['translations'] as List;
        return translations.map((t) => t['translatedText'] as String).toList();
      } else {
        print(
          'Batch Translation Error: ${response.statusCode} - ${response.body}',
        );
        return texts;
      }
    } catch (e) {
      print('Batch Translation Exception: $e');
      return texts;
    }
  }
}
