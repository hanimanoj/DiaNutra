
import 'dart:convert';
import 'package:flutter/material.dart';
import 'services/recommendation_service.dart';

void main() {
  runApp(const ApiTestApp());
}

class ApiTestApp extends StatelessWidget {
  const ApiTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ApiTestPage(),
    );
  }
}

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  final service = RecommendationService();

  String result = 'Click the button to test food recommendations.';
  bool isLoading = false;
  
  Future<void> testMealRecommendation() async {
    setState(() {
      isLoading = true;
      result = 'Getting breakfast recommendation...';
    });

    try {
      final meals = await service.getMealRecommendation(
        mealType: 'Snack',
        calories: 250,
        carbs: 20,
        protein: 15,
        fat: 8,
      );

      setState(() {
        result = const JsonEncoder.withIndent('  ').convert(meals);
      });
    } catch (e) {
      setState(() {
        result = 'Error: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DiaNutra Food API Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testMealRecommendation,
              child: const Text('Get Food Recommendations'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(result),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
