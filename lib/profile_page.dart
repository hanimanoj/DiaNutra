import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color diaGreen = Color(0xFF176744);
  static const Color diaMint = Color(0xFFF3FFF0);
  static const Color diaCard = Color(0xFFC9DFCD);

  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final data = await FirestoreService().getUserProfile();

      if (!mounted) return;

      setState(() {
        userProfile = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> showChangePasswordDialog() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final hasPasswordProvider = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );

    if (!hasPasswordProvider) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Password'),
          content: const Text(
            'Your account uses Google Sign-In. '
            'Please manage your password through your Google Account.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool loading = false;
    bool hideCurrent = true;
    bool hideNew = true;
    bool hideConfirm = true;

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              Future<void> updatePassword() async {
                final currentPassword =
                    currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword =
                    confirmPasswordController.text;

                if (currentPassword.isEmpty ||
                    newPassword.isEmpty ||
                    confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please complete all fields.'),
                    ),
                  );
                  return;
                }

                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New password must contain at least 6 characters.',
                      ),
                    ),
                  );
                  return;
                }

                if (newPassword != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('New passwords do not match.'),
                    ),
                  );
                  return;
                }

                if (currentPassword == newPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'New password must be different from current password.',
                      ),
                    ),
                  );
                  return;
                }

                setDialogState(() => loading = true);

                try {
                  final credential = EmailAuthProvider.credential(
                    email: user.email!,
                    password: currentPassword,
                  );

                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPassword);

                  if (!dialogContext.mounted) return;

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Password changed successfully!',
                      ),
                      backgroundColor: diaGreen,
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() => loading = false);

                  String errorMessage;

                  if (e.code == 'wrong-password' ||
                      e.code == 'invalid-credential') {
                    errorMessage = 'Current password is incorrect.';
                  } else if (e.code == 'weak-password') {
                    errorMessage = 'Please choose a stronger password.';
                  } else if (e.code == 'requires-recent-login') {
                    errorMessage =
                        'Please sign in again before changing your password.';
                  } else {
                    errorMessage =
                        e.message ?? 'Unable to change password.';
                  }

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(errorMessage)),
                  );
                } catch (e) {
                  if (!dialogContext.mounted) return;

                  setDialogState(() => loading = false);

                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Unable to change password: $e'),
                    ),
                  );
                }
              }

              return AlertDialog(
                backgroundColor: diaMint,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Change Password',
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Enter your current password and choose a new password.',
                          style: TextStyle(fontSize: 13),
                        ),

                        const SizedBox(height: 20),

                        const Text('Current Password'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: currentPasswordController,
                          obscureText: hideCurrent,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideCurrent
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setDialogState(
                                  () => hideCurrent = !hideCurrent,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text('New Password'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: newPasswordController,
                          obscureText: hideNew,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideNew
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setDialogState(
                                  () => hideNew = !hideNew,
                                );
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text('Confirm New Password'),
                        const SizedBox(height: 6),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: hideConfirm,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                hideConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setDialogState(
                                  () => hideConfirm = !hideConfirm,
                                );
                              },
                            ),
                          ),
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
                              : () => Navigator.pop(dialogContext),
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
                          onPressed: loading ? null : updatePassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF70B99A),
                            foregroundColor: Colors.white,
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
                                  'SAVE',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      );
    } finally {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: diaMint,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: diaGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: diaMint,
        elevation: 0,
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Profile Header
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: diaCard,
                      child: const Icon(
                        Icons.person,
                        size: 55,
                        color: diaGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isLoading
                          ? 'Loading...'
                          : userProfile?['name'] ?? 'User Name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: diaGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLoading
                          ? 'Loading...'
                          : userProfile?['email'] ?? 'No email available',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Personal Information
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: diaGreen,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: diaGreen),
                ),
                child: Column(
                  children: [
                    _ProfileInfo(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: userProfile?['age']?.toString() ?? '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.person_outline,
                      label: 'Gender',
                      value: userProfile?['gender'] ?? '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.height,
                      label: 'Height',
                      value: userProfile?['height'] != null ? '${userProfile!['height']} cm' : '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: userProfile?['weight'] != null ? '${userProfile!['weight']} kg' : '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.health_and_safety_outlined,
                      label: 'Diabetes Type',
                      value: userProfile?['diabetesType'] ?? '-',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Settings
              const Text(
                'Account Settings',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: diaGreen,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: diaGreen),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.edit_outlined,
                        color: diaGreen,
                      ),
                      title: const Text('Edit Profile'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final updated = await showDialog<bool>(
                          context: context,
                          builder: (_) => EditProfilePage(
                            profile: userProfile ?? {},
                          ),
                        );

                        if (updated == true) {
                          await loadUserProfile();
                        }
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                        color: diaGreen,
                      ),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: showChangePasswordDialog,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.red,
                      ),
                      onTap: () async {
                        await signOut();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF176744)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
