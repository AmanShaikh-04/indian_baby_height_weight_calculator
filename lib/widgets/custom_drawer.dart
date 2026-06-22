import 'package:flutter/material.dart';

import '../screens/diary_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/legal_screen.dart';
import '../screens/manage_profiles_screen.dart'; // NEW IMPORT

class CustomDrawer extends StatelessWidget {
  final VoidCallback onReturn;

  const CustomDrawer({super.key, required this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
              child: Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 40, width: 40),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Indian Baby\nGrowth Calculator',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.calculate_outlined),
              title: const Text('Growth Calculator', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context); // Just close drawer, we are already here
              },
            ),

            // NEW: Manage Profiles Menu Item
            ListTile(
              leading: const Icon(Icons.family_restroom),
              title: const Text('Manage Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageProfilesScreen()),
                );
                onReturn(); // Refresh Home screen on return in case profiles changed
              },
            ),

            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('Growth Diary', style: TextStyle(fontWeight: FontWeight.bold)),
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
              leading: const Icon(Icons.settings),
              title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
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
            const Divider(),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('Legal & Data Privacy'),
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