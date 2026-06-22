import 'package:flutter/material.dart';

class ProfileHorizontalBar extends StatelessWidget {
  final List<Map<String, dynamic>> profiles;
  final String? activeProfileId;
  final Function(String?) onProfileSelected;
  final Function(String) onEditProfile;
  final VoidCallback onCreateNew;

  const ProfileHorizontalBar({
    super.key,
    required this.profiles,
    required this.activeProfileId,
    required this.onProfileSelected,
    required this.onEditProfile,
    required this.onCreateNew,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Who are we checking?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
              if (profiles.isNotEmpty)
                Text('Long-press a child to edit', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildAvatar(id: null, name: 'Quick Check', icon: Icons.speed, color: Colors.orange),
              ...profiles.map((p) => _buildAvatar(
                  id: p['id'],
                  name: p['name'],
                  icon: p['gender'] == 'boys' ? Icons.boy : Icons.girl,
                  color: p['gender'] == 'boys' ? Colors.blue : Colors.pink
              )),
              _buildAvatar(id: 'ADD', name: 'Add Child', icon: Icons.add, color: Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar({required String? id, required String name, required IconData icon, required MaterialColor color}) {
    bool isSelected = activeProfileId == id && id != 'ADD';

    return GestureDetector(
      onTap: () {
        if (id == 'ADD') {
          onCreateNew();
        } else {
          onProfileSelected(id);
        }
      },
      onLongPress: () {
        if (id != null && id != 'ADD') {
          onEditProfile(id);
        }
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? color.shade700 : Colors.transparent, width: 3),
                boxShadow: isSelected ? [BoxShadow(color: color.shade200, blurRadius: 8, spreadRadius: 2)] : null,
              ),
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: isSelected ? color.shade100 : Colors.grey.shade100,
                    child: Icon(icon, size: 30, color: isSelected ? color.shade800 : Colors.grey.shade600),
                  ),
                  if (id != null && id != 'ADD' && isSelected)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: color.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        child: const Icon(Icons.edit, size: 10, color: Colors.white),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? color.shade800 : Colors.grey.shade700)
            ),
          ],
        ),
      ),
    );
  }
}