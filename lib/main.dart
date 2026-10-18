
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'firebase_options.dart';
import 'patient_list.dart';

const Color mint = Color(0xFF79C2A0);
const Color green = Color(0xFF2F7948);
const Color darkGreen = Color(0xFF17623B);
const Color paleGreen = Color(0xFFE8FBE5);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    await GoogleSignIn.instance.initialize();
  }

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
        scaffoldBackgroundColor: mint,
        colorScheme: ColorScheme.fromSeed(seedColor: green),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

// SPLASH SCREEN

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: BrandLogo(size: 120)),
    );
  }
}

// AUTHENTICATION ROUTING

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: green),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          if (user.email != null &&
              !user.emailVerified &&
              user.providerData.any(
                (p) => p.providerId == 'password',
              )) {
            return VerifyEmailPage(email: user.email!);
          }

          return const AppShell(child: PatientPage());
        }

        return const LoginPage();
      },
    );
  }
}

// REUSABLE LOGO


class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({
    super.key,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.8,
      height: size,
      child: Image.asset(
        'assets/images/dianutra_logo.png',
        fit: BoxFit.contain,
        alignment: Alignment.center,
      ),
    );
  }
}

// SHARED AUTH CARD

class AuthCard extends StatelessWidget {
  final List<Widget> children;

  const AuthCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      constraints: const BoxConstraints(maxWidth: 380),
      padding: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 30,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: child,
          ),
        ),
      ),
    );
  }
}

class FieldLabel extends StatelessWidget {
  final String text;

  const FieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: darkGreen,
          fontSize: 12,
        ),
      ),
    );
  }
}

class InputField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool obscure;
  final TextInputType keyboardType;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  const InputField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.obscure = false,
    this.keyboardType = TextInputType.text,
    this.suffix,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 19),
        suffixIcon: suffix,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        hintStyle: const TextStyle(
          color: Colors.black26,
          fontSize: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: green),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(11),
          borderSide: const BorderSide(color: darkGreen, width: 1.5),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: mint,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
            side: const BorderSide(color: Colors.green),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
      ),
    );
  }
}

class AuthTabs extends StatelessWidget {
  final bool signUp;

  const AuthTabs({super.key, required this.signUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: green),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          _tab(context, 'LOGIN', !signUp, () {
            if (signUp) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            }
          }),
          _tab(context, 'SIGN UP', signUp, () {
            if (!signUp) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SignUpPage()),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? mint : Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

// LOGIN PAGE

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  
  Future<void> login() async {
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      message(context, 'Please enter your email and password.');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      // Refresh the user's latest verification status.
      await result.user?.reload();

      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(code: 'user-not-found');
      }

      if (!user.emailVerified &&
          user.providerData.any((p) => p.providerId == 'password')) {
        await FirebaseAuth.instance.signOut();

        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VerifyEmailPage(email: email.text.trim()),
          ),
        );

