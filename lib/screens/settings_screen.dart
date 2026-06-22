import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Import to access the appThemeNotifier
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _system = 'metric';
  String _theme = 'fun';

  @override
  void initState() {
    super.initState();
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _system = prefs.getString('setting_system') ?? 'metric';
      _theme = prefs.getString('app_theme') ?? 'fun';
    });
  }

  Future<void> _saveSystemSetting(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('setting_system', value);
    setState(() => _system = value);
  }

  Future<void> _saveThemeSetting(String value) async {
    await StorageService.setAppTheme(value);
    appThemeNotifier.value = value; // Trigger instant rebuild
    setState(() => _theme = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
          title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Theme Settings
          const Text('App Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                    title: const Text('🌟 Fun & Playful (Default)'),
                    value: 'fun',
                    groupValue: _theme,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => _saveThemeSetting(val!)
                ),
                RadioListTile<String>(
                    title: const Text('🩺 Standard Medical'),
                    value: 'standard',
                    groupValue: _theme,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => _saveThemeSetting(val!)
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Measurement Settings
          const Text('Measurement System', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                RadioListTile<String>(
                    title: const Text('Metric (kg, cm)'),
                    value: 'metric',
                    groupValue: _system,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => _saveSystemSetting(val!)
                ),
                RadioListTile<String>(
                    title: const Text('Imperial (lbs, inches)'),
                    value: 'imperial',
                    groupValue: _system,
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) => _saveSystemSetting(val!)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}