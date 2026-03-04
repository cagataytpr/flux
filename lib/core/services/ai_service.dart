/// Flux Application - AI Service
///
/// Provides Gemini-powered receipt analysis and savings suggestions
/// using direct HTTP REST requests to the stable v1 API.
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../features/transactions/domain/transaction_model.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

/// Provides a singleton [AiService] instance.
final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Makes direct REST API calls to the STABLE v1 Gemini endpoint.
class AiService {
  final String _apiKey;

  static const String _model = 'gemini-2.5-flash';

  AiService() : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '' {
    // ignore: avoid_print
    print('[AiService] API key ${_apiKey.isEmpty ? "MISSING" : "loaded"}');
  }

  /// Helper to send a POST request strictly to the v1 API route.
  Future<String?> _postToGemini(Map<String, dynamic> requestBody) async {
    if (_apiKey.isEmpty) {
      // ignore: avoid_print
      print('[AiService] Error: GEMINI_API_KEY is empty');
      return null;
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent?key=$_apiKey',
    );

    // ignore: avoid_print
    print('[AiService] 🚀 Launching request with Gemini 2.5 Flash...');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Clean Log: Only print status code
      // ignore: avoid_print
      print('[AiService] HTTP Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final text = json['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        return text;
      } else {
        // ignore: avoid_print
        print('[AiService] API Error: ${response.body}');
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      // ignore: avoid_print
      print('[AiService] Request Failed: $e');
      rethrow;
    }
  }

  // -------------------------------------------------------------------------
  // Receipt Analysis
  // -------------------------------------------------------------------------

  /// Analyses a receipt image and returns structured transaction data.
  Future<Map<String, dynamic>?> analyzeReceipt(Uint8List imageBytes) async {
    try {
      const prompt = 'Analyze this Turkish receipt. The currency is Turkish Lira (TL). '
          'Extract the total amount as a number only. '
          'Example: If it\'s 150,50 TL, return 150.50. Format the date as YYYY-MM-DD. '
          'Categories should be in Turkish (Market, Yemek, Ulaşım, Eğlence, Diğer). '
          'Return valid JSON only: '
          '{"title": "...", "amount": 0.0, "date": "...", "category": "..."}.';

      final base64Image = base64Encode(imageBytes);

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image
                }
              }
            ]
          }
        ]
      };

      final text = await _postToGemini(requestBody);
      if (text == null || text.isEmpty) return null;

      // ── Try to extract valid JSON ──
      final parsed = _extractJson(text);
      if (parsed == null) return null;

      // ── Normalise fields with safe defaults ──
      parsed['title'] = (parsed['title'] ?? '').toString();
      if ((parsed['title'] as String).isEmpty) {
        parsed['title'] = 'Bilinmeyen Mağaza';
      }

      final rawAmount = parsed['amount'];
      if (rawAmount is num) {
        parsed['amount'] = rawAmount.toDouble();
      } else if (rawAmount is String) {
        // Handle Turkish comma decimals (150,50 -> 150.50)
        final formattedString = rawAmount.replaceAll(',', '.').replaceAll(RegExp(r'[^\d.]'), '');
        parsed['amount'] = double.tryParse(formattedString) ?? 0.0;
      } else {
        parsed['amount'] = 0.0;
      }

      final rawDate = parsed['date'];
      if (rawDate is String && rawDate.isNotEmpty) {
        try {
          DateTime.parse(rawDate);
        } catch (_) {
          parsed['date'] = DateTime.now().toIso8601String().split('T').first;
        }
      } else {
        parsed['date'] = DateTime.now().toIso8601String().split('T').first;
      }

      final rawCat = (parsed['category'] ?? '').toString().toLowerCase().trim();
      if (rawCat.isEmpty) {
        parsed['category'] = 'market';
      } else {
        parsed['category'] = rawCat;
      }

      return parsed;
    } catch (e) {
      // ignore: avoid_print
      print('analyzeReceipt error: $e');
      rethrow;
    }
  }

  /// Attempts to extract a JSON object from potentially messy AI text.
  Map<String, dynamic>? _extractJson(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'```json\s*', multiLine: true), '')
        .replaceAll(RegExp(r'```\s*', multiLine: true), '')
        .trim();

    try {
      final result = jsonDecode(cleaned);
      if (result is Map<String, dynamic>) return result;
    } catch (_) {}

    final match = RegExp(r'\{[\s\S]*\}').firstMatch(cleaned);
    if (match != null) {
      try {
        final result = jsonDecode(match.group(0)!);
        if (result is Map<String, dynamic>) return result;
      } catch (_) {}
    }

    return null;
  }

  // -------------------------------------------------------------------------
  // Savings Tips
  // -------------------------------------------------------------------------

  Future<List<String>> getSavingsTips(List<Transaction> transactions) async {
    try {
      if (transactions.isEmpty) {
        return ['Start tracking your expenses to receive personalised tips!'];
      }

      final summary = transactions.map((t) {
        final type = t.isIncome ? 'Income' : 'Expense';
        return '$type: ${t.title} – ${t.amount.toStringAsFixed(2)} '
            '(${t.category.name})';
      }).join('\n');

      final prompt =
          'You are a personal finance advisor. Based on the following '
          'recent transactions, provide exactly 3 concise, actionable savings '
          'suggestions. Return ONLY a JSON array of 3 strings.\n\n'
          'Transactions:\n$summary';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };

      final text = await _postToGemini(requestBody);
      if (text == null || text.isEmpty) return [];

      final cleaned = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final decoded = jsonDecode(cleaned);

      if (decoded is List) {
        return decoded.map((e) => e.toString()).take(3).toList();
      }

      return [];
    } on FormatException {
      return [];
    } catch (e) {
      return [];
    }
  }

  // -------------------------------------------------------------------------
  // FluxAI Savings Coach
  // -------------------------------------------------------------------------

  Future<List<String>> getSavingsAdvice(List<Transaction> history) async {
    try {
      if (history.isEmpty) {
        return ['İlk harcamanı ekle, sana özel tavsiyeleri görelim! 🚀'];
      }

      final summary = history.map((t) {
        final type = t.isIncome ? 'Gelir' : 'Gider';
        return '$type: ${t.title} – ${t.amount.toStringAsFixed(2)} TL '
            '(${t.category.name})';
      }).join('\n');

      final prompt =
          'You are a witty, slightly sarcastic financial coach named FluxAI. '
          'Analyze these expenses and give 3 short, punchy, and helpful '
          'savings tips in Turkish. Use emojis. '
          'Return ONLY a JSON array of 3 strings.\n\n'
          'Harcamalar:\n$summary';

      final requestBody = {
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      };

      final text = await _postToGemini(requestBody);
      if (text == null || text.isEmpty) return [];

      final cleaned = text
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final decoded = jsonDecode(cleaned);

      if (decoded is List) {
        return decoded.map((e) => e.toString()).take(3).toList();
      }

      return [];
    } on FormatException {
      return [];
    } catch (e) {
      return [];
    }
  }
}
