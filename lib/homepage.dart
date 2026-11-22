import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'header.dart';
import 'footer.dart';
import 'calculation.dart';
import 'userform.dart';

const Color diaGreen = Color(0xFF176744);
const Color diaMint = Color(0xFFF3FFF0);
const Color diaCard = Color(0xFFC9DFCD);
const Color diaButton = Color(0xFF70B99A);
const Color diaBlue = Color(0xFF7B8BD8);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  int selectedTab = 0;
  TdeeCalculationResult? latestResult;

  final List<TdeeCalculationResult> savedHistory = [];
  final Set<DateTime> loggedDates = {};

  final List<String> days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final List<String> tabs = [
    'Home',
    'Progress',
    'Meal',
    'History',
    'Profile',
  ];

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final today = DateTime.now();
    final isToday =
      selectedDate.year == today.year &&
      selectedDate.month == today.month &&
      selectedDate.day == today.day;

    final dateText =
        '${selectedDate.day} ${months[selectedDate.month - 1]} ${selectedDate.year}';

    return isToday ? 'Today, $dateText' : dateText;
  }

  DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime get startOfWeek {
    final date = dateOnly(selectedDate);
    return date.subtract(Duration(days: date.weekday - 1));
  }

  DateTime dateForDay(int index) {
    return startOfWeek.add(Duration(days: index));
  }

  bool hasProgress(DateTime date) {
    return loggedDates.contains(dateOnly(date));
  }

  Future<void> openCalculateTdee() async {
    final response = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => const UserFormPage(),
      ),
    );

    if (!mounted || response == null) return;

    final result = response['result'] as TdeeCalculationResult;
    final saved = response['saved'] as bool;

    setState(() {
      latestResult = result;

      if (saved) {
        savedHistory.add(result);
      }
    });
  }

  void selectTab(int index) {
    setState(() => selectedTab = index);

    if (index != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${tabs[index]} page will be dev later'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: diaMint,
      appBar: const DiaNutraHeader(),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting and calendar
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black,
                                ),
                                children: [
                                  TextSpan(text: 'Hi '),
                                  TextSpan(
                                    text: FirebaseAuth.instance.currentUser?.displayName
                                            ?.split(' ')
                                            .first ??
                                        'User',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(text: ", let's see today's log"),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );

                          if (picked != null) {
                            setState(() {
                              selectedDate = dateOnly(picked);
                            });
                          }
                        },
                        icon: const Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Weekly tracker
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: diaGreen),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: List.generate(7, (index) {
                        final date = dateForDay(index);
                        final isSelected = dateOnly(selectedDate) == date;
                        final isLogged = hasProgress(date);

                        return Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              setState(() {
                                selectedDate = date;
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  days[index],
                                  style: const TextStyle(
                                    color: diaGreen,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Circle status progress
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,

                                    // Blue if updated progress, transparent if not
                                    color: isLogged
                                        ? diaBlue
                                        : Colors.transparent,

                                    border: Border.all(
                                      color: isLogged
                                          ? diaBlue
                                          : Colors.grey,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(
                                            Icons.circle,
                                            size: 6,
                                            color: Colors.black,
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Today's nutrition card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                    decoration: BoxDecoration(
                      color: diaCard,
                      border: Border.all(color: diaGreen),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "Daily Nutrition Details",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: diaGreen,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Calories ring
                        Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: Center(
                                child: Container(
                                  width: 104,
                                  height: 104,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.redAccent,
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Container(
                                    margin: const EdgeInsets.all(9),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.redAccent,
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          latestResult == null
                                              ? '0'
                                              : latestResult!.tdee.round().toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Text(
                                          'kcal left',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Calories',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    latestResult == null
                                        ? '0 kcal/day'
                                        : '${latestResult!.tdee.round()} kcal/day',
                                    style: const TextStyle(
                                      color: diaGreen,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        _NutrientBar(
                          label: 'Carbs',
                          amount: latestResult == null
                              ? '0 g'
                              : '${latestResult!.carbs.round()} g',
                          color: const Color(0xFF83B65D),
                          progress: 0,
                        ),
                        const SizedBox(height: 12),
                        _NutrientBar(
                          label: 'Protein',
                          amount: latestResult == null
                              ? '0 g'
                              : '${latestResult!.protein.round()} g',
                          color: const Color(0xFF4C9CE8),
                          progress: 0,
                        ),
                        const SizedBox(height: 12),
                        _NutrientBar(
                          label: 'Fat',
                          amount: latestResult == null
                              ? '0 g'
                              : '${latestResult!.fat.round()} g',
                          color: Colors.white,
                          progress: 0,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Nutrition details will be added later',
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              '> See all details',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: openCalculateTdee,
                            icon: const Icon(Icons.calculate_outlined),
                            label: const Text(
                              'CALCULATE TDEE',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: diaButton,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              side: const BorderSide(color: diaGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Latest summary
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your latest summary',
                        style: TextStyle(
                          color: diaGreen,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => selectTab(1),
                        child: const Text(
                          'See your progress >',
                          style: TextStyle(
                            color: diaGreen,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: diaGreen),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 72,
                            child: CustomPaint(
                              painter: _SummaryChartPainter(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'October 2026',
                                style: TextStyle(fontSize: 10),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'each week your calories\nincrease 30% daily',
                                style: TextStyle(
                                  color: diaBlue,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: DiaNutraFooter(
        currentIndex: selectedTab,
        onTap: selectTab,
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;
  final double progress;

  const _NutrientBar({
    required this.label,
    required this.amount,
    required this.color,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              amount,
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 5),

        // Progress bar background with border
        Container(
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: color,
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: safeProgress,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barPaint = Paint()..color = const Color(0xFFB84B50);
    final linePaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final heights = [32.0, 56.0, 38.0, 18.0, 44.0];
    final points = <Offset>[];

    for (int i = 0; i < heights.length; i++) {
      final x = 8.0 + i * (size.width - 24) / 4;
      final y = size.height - heights[i];
      canvas.drawRect(
        Rect.fromLTWH(x, y, 14, heights[i]),
        barPaint,
      );
      points.add(Offset(x + 7, y));
    }

    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
