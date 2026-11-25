import 'package:flutter/material.dart';
import '../../models/calculation.dart';
import '../../core/meal_distribution.dart';
import '../../services/recommendation_service.dart';
import '../../services/firestore_service.dart';

class MealRecommendationPage extends StatefulWidget {
  final TdeeCalculationResult? result;

  const MealRecommendationPage({
    super.key,
    required this.result,
  });

  @override
  State<MealRecommendationPage> createState() =>
      _MealRecommendationPageState();
}

class _MealRecommendationPageState
  extends State<MealRecommendationPage> {

  static const Color diaGreen = Color(0xFF176744);
  static const Color diaMint = Color(0xFFF3FFF0);
  static const Color diaCard = Color(0xFFC9DFCD);

  int selectedCategory = 0;

  @override
  void initState() {
    super.initState();

    loadRecommendations();
    loadDailyTracking();
  }

  final RecommendationService recommendationService = RecommendationService();
  final FirestoreService firestoreService = FirestoreService();

  List<dynamic> recommendedMeals = [];
  List<dynamic> recommendedFoods = [];

  List<Map<String, dynamic>> dailyFoods = [];
  bool isTrackingLoading = false;

  bool isLoading = false;
  String? errorMessage;

  final List<String> categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];
  
  Map<String, double>? get selectedMealTargets {
    final daily = widget.result;

    if (daily == null) return null;

    final mealType = categories[selectedCategory];

    return {
      'calories': MealDistribution.getTarget(
        dailyTarget: daily.tdee,
        mealType: mealType,
      ),
      'carbs': MealDistribution.getTarget(
        dailyTarget: daily.carbs,
        mealType: mealType,
      ),
      'protein': MealDistribution.getTarget(
        dailyTarget: daily.protein,
        mealType: mealType,
      ),
      'fat': MealDistribution.getTarget(
        dailyTarget: daily.fat,
        mealType: mealType,
      ),
    };
  }

  Future<void> loadRecommendations() async {
    final targets = selectedMealTargets;

    if (targets == null) {
      setState(() {
        errorMessage = 'Please calculate your TDEE first.';
        recommendedMeals = [];
        recommendedFoods = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final mealType = categories[selectedCategory];

      final meals = await recommendationService.getMealRecommendation(
        mealType: mealType,
        calories: targets['calories']!,
        carbs: targets['carbs']!,
        protein: targets['protein']!,
        fat: targets['fat']!,
      );

      final foods = await recommendationService.getFoodRecommendations(
        calories: targets['calories']!,
        carbs: targets['carbs']!,
        protein: targets['protein']!,
        fat: targets['fat']!,
      );

      if (!mounted) return;

      setState(() {
        recommendedMeals = meals;
        recommendedFoods = foods;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Load today's food tracking records
  Future<void> loadDailyTracking() async {
    setState(() {
      isTrackingLoading = true;
    });

    try {
      final foods = await firestoreService.getDailyFoodTracking();

      if (!mounted) return;

      setState(() {
        dailyFoods = foods;
        isTrackingLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isTrackingLoading = false;
      });

      debugPrint('Daily Tracking Error: $e');
    }
  }

  // Remove tracked food or meal
  Future<void> removeTrackedFood(String foodId) async {
    try {
      await firestoreService.removeFoodFromDailyTracking(
        foodId: foodId,
      );

      if (!mounted) return;

      await loadDailyTracking();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from Daily Tracking.'),
          backgroundColor: diaGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to remove item: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: diaMint,

      appBar: AppBar(
        backgroundColor: diaMint,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: diaGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Image.asset(
          'assets/images/dianutra_logo.png',
          height: 48,
          errorBuilder: (_, __, ___) => const Text(
            'DIANUTRA',
            style: TextStyle(
              color: diaGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Center(
                child: Text(
                  'FOOD RECOMMENDATIONS',
                  style: TextStyle(
                    color: diaGreen,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Meal category selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: diaGreen),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: List.generate(
                    categories.length,
                    (index) {
                      final isSelected =
                          selectedCategory == index;

                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (selectedCategory == index) return;

                            setState(() {
                              selectedCategory = index;
                            });

                            loadRecommendations();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? diaGreen
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              categories[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : diaGreen,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Daily nutrition summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: diaCard,
                  border: Border.all(color: diaGreen),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Nutrition Summary',
                      style: TextStyle(
                        color: diaGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Nutrition tracking will appear here',
                        style: TextStyle(
                          fontSize: 12,
                          color: diaGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              _buildDailyTracking(),

              const SizedBox(height: 22),

              Text(
                '${categories[selectedCategory]} Recommendations',
                style: const TextStyle(
                  color: diaGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              // Meal recommendation placeholder
              _buildMealRecommendation(),

              const SizedBox(height: 20),

              const Text(
                'Recommended Foods',
                style: TextStyle(
                  color: diaGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              //Food recommendation placeholder
              _buildFoodRecommendations(),
            ],
          ),
        ),
      ),
    );
  }

  // Build Daily Tracking section
  Widget _buildDailyTracking() {
    if (isTrackingLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Daily Tracking',
          style: TextStyle(
            color: diaGreen,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...categories.map((category) {
          final categoryFoods = dailyFoods
              .where((food) => food['mealType'] == category)
              .toList();

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: diaGreen),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    color: diaGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 10),

                if (categoryFoods.isEmpty)
                  const Text(
                    'No food tracked yet.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  )
                else
                  ...categoryFoods.map((food) {
                    final serving =
                        (food['servingSize'] as num?)?.toDouble() ?? 1.0;

                    final calories =
                        (food['calories'] as num?)?.toDouble() ?? 0.0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: diaMint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  food['foodName'] ?? 'Unknown Food',
                                  style: const TextStyle(
                                    color: diaGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  '$serving serving(s) • '
                                  '${calories.toStringAsFixed(1)} kcal',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            tooltip: 'Remove item',
                            onPressed: () {
                              removeTrackedFood(food['id']);
                            },
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMealRecommendation() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildPlaceholderCard(
        'Recommendation Error',
        errorMessage!,
      );
    }

    if (recommendedMeals.isEmpty) {
      return _buildPlaceholderCard(
        'Meal Recommendation',
        'No recommendation available.',
      );
    }

    final meal = recommendedMeals.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: diaGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meal['Dish']?.toString() ?? 'Recommended Meal',
            style: const TextStyle(
              color: diaGreen,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${meal['Calories']} kcal',
            style: const TextStyle(
              color: diaGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text('Carbs: ${meal['Carbs']} g'),
          Text('Protein: ${meal['Protein']} g'),
          Text('Fat: ${meal['Fat']} g'),
          Text('Fibre: ${meal['Fiber']} g'),
          Text('Glycemic Index: ${meal['Glycemic Index']}'),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _confirmAddFood({
                  'Food Name': meal['Dish'],
                  'Calories': meal['Calories'],
                  'Carbohydrates': meal['Carbs'],
                  'Protein': meal['Protein'],
                  'Fat': meal['Fat'],
                });
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add to Daily Tracking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: diaGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodRecommendations() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildPlaceholderCard(
        'Food Recommendations',
        errorMessage!,
      );
    }

    if (recommendedFoods.isEmpty) {
      return _buildPlaceholderCard(
        'Food Recommendations',
        'No food recommendations available.',
      );
    }

    return Column(
      children: recommendedFoods.map((food) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: diaGreen),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: diaCard,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.restaurant,
                  color: diaGreen,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food['Food Name']?.toString() ?? 'Unknown Food',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: diaGreen,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text('${food['Calories']} kcal'),
                    Text(
                      'Carbs: ${food['Carbohydrates']}g',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Protein: ${food['Protein']}g',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Fat: ${food['Fat']}g',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'GI: ${food['Glycemic Index']}',
                      style: const TextStyle(fontSize: 11),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _confirmAddFood(food);
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add to Daily Tracking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: diaGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }


  // Confirm adding food to daily tracking
  Future<void> _confirmAddFood(Map<String, dynamic> food) async {
    double servingSize = 1.0;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add to Daily Tracking'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food['Food Name']?.toString() ?? 'Unknown Food'),
                  const SizedBox(height: 16),
                  const Text('Select Serving Size'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<double>(
                    value: servingSize,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    items: [0.5, 1.0, 1.5, 2.0].map((size) {
                      return DropdownMenuItem<double>(
                        value: size,
                        child: Text('$size serving'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() {
                          servingSize = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: diaGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add Food'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true) {
      await _saveFoodToTracking(food, servingSize);
    }
  }

  // Save selected food to Firestore
  Future<void> _saveFoodToTracking(
    Map<String, dynamic> food,
    double servingSize,
  ) async {
    try {
      await firestoreService.addFoodToDailyTracking(
        foodName: food['Food Name'].toString(),
        mealType: categories[selectedCategory],
        calories: (food['Calories'] as num).toDouble() * servingSize,
        carbs: (food['Carbohydrates'] as num).toDouble() * servingSize,
        protein: (food['Protein'] as num).toDouble() * servingSize,
        fat: (food['Fat'] as num).toDouble() * servingSize,
        servingSize: servingSize,
      );

      if (!mounted) return;

      await loadDailyTracking();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${food['Food Name']} added to Daily Tracking!',
          ),
          backgroundColor: diaGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add food: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPlaceholderCard(String title, String description) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: diaGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: diaGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
