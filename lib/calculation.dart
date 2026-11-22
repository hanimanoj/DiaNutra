class TdeeCalculationResult {
  final double bmr;
  final double tdee;
  final double bmi;
  final double carbs;
  final double protein;
  final double fat;

  const TdeeCalculationResult({
    required this.bmr,
    required this.tdee,
    required this.bmi,
    required this.carbs,
    required this.protein,
    required this.fat,
  });
}

class TdeeCalculator {
  static double activityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'Sedentary':
        return 1.2;
      case 'Slightly Active':
        return 1.375;
      case 'Moderately Active':
        return 1.55;
      case 'Very Active':
        return 1.725;
      case 'Extra Active':
        return 1.9;
      default:
        throw ArgumentError('Unknown activity level: $activityLevel');
    }
  }

  static TdeeCalculationResult calculate({
    required int age,
    required String gender,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
  }) {
    final bmr = (10 * weightKg) +
        (6.25 * heightCm) -
        (5 * age) +
        (gender == 'Male' ? 5 : -161);

    final tdee = bmr * activityMultiplier(activityLevel);
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);

    return TdeeCalculationResult(
      bmr: bmr,
      tdee: tdee,
      bmi: bmi,
      carbs: (0.65 * tdee) / 4, //1gram = 4kcal
      protein: (0.15 * tdee) / 4, //1gram = 4kcal
      fat: (0.20 * tdee) / 9, //1gram = 9kcal
    );
  }
}
