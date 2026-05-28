import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  GeminiService._();
  static final GeminiService instance = GeminiService._();

  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get _url =>
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey';


  Future<String> _callGemini(String prompt) async {
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
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return text?.trim() ?? 'No response received from AI.';
      } else {
        return 'AI service is temporarily unavailable. Code: ${response.statusCode}';
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
