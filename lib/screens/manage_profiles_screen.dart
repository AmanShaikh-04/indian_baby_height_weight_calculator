import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import '../dialogs/profile_dialogs.dart';

class ManageProfilesScreen extends StatefulWidget {
  const ManageProfilesScreen({super.key});

  @override
  State<ManageProfilesScreen> createState() => _ManageProfilesScreenState();
}

class _ManageProfilesScreenState extends State<ManageProfilesScreen> {
  List<Map<String, dynamic>> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    final profiles = await StorageService.getProfiles();
    setState(() {
      _profiles = profiles;
      _isLoading = false;
    });
  }

  String _calculateAgeString(String? birthdateIso) {
    if (birthdateIso == null) return 'Unknown Age';
    DateTime dob = DateTime.parse(birthdateIso);
    DateTime now = DateTime.now();
    int years = now.year - dob.year;
    int months = now.month - dob.month;
    if (now.day < dob.day) months--;
    if (months < 0) {
      years--;
      months += 12;
    }
    return '$years Years, $months Months';
  }

  Future<void> _saveProfile(String name, String gender, DateTime date, {String? existingId}) async {
    if (existingId == null) {
      final newProfile = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'gender': gender,
        'birthdate': date.toIso8601String()
      };
      _profiles.add(newProfile);

      if (_profiles.length == 1) {
        await StorageService.setActiveProfileId(newProfile['id']!);
      }
    } else {
      final idx = _profiles.indexWhere((p) => p['id'] == existingId);
      _profiles[idx]['name'] = name;
      _profiles[idx]['gender'] = gender;
      _profiles[idx]['birthdate'] = date.toIso8601String();

      List<Map<String, dynamic>> diary = await StorageService.getDiary();
      for (var log in diary) {
        if (log['profileId'] == existingId) {
          log['name'] = name;
          log['gender'] = gender;
        }
      }
      await StorageService.saveDiary(diary);
    }

    await StorageService.saveProfiles(_profiles);
    _loadProfiles();
  }

  void _confirmDelete(String profileId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('This will permanently delete this child and all their saved growth records.', style: TextStyle(fontWeight: FontWeight.w500)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold))),
          TextButton(
            onPressed: () async {
              _profiles.removeWhere((p) => p['id'] == profileId);
              await StorageService.saveProfiles(_profiles);

              List<Map<String, dynamic>> diary = await StorageService.getDiary();
              diary.removeWhere((log) => log['profileId'] == profileId);
              await StorageService.saveDiary(diary);

              String? activeId = await StorageService.getActiveProfileId();
              if (activeId == profileId) {
                await StorageService.setActiveProfileId(null);
              }

              _loadProfiles();
              if (mounted) Navigator.pop(ctx);
            },
            child: Text('Delete Permanently', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface, // Dynamically use soft background
      appBar: AppBar(
        title: const Text('Manage Profiles', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profiles.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.face_retouching_natural_rounded, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No profiles found.', style: TextStyle(color: Colors.grey.shade600, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final p = _profiles[index];
          bool isBoy = p['gender'] == 'boys';
          return Card(
            // STRIPPED: Removed elevation and shape overrides.
            // It automatically becomes a bouncy card.
            margin: const EdgeInsets.only(bottom: 20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Extra padding for the big 32px corners
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: isBoy ? Colors.blue.shade100 : Colors.pink.shade100,
                      shape: BoxShape.circle
                  ),
                  child: Icon(
                    isBoy ? Icons.boy : Icons.girl,
                    size: 28,
                    color: isBoy ? Colors.blue.shade700 : Colors.pink.shade700,
                  ),
                ),
                title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                subtitle: Text(_calculateAgeString(p['birthdate']), style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
                trailing: IconButton(
                  icon: Icon(Icons.edit_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                  onPressed: () {
                    ProfileDialogs.showEditProfile(
                      context,
                      initialName: p['name'],
                      initialGender: p['gender'],
                      initialDate: p['birthdate'] != null ? DateTime.parse(p['birthdate']) : null,
                      onSave: (n, g, d) => _saveProfile(n, g, d, existingId: p['id']),
                      onDelete: () {
                        Navigator.pop(context);
                        _confirmDelete(p['id']);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ProfileDialogs.showCreateProfile(context, onCreate: (n, g, d) => _saveProfile(n, g, d));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Pill button shape
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text('Add Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
      ),
    );
  }
}