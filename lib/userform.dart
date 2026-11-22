import 'package:flutter/material.dart';
import 'footer.dart';
import 'calculation.dart';
import 'tdee_result_page.dart';

const Color diaGreen = Color(0xFF176744);
const Color diaMint = Color(0xFFF3FFF0);
const Color diaCard = Color(0xFFC9DFCD);
const Color diaButton = Color(0xFF70B99A);

class UserFormPage extends StatefulWidget {
  const UserFormPage({super.key});

  @override
  State<UserFormPage> createState() =>
      _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final healthController = TextEditingController();

  String? gender;
  String? diabetesType;
  String? activityLevel;

  final List<String> activityOptions = [
    'Sedentary',
    'Slightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active',
  ];

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    healthController.dispose();
    super.dispose();
  }

  Widget buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget buildNumberField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String unit,
    required bool isInteger,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel(label),
        SizedBox(
          height: 34,
          child: TextFormField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
              suffixText: unit,
              suffixStyle: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: diaGreen,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: diaGreen,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: diaGreen,
                  width: 1.5,
                ),
              ),
              errorStyle: const TextStyle(fontSize: 9),
            ),
            validator: (value) {
              final number = double.tryParse(value ?? '');

              if (number == null || number <= 0) {
                return 'Please enter a valid $label';
              }

              if (isInteger && number != number.roundToDouble()) {
                return 'Please enter a whole number';
              }

              if (label == 'Age' && number > 120) {
                return 'Please enter a valid age';
              }

              if (label == 'Height' && number > 250) {
                return 'Please enter a valid height';
              }

              if (label == 'Weight' && number > 500) {
                return 'Please enter a valid weight';
              }

              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildFieldLabel(label),
        SizedBox(
          height: 34,
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.black,
              size: 22,
            ),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: diaGreen),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: diaGreen),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: diaGreen,
                  width: 1.5,
                ),
              ),
            ),
            hint: Text(
              'Select $label',
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
            ),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) =>
                value == null ? 'Please select $label' : null,
          ),
        ),
      ],
    );
  }
  
  Future<void> calculateTdee() async {
    if (!_formKey.currentState!.validate()) return;

    final result = TdeeCalculator.calculate(
      age: int.parse(ageController.text),
      gender: gender!,
      heightCm: double.parse(heightController.text),
      weightKg: double.parse(weightController.text),
      activityLevel: activityLevel!,
    );

    final response = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => TdeeResultPage(result: result),
      ),
    );

    if (!mounted || response == null) return;

    Navigator.pop(context, response);
  }

  void handleTabTap(int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: diaMint,

      // Custom top bar matching the reference design
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
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: diaGreen,
                    size: 24,
                  ),
                ),
                Image.asset(
                  'assets/images/dianutra_logo.png',
                  width: 56,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text(
                      'DiaNutra',
                      style: TextStyle(
                        color: diaGreen,
                        fontSize: 18,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'CALCULATE YOUR TDEE',
                    style: TextStyle(
                      color: diaGreen,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(12, 2, 12, 16),
                  child: Text(
                    'Review your inputs, then estimate your daily energy expenditure.',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                    ),
                  ),
                ),

                // Main form card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(
                    24, 16, 24, 20,
                  ),
                  decoration: BoxDecoration(
                    color: diaCard,
                    border: Border.all(color: diaGreen),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildNumberField(
                        label: 'Age',
                        hint: 'Enter age',
                        controller: ageController,
                        unit: 'years old',
                        isInteger: true,
                      ),

                      const SizedBox(height: 14),

                      // Gender
                      buildDropdown(
                        label: 'Gender',
                        value: gender,
                        options: const ['Female', 'Male'],
                        onChanged: (value) {
                          setState(() => gender = value);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Height before weight, as in the screenshot
                      buildNumberField(
                        label: 'Height',
                        hint: 'Enter height',
                        controller: heightController,
                        unit: 'cm',
                        isInteger: false,
                      ),

                      const SizedBox(height: 14),

                      buildNumberField(
                        label: 'Weight',
                        hint: 'Enter weight',
                        controller: weightController,
                        unit: 'kg',
                        isInteger: false,
                      ),

                      const SizedBox(height: 14),

                      buildDropdown(
                        label: 'Type of Diabetes',
                        value: diabetesType,
                        options: const [
                          'Type 1',
                          'Type 2',
                          'Prediabetes',
                          'Gestational Diabetes',
                          'Not Diagnosed',
                        ],
                        onChanged: (value) {
                          setState(() => diabetesType = value);
                        },
                      ),

                      const SizedBox(height: 14),

                      buildDropdown(
                        label: 'Activity Level',
                        value: activityLevel,
                        options: activityOptions,
                        onChanged: (value) {
                          setState(() => activityLevel = value);
                        },
                      ),

                      const SizedBox(height: 14),

                      // Optional health information
                      buildFieldLabel('Health Information (Optional)'),
                      SizedBox(
                        height: 34,
                        child: TextFormField(
                          controller: healthController,
                          style: const TextStyle(fontSize: 11),
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: diaGreen),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: diaGreen),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: diaGreen,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Calculate button
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton.icon(
                          onPressed: calculateTdee,
                          icon: const Icon(
                            Icons.calculate_outlined,
                            size: 22,
                          ),
                          label: const Text(
                            'CALCULATE TDEE',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: diaButton,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(color: diaGreen),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                        ),
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

      // Reuse the shared bottom navigation
      bottomNavigationBar: DiaNutraFooter(
        currentIndex: 0,
        onTap: handleTabTap,
      ),
    );
  }
}
