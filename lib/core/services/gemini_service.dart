import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  static String get _apiKey => (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
  static String get _url =>
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$_apiKey';

  Future<String> _callGemini(String prompt) async {
    if (_apiKey.isEmpty) {
      return 'Error: GEMINI_API_KEY is not configured in your .env file.';
    }

    try {
      final response = await http.post(
        Uri.parse(_url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          // Gemini 2.5 may include "thought" parts before the actual text.
          // Find the last part that has a 'text' key (skip thought-only parts).
          for (int i = parts.length - 1; i >= 0; i--) {
            final part = parts[i];
            if (part['text'] != null && part['thought'] != true) {
              return (part['text'] as String).trim();
            }
          }
          // Fallback: return the last part's text even if marked as thought
          final lastText = parts.last['text'] as String?;
          if (lastText != null) return lastText.trim();
        }
        return 'No response received from AI.';
      } else {
        print('Gemini API Error (${response.statusCode}): ${response.body}');
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error']?['message'] as String?;
          if (errorMessage != null) {
            return 'AI Error: $errorMessage (Code: ${response.statusCode})';
          }
        } catch (_) {}
        return 'AI service returned error code: ${response.statusCode}';
      }
    } catch (e) {
      return 'Failed to reach AI helper: $e';
    }
  }

  Future<String> improveText(String text) async {
    final prompt = 'You are a professional editor. Please proofread, correct spelling/grammar, and improve the flow of this note content. Keep the formatting clean and maintain the original tone. Return ONLY the improved note text without any introductory remarks or explanations:\n\n$text';
    return await _callGemini(prompt);
  }

  Future<String> suggestTitle(String title, String body) async {
    final prompt = 'Suggest a single concise, engaging, and premium title (maximum 6 words) for a note with this title suggestion "$title" and this body text:\n\n$body\n\nReturn ONLY the suggested title, no punctuation quotes, no explanations:';
    return await _callGemini(prompt);
  }

  Future<String> fixMispronunciations(String spokenText) async {
    final prompt = 'The following text is transcribed from a voice recording and may contain verbal slips, homophone spelling errors, phonetic mispronunciations, or spelling slip-ups. Clean it up, correct homophones, and ensure proper capitalization and syntax. Return ONLY the polished, correct text without notes or comments:\n\n$spokenText';
    return await _callGemini(prompt);
  }
}
