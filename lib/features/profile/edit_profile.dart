
import 'package:flutter/material.dart';
import '../../services/firestore_service.dart';

const Color diaGreen = Color(0xFF176744);
const Color diaMint = Color(0xFFF3FFF0);
const Color diaCard = Color(0xFFC9DFCD);
const Color diaButton = Color(0xFF70B99A);

class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const EditProfilePage({
    super.key,
    required this.profile,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController ageController;
  late final TextEditingController heightController;
  late final TextEditingController weightController;

  String? gender;
  String? diabetesType;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    ageController = TextEditingController(
      text: widget.profile['age']?.toString() ?? '',
    );

    heightController = TextEditingController(
      text: widget.profile['height']?.toString() ?? '',
    );

    weightController = TextEditingController(
      text: widget.profile['weight']?.toString() ?? '',
    );

    gender = widget.profile['gender'];
    diabetesType = widget.profile['diabetesType'];
  }

  Future<void> saveChanges() async {
    if (ageController.text.trim().isEmpty ||
        heightController.text.trim().isEmpty ||
        weightController.text.trim().isEmpty ||
        gender == null ||
        diabetesType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirestoreService().saveTdeeProfile(
        age: int.parse(ageController.text),
        gender: gender!,
        heightCm: double.parse(heightController.text),
        weightKg: double.parse(weightController.text),
        diabetesType: diabetesType!,
        activityLevel: widget.profile['activityLevel'] ?? 'Sedentary',
        healthInformation: widget.profile['healthInformation'] ?? '',
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update profile: $e')),
      );

      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: diaMint,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Edit Profile',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: diaGreen,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update your personal information.',
                style: TextStyle(fontSize: 13),
              ),

              const SizedBox(height: 20),

              // Age
              const Text('Age'),
              const SizedBox(height: 6),
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  suffixText: 'years old',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Height
              const Text('Height'),
              const SizedBox(height: 6),
              TextFormField(
                controller: heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  suffixText: 'cm',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Weight
              const Text('Weight'),
              const SizedBox(height: 6),
              TextFormField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  suffixText: 'kg',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              // Gender
              const Text('Gender'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text('Female'),
                  ),
                  DropdownMenuItem(
                    value: 'Male',
                    child: Text('Male'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => gender = value);
                },
              ),

              const SizedBox(height: 16),

              // Diabetes Type
              const Text('Diabetes Type'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: diabetesType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Type 1',
                    child: Text('Type 1'),
                  ),
                  DropdownMenuItem(
                    value: 'Type 2',
                    child: Text('Type 2'),
                  ),
                  DropdownMenuItem(
                    value: 'Prediabetes',
                    child: Text('Prediabetes'),
                  ),
                  DropdownMenuItem(
                    value: 'Gestational Diabetes',
                    child: Text('Gestational Diabetes'),
                  ),
                  DropdownMenuItem(
                    value: 'Not Diagnosed',
                    child: Text('Not Diagnosed'),
                  ),
                ],
                onChanged: (value) {
                  setState(() => diabetesType = value);
                },
              ),
            ],
          ),
        ),
      ),

      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: loading
                    ? null
                    : () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: diaGreen,
                  side: const BorderSide(color: diaGreen),
                ),
                child: const Text('CANCEL'),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: ElevatedButton(
                onPressed: loading ? null : saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: diaButton,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  side: const BorderSide(color: diaGreen),
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'SAVE CHANGES',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
