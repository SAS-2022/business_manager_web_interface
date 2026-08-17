import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CloudeAIDataService {
  static final CloudeAIDataService _instance = CloudeAIDataService._internal();
  factory CloudeAIDataService() => _instance;
  CloudeAIDataService._internal();

  Timer? _fetchTimer;
  DateTime? _lastFetchTime;
  final String _apiKey = '';
  static const String _baseUrl = 'https://api.anthropic.com';
  final String _completionsUrl = '$_baseUrl/v1/messages';

  // Start periodic fetching
  void startPeriodicFetch(
      String businessType, String category, BuildContext context) {
    // Cancel any existing timer
    _fetchTimer?.cancel();

    // Fetch immediately
    fetchBusinessContent(businessType, category, context);

    // Then every 2 hours
    _fetchTimer = Timer.periodic(const Duration(hours: 2), (_) {
      fetchBusinessContent(businessType, category, context);
    });
  }

  void stopPeriodicFetch() {
    _fetchTimer?.cancel();
  }

  Future<Map<String, dynamic>> fetchBusinessContent(
      String businessType, String category, BuildContext context) async {
    // Skip if last fetch was recent (within 10 minutes)
    if (_lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) <
            const Duration(minutes: 10)) {
      return {};
    }
    try {
      // Step 1: Get text content
      final Map<String, String> textContent =
          await _getTextContent(businessType, category);

      return {
        'title': textContent['title'],
        'text_content': textContent['content'],
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Fetch Error: $e');
      return {};
      // You might want to implement retry logic here
    }
  }

  Future<Map<String, String>> _getTextContent(
      String businessType, String category) async {
    try {
      final response = await http.post(
        Uri.parse(_completionsUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that provides business insights and content.',
            },
            {
              'role': 'user',
              'content':
                  '''Generate responses business insight for a $businessType in the $category category in this exact JSON format:
                  {
                    "title": "A concise, engaging title (5-8 words)",
                    "content": "200-word business insight with trends, advice, and positive outlook"
                  }
                 ''',
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final contentJson =
            json.decode(data['choices'][0]['message']['content']);

        return {
          'title': contentJson['title'],
          'content': contentJson['content'],
        };
      } else {
        final errorData = json.decode(response.body);
        debugPrint('OpenAI API Error: ${errorData['error']}');

        if (response.statusCode == 404) {
          throw Exception('Model not found - check your model name');
        } else if (response.statusCode == 401) {
          throw Exception('Invalid API key - check your authentication');
        } else if (response.statusCode == 429) {
          throw Exception('Rate limit exceeded - wait before retrying');
        } else {
          throw Exception('API request failed: ${response.statusCode}');
        }
      }
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
