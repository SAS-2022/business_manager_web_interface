import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIDataService with ChangeNotifier {
  static const String _backendUrl =
      'https://us-central1-business-manager-a8c65.cloudfunctions.net/businessData';
  static const int _refreshIntervalHours = 4;

  Future<Map<String, dynamic>> fetchBusinessNews(
      String businessType, String category,
      {bool forceRefresh = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchKey = 'lastFetch_${businessType}_$category';
    final cachedDataKey = 'cachedData_${businessType}_$category';

    // Check if cached data exists and is still valid
    if (!forceRefresh) {
      final lastFetchTime = prefs.getInt(lastFetchKey);
      final currentTime = DateTime.now().millisecondsSinceEpoch;

      if (lastFetchTime != null &&
          (currentTime - lastFetchTime) < _refreshIntervalHours * 3600 * 1000) {
        final cachedData = prefs.getString(cachedDataKey);
        if (cachedData != null) {
          return json.decode(cachedData);
        }
      }
    }

    // Fetch new data from backend
    try {
      final response = await http.post(
        Uri.parse(_backendUrl),
        body: json.encode({
          'businessType': businessType,
          'category': category,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Cache the new data
        await prefs.setInt(lastFetchKey, DateTime.now().millisecondsSinceEpoch);
        await prefs.setString(cachedDataKey, response.body);

        return data;
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      // Fallback to cached data if available
      final cachedData = prefs.getString(cachedDataKey);
      if (cachedData != null) {
        return json.decode(cachedData);
      }
      throw Exception('Failed to fetch data: $e');
    }
  }
}
