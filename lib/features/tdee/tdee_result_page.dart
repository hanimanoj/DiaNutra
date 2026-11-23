import 'package:flutter/material.dart';
import '../../models/calculation.dart';
import '../../widgets/footer.dart';

const Color resultGreen = Color(0xFF176744);
const Color resultMint = Color(0xFFF3FFF0);
const Color resultCard = Color(0xFFC9DFCD);
const Color resultButton = Color(0xFF70B99A);
const Color resultBlue = Color(0xFF7B8BD8);

class TdeeResultPage extends StatelessWidget {
  final TdeeCalculationResult result;
  final Future<void> Function()? onSaveHistory;

  const TdeeResultPage({
    super.key,
    required this.result,
    this.onSaveHistory,
  });

  String formatNumber(double value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  Widget nutrientRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 9,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: resultGreen,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              '${amount.round()} g',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: resultBlue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 27),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: resultButton,
          foregroundColor: Colors.white,
          elevation: 0,
          side: const BorderSide(color: resultGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: resultMint,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(88),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () { 
                    Navigator.pop(context, {
                      'result': result,
                      'saved': false,
                    });
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: resultGreen,
                    size: 24,
                  ),
                ),
                Image.asset(
                  'assets/images/dianutra_logo.png',
                  width: 76,
                  height: 68,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'DiaNutra',
                      style: TextStyle(
                        color: resultGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      body: SafeArea(
        top: false,
        child: Container(
          width: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TDEE Result',
                  style: TextStyle(
                    color: resultGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),

                // TDEE summary card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
                  decoration: BoxDecoration(
                    color: resultCard,
                    border: Border.all(color: resultGreen),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Your TDEE',
                        style: TextStyle(
                          color: resultGreen,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 18),

                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formatNumber(result.tdee),
                              style: const TextStyle(
                                color: Color(0xFFA51F25),
                                fontSize: 46,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'kcal/day',
                              style: TextStyle(
                                color: resultGreen,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        'Total Daily Energy Expenditure',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: resultGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  'Macronutrient and Nutrient Targets',
                  style: TextStyle(
                    color: resultGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: resultGreen),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      nutrientRow('Carbohydrates', result.carbs),
                      const Divider(
                        height: 1,
                        color: resultCard,
                      ),
                      nutrientRow('Protein', result.protein),
                      const Divider(
                        height: 1,
                        color: resultCard,
                      ),
                      nutrientRow('Fat', result.fat),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 27),
                  child: Column(
                    children: [
                      actionButton(
                        icon: Icons.access_time,
                        label: 'Save History Calculation Results',
                        onPressed: () {
                          Navigator.pop(context, {
                            'result': result,
                            'saved': true,
                          });
                        },
                      ),

                      const SizedBox(height: 14),

                      actionButton(
                        icon: Icons.restaurant_menu,
                        label: 'View Food Recommendation',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Food recommendation page will be connected next.',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: DiaNutraFooter(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${['Home', 'Progress', 'Meal', 'History', 'Profile'][index]} page will be available later.',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
