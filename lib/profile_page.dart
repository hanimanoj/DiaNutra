import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

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
                child: const Column(
                  children: [
                    _ProfileInfo(
                      icon: Icons.cake_outlined,
                      label: 'Age',
                      value: '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.person_outline,
                      label: 'Gender',
                      value: '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.height,
                      label: 'Height',
                      value: '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.monitor_weight_outlined,
                      label: 'Weight',
                      value: '-',
                    ),
                    Divider(),
                    _ProfileInfo(
                      icon: Icons.health_and_safety_outlined,
                      label: 'Diabetes Type',
                      value: '-',
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
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(
                        Icons.lock_outline,
                        color: diaGreen,
                      ),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
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
                      onTap: () {},
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
