
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MfaSignInPage extends StatefulWidget {
  final MultiFactorResolver resolver;

  const MfaSignInPage({
    super.key,
    required this.resolver,
  });

  @override
  State<MfaSignInPage> createState() => _MfaSignInPageState();
}

class _MfaSignInPageState extends State<MfaSignInPage> {
  final otpController = TextEditingController();

  String? verificationId;
  PhoneMultiFactorInfo? phoneHint;
  bool loading = false;
  String status = 'Preparing phone verification...';

  @override
  void initState() {
    super.initState();

    for (final hint in widget.resolver.hints) {
      if (hint is PhoneMultiFactorInfo) {
        phoneHint = hint;
        break;
      }
    }

    if (phoneHint == null) {
      status = 'No registered phone factor was found.';
    } else {
      sendOtp();
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    debugPrint('MFA DEBUG: sendOtp() called');

    final hint = phoneHint;
    if (hint == null) return;

    setState(() {
      loading = true;
      status = 'Sending SMS verification code...';
    });

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        multiFactorSession: widget.resolver.session,
        multiFactorInfo: hint,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => status =
              e.message ?? 'Failed to send SMS OTP.');
        },
        codeSent: (String id, int? resendToken) {
          if (!mounted) return;
          setState(() {
            verificationId = id;
            status = 'OTP sent. Enter the code received by SMS.';
          });
        },
        codeAutoRetrievalTimeout: (String id) {
          verificationId = id;
        },
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => status =
            e.message ?? 'MFA verification failed.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => status = 'Unable to send OTP: $e');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> verifyOtp() async {
    debugPrint('MFA DEBUG: verifyOtp() called');

    final id = verificationId;
    final code = otpController.text.trim();

    if (id == null || code.isEmpty) {
      setState(() => status =
          'Wait for the SMS and enter its OTP.');
      return;
    }

    setState(() {
      loading = true;
      status = 'Verifying OTP...';
    });

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: id,
        smsCode: code,
      );

      final assertion =
          PhoneMultiFactorGenerator.getAssertion(credential);

      print('MFA: Resolving sign-in...');

      final result =
          await widget.resolver.resolveSignIn(assertion);

      print('MFA: Sign-in resolved for ${result.user?.uid}');
      print(
        'MFA: Current user = '
        '${FirebaseAuth.instance.currentUser?.uid}',
      );

      if (!mounted) return;

      await result.user?.reload();

      if (!mounted) return;

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      print('MFA Firebase error: ${e.code} - ${e.message}');

      if (mounted) {
        setState(() => status = e.message ?? 'Invalid OTP.');
      }
    } catch (e, stackTrace) {
      print('MFA unexpected error: $e');
      print(stackTrace);

      if (mounted) {
        setState(() => status = 'Verification failed: $e');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final maskedPhone = phoneHint?.phoneNumber ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Two-step verification')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.security, size: 60),
                  const SizedBox(height: 16),
                  const Text(
                    'Verify your identity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    maskedPhone.isEmpty
                        ? 'Verify using your registered phone.'
                        : 'Enter the SMS code sent to $maskedPhone',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
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
                    onPressed: loading ? null : verifyOtp,
                    child: const Text('VERIFY AND SIGN IN'),
                  ),
                  TextButton(
                    onPressed: loading ? null : sendOtp,
                    child: const Text('RESEND OTP'),
                  ),
                  const SizedBox(height: 8),
                  Text(status, textAlign: TextAlign.center),
                  if (loading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
