import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/meal_distribution.dart';

class RecommendationService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:5000';
    }
    return 'http://10.0.2.2:5000';
  }

  // Check Flask connection
  Future<bool> checkConnection() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get food recommendations
  Future<List<dynamic>> getFoodRecommendations({
    required double calories,
    required double carbs,
    required double protein,
    required double fat,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recommend/foods'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['status'] == 'success') {
      return data['recommendations'] as List<dynamic>;
    }

    throw Exception(data['message'] ?? 'Failed to get food recommendations');
  }

  Map<String, double> getMealTargets({
    required String mealType,
    required double dailyCalories,
    required double dailyCarbs,
    required double dailyProtein,
    required double dailyFat,
  }) {
    return {
      'calories': MealDistribution.getTarget(
        dailyTarget: dailyCalories,
        mealType: mealType,
      ),
      'carbs': MealDistribution.getTarget(
        dailyTarget: dailyCarbs,
        mealType: mealType,
      ),
      'protein': MealDistribution.getTarget(
        dailyTarget: dailyProtein,
        mealType: mealType,
      ),
      'fat': MealDistribution.getTarget(
        dailyTarget: dailyFat,
        mealType: mealType,
      ),
    };
  }

  // Get meal recommendation
  Future<List<dynamic>> getMealRecommendation({
    required String mealType,
    required double calories,
    required double carbs,
    required double protein,
    required double fat,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recommend/meal'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'meal_type': mealType,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
      }),
    ).timeout(const Duration(seconds: 15));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 &&
        data['status'] == 'success') {
      return data['recommendations'] as List<dynamic>;
    }

    throw Exception(data['message'] ?? 'Failed to get meal recommendation');
  }
}
