import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DiaNutraHeader extends StatelessWidget
    implements PreferredSizeWidget {
  const DiaNutraHeader({super.key});

  static const Color diaGreen = Color(0xFF176744);
  static const Color diaMint = Color(0xFFF3FFF0);

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: diaMint,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      title: const Text(
        'DiaNutra',
        style: TextStyle(
          color: diaGreen,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          'assets/images/dianutra_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(
            Icons.spa,
            color: diaGreen,
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(
            Icons.logout,
            color: diaGreen,
          ),
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Log out?'),
                content: const Text(
                  'Are you sure you want to log out of DiaNutra?',
                ),
                actions: [
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pop(dialogContext, true),
                    child: const Text('Log out'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              await FirebaseAuth.instance.signOut();
            }
          },
        ),
      ],
    );
  }
}
