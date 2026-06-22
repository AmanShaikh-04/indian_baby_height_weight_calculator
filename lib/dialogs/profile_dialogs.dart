import 'package:flutter/material.dart';

class ProfileDialogs {
  static void showWelcomeProfile(BuildContext context, {required Function(String name, String gender, DateTime date) onCreate}) {
    _showFormDialog(context, title: 'Welcome! 🎉', subtitle: 'Create a profile for your child to quickly track their growth over time.', isWelcome: true, onCreate: onCreate);
  }

  static void showCreateProfile(BuildContext context, {required Function(String name, String gender, DateTime date) onCreate}) {
    _showFormDialog(context, title: 'New Child Profile', isWelcome: false, onCreate: onCreate);
  }

  static void showEditProfile(BuildContext context, {required String initialName, required String initialGender, required DateTime? initialDate, required Function(String name, String gender, DateTime date) onSave, required VoidCallback onDelete}) {
    _showFormDialog(context, title: 'Edit Profile', initialName: initialName, initialGender: initialGender, initialDate: initialDate, isWelcome: false, onCreate: onSave, onDelete: onDelete);
  }

  static void _showFormDialog(BuildContext context, {required String title, String? subtitle, String initialName = '', String initialGender = 'boys', DateTime? initialDate, required bool isWelcome, required Function(String name, String gender, DateTime date) onCreate, VoidCallback? onDelete}) {
    String tempName = initialName;
    String tempGender = initialGender;
    DateTime? tempDate = initialDate;

    showDialog(
        context: context,
        barrierDismissible: !isWelcome,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setStateDialog) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (subtitle != null) ...[Text(subtitle, style: const TextStyle(fontSize: 14)), const SizedBox(height: 20)],
                      TextFormField(initialValue: tempName, decoration: InputDecoration(labelText: 'Child\'s Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)), filled: true, fillColor: Colors.grey.shade50), onChanged: (val) => tempName = val),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [ButtonSegment(value: 'boys', label: Text('Boy'), icon: Icon(Icons.boy)), ButtonSegment(value: 'girls', label: Text('Girl'), icon: Icon(Icons.girl))],
                        selected: {tempGender},
                        onSelectionChanged: (newSelection) => setStateDialog(() => tempGender = newSelection.first),
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                        tileColor: Colors.grey.shade50,
                        title: Text(tempDate == null ? 'Select Birthdate*' : '${tempDate!.day}/${tempDate!.month}/${tempDate!.year}', style: TextStyle(color: tempDate == null ? Colors.grey.shade600 : Colors.black87)),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          DateTime? picked = await showDatePicker(context: context, initialDate: tempDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
                          if (picked != null) setStateDialog(() => tempDate = picked);
                        },
                      ),
                      if (onDelete != null) ...[
                        const SizedBox(height: 24),
                        OutlinedButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete_forever, color: Colors.red), label: const Text('Delete Profile', style: TextStyle(color: Colors.red)), style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), minimumSize: const Size.fromHeight(45)))
                      ]
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: Text(isWelcome ? 'Skip for now' : 'Cancel', style: TextStyle(color: isWelcome ? Colors.grey : Theme.of(context).colorScheme.primary))),
                    ElevatedButton(
                      onPressed: () {
                        if (tempName.trim().isEmpty || tempDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and birthdate are required.')));
                          return;
                        }
                        onCreate(tempName.trim(), tempGender, tempDate!);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white),
                      child: Text(onDelete != null ? 'Save Changes' : 'Create Profile'),
                    ),
                  ],
                );
              }
          );
        }
    );
  }
}