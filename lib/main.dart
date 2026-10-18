import 'package:flutter/material.dart';
import 'patient_list.dart';

void main() {
  runApp(const DiaNutraApp());
}

class DiaNutraApp extends StatelessWidget {
  const DiaNutraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiaNutra',

      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFE8FBE5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF19B9D1),
        ),
        useMaterial3: true,
      ),

      home: const AppShell(
        child: PatientPage(),
      ),
    );
  }
}

// ============================================================
// GLOBAL APP SHELL
// ============================================================

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8FBE5),

      body: SafeArea(
        child: Column(
          children: [
            // GLOBAL HEADER
            _buildHeader(),

            // CURRENT PAGE
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HEADER
  // ==========================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        32,
        8,
        20,
        4,
      ),
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            // PAGE TITLE
            const Text(
              'T - Patient Page',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),

            const Spacer(),

            // TOGGLE
            Container(
              width: 46,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(left: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // NUTRINOVA LOGO
            Image.asset(
              'assets/images/nutrinova_logo.png',
              width: 70,
              height: 70,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}