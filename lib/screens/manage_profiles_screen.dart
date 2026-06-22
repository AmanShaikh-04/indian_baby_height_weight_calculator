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
      // Create New
      final newProfile = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'gender': gender,
        'birthdate': date.toIso8601String()
      };
      _profiles.add(newProfile);

      // Auto-set as active if it's the very first profile
      if (_profiles.length == 1) {
        await StorageService.setActiveProfileId(newProfile['id']!);
      }
    } else {
      // Update Existing
      final idx = _profiles.indexWhere((p) => p['id'] == existingId);
      _profiles[idx]['name'] = name;
      _profiles[idx]['gender'] = gender;
      _profiles[idx]['birthdate'] = date.toIso8601String();

      // Cascade update to Diary entries
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
        title: const Text('Are you sure?'),
        content: const Text('This will permanently delete this child and all their saved growth records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              _profiles.removeWhere((p) => p['id'] == profileId);
              await StorageService.saveProfiles(_profiles);

              // Cascade delete from diary
              List<Map<String, dynamic>> diary = await StorageService.getDiary();
              diary.removeWhere((log) => log['profileId'] == profileId);
              await StorageService.saveDiary(diary);

              // Clear active profile if the deleted one was currently active
              String? activeId = await StorageService.getActiveProfileId();
              if (activeId == profileId) {
                await StorageService.setActiveProfileId(null);
              }

              _loadProfiles();
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete Permanently', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Manage Profiles', style: TextStyle(fontWeight: FontWeight.bold)),
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
            Icon(Icons.face_retouching_natural, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No profiles found.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _profiles.length,
        itemBuilder: (context, index) {
          final p = _profiles[index];
          bool isBoy = p['gender'] == 'boys';
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: isBoy ? Colors.blue.shade100 : Colors.pink.shade100,
                child: Icon(
                  isBoy ? Icons.boy : Icons.girl,
                  color: isBoy ? Colors.blue.shade700 : Colors.pink.shade700,
                ),
              ),
              title: Text(p['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(_calculateAgeString(p['birthdate'])),
              trailing: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
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
                ],
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
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}