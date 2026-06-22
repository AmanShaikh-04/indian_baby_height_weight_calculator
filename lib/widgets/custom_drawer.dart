import 'package:flutter/material.dart';

import '../screens/diary_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/manage_profiles_screen.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onReturn;

  const CustomDrawer({super.key, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface, // Pulling soft background
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 20),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 48, width: 48), // Slightly larger
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Growth\nCalculator',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary, height: 1.2),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1),

            const SizedBox(height: 16),

            ListTile(
              leading: Icon(Icons.calculate_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
              title: const Text('Growth Calculator', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: Icon(Icons.family_restroom_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
              title: const Text('Manage Profiles', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageProfilesScreen()),
                );
                onReturn();
              },
            ),

            ListTile(
              leading: Icon(Icons.menu_book_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
              title: const Text('Growth Diary', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DiaryScreen()),
                );
                onReturn();
              },
            ),

            ListTile(
              leading: Icon(Icons.settings_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
                onReturn();
              },
            ),

            const Spacer(),
            const Divider(height: 1, thickness: 1),
            ListTile(
              leading: Icon(Icons.privacy_tip_rounded, color: Colors.grey.shade500),
              title: Text('Legal & Data Privacy', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LegalScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}