        return;
      }

      // AuthGate will navigate to PatientPage automatically.
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        message(context, e.message ?? 'Login failed.');
      }
    } catch (e) {
      if (mounted) {
        message(context, 'Unable to log in. Please try again.');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }


  Future<void> googleLogin() async {
    setState(() => loading = true);

    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
      } else {
        final account = await GoogleSignIn.instance.authenticate();
        final googleAuth = account.authentication;

        final credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
        );

        await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) message(context, e.message ?? 'Google sign-in failed.');
    } catch (e) {
      if (mounted) message(context, 'Google sign-in was cancelled or failed.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          const Center(child: BrandLogo(size: 85)),
          const SizedBox(height: 26),
          const AuthTabs(signUp: false),
          const SizedBox(height: 34),
          const FieldLabel('Email :'),
          InputField(
            hint: 'Enter your email',
            icon: Icons.mail_outline,
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          const FieldLabel('Password :'),
          InputField(
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            controller: password,
            obscure: hidePassword,
            onSubmitted: (_) => login(),
            suffix: IconButton(
              onPressed: () => setState(() => hidePassword = !hidePassword),
              icon: Icon(
                hidePassword ? Icons.visibility_off : Icons.visibility,
                size: 18,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ForgotPasswordPage(),
                ),
              ),
              child: const Text(
                'Forgot Password ?',
                style: TextStyle(color: darkGreen, fontSize: 11),
              ),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'LOGIN',
            loading: loading,
            onPressed: login,
          ),
          const SizedBox(height: 10),
          const Center(child: Text('OR')),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: loading ? null : googleLogin,
            icon: Image.asset(
              'assets/images/google_icon.png',
              width: 12,
              height: 12,
              fit: BoxFit.contain,
            ),
            label: const Text(
              'SIGN IN USING GOOGLE',
              style: TextStyle(fontSize: 11, color: Colors.black),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 42),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Wrap(
              children: [
                const Text(
                  "Don't have any account? ",
                  style: TextStyle(fontSize: 10),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpPage()),
                  ),
                  child: const Text(
                    'Sign Up Here',
                    style: TextStyle(
                      color: darkGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MANUAL SIGN-UP PAGE

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  Future<void> register() async {
    if (name.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.isEmpty ||
        confirmPassword.text.isEmpty) {
      message(context, 'Please complete all fields.');
      return;
    }

    if (password.text.length < 6) {
      message(context, 'Password must contain at least 6 characters.');
      return;
    }

    if (password.text != confirmPassword.text) {
      message(context, 'Passwords do not match.');
      return;
    }

    setState(() => loading = true);

    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      await result.user?.updateDisplayName(name.text.trim());
      await result.user?.sendEmailVerification();

      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailPage(email: email.text.trim()),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) message(context, e.message ?? 'Sign-up failed.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          const Center(child: BrandLogo(size: 80)),
          const SizedBox(height: 24),
          const AuthTabs(signUp: true),
          const SizedBox(height: 24),
          const FieldLabel('Full Name :'),
          InputField(
            hint: 'Enter your full name',
            icon: Icons.person_outline,
            controller: name,
          ),
          const SizedBox(height: 14),
          const FieldLabel('Email :'),
          InputField(
            hint: 'Enter your email',
            icon: Icons.mail_outline,
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          const FieldLabel('Password :'),
          InputField(
            hint: 'Enter your password',
            icon: Icons.lock_outline,
            controller: password,
            obscure: hidePassword,
          ),
          const SizedBox(height: 14),
          const FieldLabel('Confirm Password :'),
          InputField(
            hint: 'Re-enter your password',
            icon: Icons.lock_outline,
            controller: confirmPassword,
            obscure: true,
          ),
          const SizedBox(height: 28),
          PrimaryButton(
            text: 'SIGN UP',
            loading: loading,
            onPressed: register,
          ),
        ],
      ),
    );
  }
}

// EMAIL VERIFICATION PAGE

class VerifyEmailPage extends StatefulWidget {
  final String email;

  const VerifyEmailPage({super.key, required this.email});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool loading = false;

  Future<void> resend() async {
    message(
      context,
      'Please sign in again to request a new verification email.',
    );
  }

  Future<void> checkVerification() async {
    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );

      message(context, 'Open the email verification link, then log in.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          const Center(child: BrandLogo(size: 90)),
          const SizedBox(height: 28),
          const Text(
            'Verify your email',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'A verification link has been sent to:\n${widget.email}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'BACK TO LOGIN',
            loading: loading,
            onPressed: checkVerification,
          ),
          TextButton(
            onPressed: resend,
            child: const Text(
              'Resend verification email',
              style: TextStyle(color: darkGreen, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// FORGOT PASSWORD

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final email = TextEditingController();
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (email.text.trim().isEmpty) {
      message(context, 'Please enter your email.');
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email.text.trim(),
      );

      if (mounted) {
        message(context, 'Password reset email requested.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) message(context, e.message ?? 'Request failed.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: AuthCard(
        children: [
          const Center(child: BrandLogo(size: 90)),
          const SizedBox(height: 24),
          const Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: darkGreen,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const FieldLabel('Email :'),
          InputField(
            hint: 'Enter your email',
            icon: Icons.mail_outline,
            controller: email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: 'RESET PASSWORD',
            loading: loading,
            onPressed: resetPassword,
          ),
        ],
      ),
    );
  }
}

// EXISTING PATIENT PAGE SHELL

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleGreen,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 8, 20, 4),
              child: SizedBox(
                height: 55,
                child: Row(
                  children: [
                    const Text(
                      'DiaNutra - Patient Page',
                      style: TextStyle(fontSize: 20),
                    ),
                    const Spacer(),
                    Image.asset(
                      'assets/images/dianutra_logo.png',
                      width: 50,
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                    IconButton(
                      tooltip: 'Sign out',
                      onPressed: () => FirebaseAuth.instance.signOut(),
                      icon: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

void message(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text)),
  );
}
