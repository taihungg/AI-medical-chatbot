import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static String get geminiModel =>
      dotenv.env['GEMINI_MODEL'] ?? 'gemini-2.5-flash';

  static bool get hasGeminiApiKey => geminiApiKey.trim().isNotEmpty &&
      geminiApiKey != 'your_api_key_here';
}
