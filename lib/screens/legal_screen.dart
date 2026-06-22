import 'package:flutter/material.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Privacy & Legal', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSection(context, icon: Icons.medical_information, title: 'Medical Disclaimer', content: 'Indian Baby Height Weight Calculator is an informational tool designed to track growth metrics based on the public datasets provided by the World Health Organization (WHO) and the Indian Academy of Pediatrics (IAP).\n\nThis app is NOT a medical device. The information provided by this app does not constitute medical advice, diagnosis, or treatment. Always consult a qualified pediatrician or healthcare professional regarding your child\'s health and development.'),
            const SizedBox(height: 16),
            _buildSection(context, icon: Icons.privacy_tip, title: 'Privacy Policy', content: 'Your privacy and your child\'s privacy are our highest priority.\n\n• Local Storage Only: All data entered into this app, including age, weight, height, and diary logs, is saved strictly locally on your physical device.\n• No Data Collection: We do not collect, transmit, upload, or sell your personal or health data to any external servers or third parties.\n• Data Deletion: Because data is not stored on a cloud server, if you uninstall the app or clear the app\'s data, your diary records will be permanently deleted.'),
            const SizedBox(height: 16),
            _buildSection(context, icon: Icons.gavel, title: 'Terms of Use', content: 'By using the Indian Baby Height Weight Calculator, you acknowledge that you are using this application at your own risk. The developer makes no warranties, express or implied, regarding the accuracy or completeness of the calculations.\n\nThe developer is not liable for any damages or health consequences resulting from the use or inability to use this application.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required IconData icon, required String title, required String content}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(icon, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
            const SizedBox(height: 16),
            Text(content, style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5)),
          ],
        ),
      ),
    );
  }
}