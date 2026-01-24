import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/constants/astrologer_prompt.dart';
import 'utils.dart';

class GeminiService {
  static const String _apiKey = "AIzaSyD2UwyHil5GAMhI4k_jrltfQMFRb6AxRdo";

  static Future<String> askAstrologer({
    required String userMessage,
    String? name,
    String? dob,
    String? timeOfBirth,
    String? placeOfBirth,
    String? gowthra,
  }) async {
    // Try different API versions and models as fallback
    final apiConfigs = [
    // Gemini 3 Flash: Current flagship for speed (released Dec 2025)
  {"version": "v1", "model": "gemini-3-flash"}, 

  // Gemini 2.5 Pro: High-performance stable model
  {"version": "v1", "model": "gemini-2.5-pro"}, 

  // Gemini 2.5 Flash-Lite: Extremely fast and cost-efficient
  {"version": "v1", "model": "gemini-2.5-flash-lite"}, 

  // Preview version for latest experimental features
  {"version": "v1beta", "model": "gemini-3-pro-preview"},
    ];

    for (final config in apiConfigs) {
      try {
        final version = config["version"]!;
        final model = config["model"]!;
        
        final uri = Uri.parse(
          "https://generativelanguage.googleapis.com/$version/models/$model:generateContent?key=$_apiKey",
        );

        // Build birth details section if available
        String birthDetailsSection = "";
        if (dob != null || timeOfBirth != null || placeOfBirth != null || gowthra != null) {
          birthDetailsSection = "\n\nUser's Birth Details:\n";
          if (name != null && name.isNotEmpty) {
            birthDetailsSection += "Name: $name\n";
          }
          if (dob != null && dob.isNotEmpty) {
            birthDetailsSection += "Date of Birth: $dob\n";
          }
          if (timeOfBirth != null && timeOfBirth.isNotEmpty) {
            birthDetailsSection += "Time of Birth: $timeOfBirth\n";
          }
          if (placeOfBirth != null && placeOfBirth.isNotEmpty) {
            birthDetailsSection += "Place of Birth: $placeOfBirth\n";
          }
          if (gowthra != null && gowthra.isNotEmpty) {
            birthDetailsSection += "Gowthra: $gowthra\n";
          }
          birthDetailsSection += "\nUse these birth details to provide accurate Vedic astrology predictions and analysis.";
        }

        final body = {
          "contents": [
            {
              "role": "user",
              "parts": [
                {
                  "text": """
$kAstrologerSystemPrompt$birthDetailsSection

User Question:
$userMessage
"""
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.6,
            "maxOutputTokens": 500,
          }
        };

        Utils.print('Gemini API Request - Version: $version, Model: $model');
        Utils.print('Request URL: ${uri.toString().replaceAll(_apiKey, 'API_KEY_HIDDEN')}');

        final response = await http.post(
          uri,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        Utils.print('Gemini API Response Status: ${response.statusCode}');
        Utils.print('Gemini API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          try {
            final data = jsonDecode(response.body);
            final text = data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"];

            if (text != null && text.toString().trim().isNotEmpty) {
              Utils.print('Successfully got response from $version/$model');
              return text.toString().trim();
            }
          } catch (e) {
            Utils.print('Error parsing response: $e');
            // Try next config
            continue;
          }
        } else {
          // Log error but try next config
          Utils.print('API Error with $version/$model: ${response.body}');
          if (config == apiConfigs.last) {
            // Last config failed, return error message
            try {
              final errorData = jsonDecode(response.body);
              final errorMsg = errorData["error"]?["message"] ?? "Unknown error";
              Utils.print('Final API Error: $errorMsg');
            } catch (e) {
              Utils.print('Could not parse error response');
            }
            return "At this moment, planetary signals are unclear. Please ask again shortly.";
          }
          // Try next config
          continue;
        }
      } catch (e) {
        Utils.print('Exception with ${config["version"]}/${config["model"]}: $e');
        if (config == apiConfigs.last) {
          return "Some planetary energies are unsettled right now. Please try again shortly.";
        }
        // Try next config
        continue;
      }
    }

    // If we get here, all configs failed
    return "At this moment, planetary signals are unclear. Please ask again shortly.";
  }
}
