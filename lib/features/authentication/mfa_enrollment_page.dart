
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MfaEnrollmentPage extends StatefulWidget {
  final VoidCallback onEnrolled;

  const MfaEnrollmentPage({
    super.key,
    required this.onEnrolled,
  });

  @override
  State<MfaEnrollmentPage> createState() => _MfaEnrollmentPageState();
}

class _MfaEnrollmentPageState extends State<MfaEnrollmentPage> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String? verificationId;
  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> sendOtp() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      showMessage('Enter your phone number with country code.');
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showMessage('Please sign in again.');
      return;
    }

    setState(() => loading = true);

    try {
      final session = await user.multiFactor.getSession();

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        multiFactorSession: session,
        verificationCompleted: (_) {},
        verificationFailed: (error) {
          showMessage(error.message ?? 'Could not send SMS.');
        },
        codeSent: (id, resendToken) {
          if (!mounted) return;
          setState(() => verificationId = id);
          showMessage('OTP sent. Check your phone.');
        },
        codeAutoRetrievalTimeout: (id) {
          verificationId = id;
        },
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'MFA setup failed.');
    } catch (e) {
      showMessage('Unable to start phone verification.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> verifyOtp() async {
    final id = verificationId;
    final code = otpController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (id == null || code.isEmpty || user == null) {
      showMessage('Request an OTP and enter the code first.');
      return;
    }

    setState(() => loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: code,
      );

      final assertion =
          PhoneMultiFactorGenerator.getAssertion(credential);

      await user.multiFactor.enroll(
        assertion,
        displayName: phoneController.text.trim(),
      );

      if (!mounted) return;

      showMessage('MFA phone factor enrolled successfully.');

      widget.onEnrolled();
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Could not verify OTP.');
    } catch (e) {
      showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up SMS MFA')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.security, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'Secure your DiaNutra account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone number',
                      hintText: '+60123456789',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: loading ? null : sendOtp,
                    child: const Text('SEND SMS OTP'),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'SMS verification code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed:
                        loading ? null : verifyOtp,
                    child: const Text('VERIFY AND ENABLE MFA'),
                  ),
                  if (loading) ...[
                    const SizedBox(height: 16),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
