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

  /// Proofread, correct grammar/spelling, and improve flow.
  Future<String> improveText(String text) async {
    final prompt =
        'You are a professional editor. Please proofread, correct spelling/grammar, '
        'and improve the flow of this note content. Keep the formatting clean and '
        'maintain the original tone. Return ONLY the improved note text without any '
        'introductory remarks or explanations:\n\n$text';
    return await _callGemini(prompt);
  }

  /// Suggest a concise, engaging title.
  Future<String> suggestTitle(String title, String body) async {
    final prompt =
        'Suggest a single concise, engaging, and premium title (maximum 6 words) '
        'for a note with this title suggestion "$title" and this body text:\n\n$body\n\n'
        'Return ONLY the suggested title, no punctuation quotes, no explanations:';
    return await _callGemini(prompt);
  }

  /// Fix phonetic mispronunciations from voice transcription.
  Future<String> fixMispronunciations(String spokenText) async {
    final prompt =
        'The following text is transcribed from a voice recording and may contain '
        'verbal slips, homophone spelling errors, phonetic mispronunciations, or '
        'spelling slip-ups. Clean it up, correct homophones, and ensure proper '
        'capitalization and syntax. Return ONLY the polished, correct text without '
        'notes or comments:\n\n$spokenText';
    return await _callGemini(prompt);
  }

  /// Reorganize note content into clean bullet points.
  Future<String> organizeBulletPoints(String text) async {
    final prompt =
        'Reorganize the following note content into clean, well-structured bullet '
        'points. Use markdown bullet syntax (- ). Group related ideas together. '
        'Preserve all key information but make it scannable. Return ONLY the '
        'bullet-point version without any introductory remarks:\n\n$text';
    return await _callGemini(prompt);
  }

  /// Expand and add more detail to note content.
  Future<String> expandDetails(String text) async {
    final prompt =
        'You are a helpful writing assistant. Expand the following note by adding '
        'more detail, context, and elaboration to each point. Keep the same tone '
        'and structure but make it more comprehensive and informative. Return ONLY '
        'the expanded text without any introductory remarks:\n\n$text';
    return await _callGemini(prompt);
  }

  /// Summarize note content into key takeaways.
  Future<String> summarize(String text) async {
    final prompt =
        'Summarize the following note content into its key takeaways. Be concise '
        'but capture all essential points. Use 2-5 sentences maximum. Return ONLY '
        'the summary without any introductory remarks:\n\n$text';
    return await _callGemini(prompt);
  }

  /// Convert casual text to formal/professional tone.
  Future<String> makeFormal(String text) async {
    final prompt =
        'Rewrite the following note in a formal, professional tone. Maintain all '
        'the original information and meaning but elevate the language to be '
        'suitable for professional or academic contexts. Return ONLY the rewritten '
        'text without any introductory remarks:\n\n$text';
    return await _callGemini(prompt);
  }

  /// Run a custom user-provided instruction against note text.
  Future<String> customPrompt(String text, String instruction) async {
    final prompt =
        'You are an AI note assistant. The user has the following note:\n\n'
        '---\n$text\n---\n\n'
        'The user\'s instruction: $instruction\n\n'
        'Apply the instruction to the note and return ONLY the resulting text '
        'without any introductory remarks, explanations, or commentary:';
    return await _callGemini(prompt);
  }
}
