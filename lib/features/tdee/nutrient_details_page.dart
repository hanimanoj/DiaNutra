import 'package:flutter/material.dart';
import '../../models/calculation.dart';

const Color detailGreen = Color(0xFF176744);
const Color detailMint = Color(0xFFF3FFF0);
const Color detailCardColor = Color(0xFFC9DFCD);
const Color detailBlue = Color(0xFF7B8BD8);

class NutrientDetailsPage extends StatelessWidget {
  final TdeeCalculationResult result;

  const NutrientDetailsPage({
    super.key,
    required this.result,
  });

  String formatNumber(double value) {
    return value.round().toString();
  }

  Widget detailCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: detailGreen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: detailGreen, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$value $unit',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: detailGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget nutrientRow({
    required String name,
    required double amount,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: detailGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: detailGreen,
                  fontSize: 14,
                ),
              ),
              Text(
                '${amount.round()} g/day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: detailMint,
      appBar: AppBar(
        backgroundColor: detailMint,
        elevation: 0,
        foregroundColor: detailGreen,
        title: const Text(
          'Nutrient Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Daily Energy Requirements',
              style: TextStyle(
                color: detailGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            detailCard(
              title: 'Basal Metabolic Rate (BMR)',
              value: formatNumber(result.bmr),
              unit: 'kcal/day',
              icon: Icons.monitor_heart_outlined,
            ),
            const SizedBox(height: 10),

            detailCard(
              title: 'Total Daily Energy Expenditure',
              value: formatNumber(result.tdee),
              unit: 'kcal/day',
              icon: Icons.local_fire_department_outlined,
            ),
            const SizedBox(height: 10),

            detailCard(
              title: 'Body Mass Index (BMI)',
              value: result.bmi.toStringAsFixed(1),
              unit: 'kg/m²',
              icon: Icons.monitor_weight_outlined,
            ),

            const SizedBox(height: 24),

            const Text(
              'Daily Macronutrient Targets',
              style: TextStyle(
                color: detailGreen,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Your estimated daily macronutrient requirements.',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 12),

            nutrientRow(
              name: 'Carbohydrates',
              amount: result.carbs,
              description: 'Energy from carbohydrates',
              color: const Color(0xFF83B65D),
            ),
            const SizedBox(height: 10),

            nutrientRow(
              name: 'Protein',
              amount: result.protein,
              description: 'Supports body tissue maintenance',
              color: const Color(0xFF4C9CE8),
            ),
            const SizedBox(height: 10),

            nutrientRow(
              name: 'Fat',
              amount: result.fat,
              description: 'Provides energy and supports body functions',
              color: detailBlue,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: detailCardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Note: These values are estimated based on your TDEE '
                'and the macronutrient distribution used by DiaNutra.',
                style: TextStyle(
                  fontSize: 11,
                  color: detailGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
