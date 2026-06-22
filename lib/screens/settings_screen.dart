import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _system = 'metric';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _system = prefs.getString('setting_system') ?? 'metric');
  }

  Future<void> _saveSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    _loadCurrentSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Measurement System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(title: const Text('Metric (kg, cm)'), value: 'metric', groupValue: _system, activeColor: Theme.of(context).colorScheme.primary, onChanged: (val) => _saveSetting('setting_system', val!)),
                RadioListTile<String>(title: const Text('Imperial (lbs, inches)'), value: 'imperial', groupValue: _system, activeColor: Theme.of(context).colorScheme.primary, onChanged: (val) => _saveSetting('setting_system', val!)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}