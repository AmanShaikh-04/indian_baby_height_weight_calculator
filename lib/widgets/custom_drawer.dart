import 'package:flutter/material.dart';
import '../screens/diary_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/legal_screen.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback? onReturn;

  const CustomDrawer({super.key, this.onReturn});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.horizontal(right: Radius.circular(30))),
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 70, bottom: 30, left: 24, right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Colors.teal.shade300], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: ClipOval(
                      child: Image.asset('assets/images/logo.png', height: 80, width: 80, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Indian Baby Height\nWeight Calculator', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Your Child\'s Growth Partner', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _buildDrawerItem(context, icon: Icons.calculate_outlined, title: 'Growth Calculator', onTap: () => Navigator.pop(context)),
            _buildDrawerItem(context, icon: Icons.menu_book_rounded, title: 'My Growth Diary', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DiaryScreen())).then((_) => onReturn?.call());
            }),
            _buildDrawerItem(context, icon: Icons.settings_outlined, title: 'Settings', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen())).then((_) => onReturn?.call());
            }),

            const Spacer(),
            const Divider(),

            _buildDrawerItem(context, icon: Icons.privacy_tip_outlined, title: 'Privacy & Legal', onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LegalScreen()));
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: Colors.grey.shade700),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
        onTap: onTap,
      ),
    );
  }
}