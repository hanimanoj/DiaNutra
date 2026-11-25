class MealDistribution {
  static const Map<String, double> percentages = {
    'Breakfast': 0.25, //Breakfast reflected 25% of daily intake
    'Lunch': 0.35,     //Lunch reflected 35% of daily intake
    'Dinner': 0.30,    //Dinner reflected 30% of daily intake
    'Snack': 0.10,     //Snack reflected 10% of daily intake
  };

  static double getTarget({
    required double dailyTarget,
    required String mealType,
  }) {
    final percentage = percentages[mealType];

    if (percentage == null) {
      throw ArgumentError('Invalid meal type: $mealType');
    }

    return dailyTarget * percentage;
  }
}