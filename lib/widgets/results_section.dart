import 'package:flutter/material.dart';
import 'growth_cards.dart';
import '../models/assessment_data.dart';

class ResultsSection extends StatelessWidget {
  final String system;
  final bool hasActiveProfile;
  final AssessmentData data;
  final String bragSnippet;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ResultsSection({
    super.key,
    required this.system,
    required this.hasActiveProfile,
    required this.data,
    required this.bragSnippet,
    required this.onSave,
    required this.onShare,
  });

  String _formatWeight(double kgVal) => system == 'imperial' ? '${(kgVal * 2.20462).toStringAsFixed(1)} lbs' : '${kgVal.toStringAsFixed(1)} kg';
  String _formatHeight(double cmVal) => system == 'imperial' ? '${(cmVal / 2.54).toStringAsFixed(1)} in' : '${cmVal.toStringAsFixed(1)} cm';

  @override
  Widget build(BuildContext context) {
    bool canSave = data.inputWeight != null && data.inputHeight != null;
    String wUnit = system == 'imperial' ? 'lbs' : 'kg';
    String hUnit = system == 'imperial' ? 'in' : 'cm';
    String saveBtnText = !hasActiveProfile ? 'Select Profile to Save' : 'Save to Profile Diary';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canSave) ...[
          ElevatedButton.icon(
            onPressed: () {
              if (!hasActiveProfile) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select or create a profile at the top to save data.')));
              else onSave();
            },
            icon: const Icon(Icons.bookmark_add_rounded),
            label: Text(saveBtnText),
            // Removed hardcoded shape so it inherits the pill button theme from main.dart
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: !hasActiveProfile ? Colors.orange.shade500 : Theme.of(context).colorScheme.primary, // Using theme primary color when active
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
        ],

        ShareBragCard(displaySnippet: bragSnippet, onShare: onShare),
        const SizedBox(height: 24),

        const Padding(padding: EdgeInsets.only(left: 8.0, bottom: 12), child: Text('Assessment', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),

        if (data.inputHeight != null) AssessmentCard(title: 'Height Check', value: '${data.inputHeight} $hUnit', status: data.heightStatus, isHealthy: data.heightStatus.contains('Healthy'), rangeText: 'Healthy range: ${_formatHeight(data.idealHeightMin)} to ${_formatHeight(data.idealHeightMax)}', currentVal: system == 'imperial' ? data.inputHeight! * 2.54 : data.inputHeight!, minLimit: data.p3Height, maxLimit: data.p97Height)
        else GuidanceCard(title: 'Ideal Target Height', targetValue: _formatHeight(data.idealHeightTarget), rangeText: 'Healthy range: ${_formatHeight(data.idealHeightMin)} to ${_formatHeight(data.idealHeightMax)}', icon: Icons.height, color: Colors.teal),

        const SizedBox(height: 16),

        if (data.inputWeight != null) AssessmentCard(title: 'Weight Check', value: '${data.inputWeight} $wUnit', status: data.weightStatus, isHealthy: data.weightStatus.contains('Healthy'), rangeText: 'Healthy range: ${_formatWeight(data.idealWeightMin)} to ${_formatWeight(data.idealWeightMax)}', currentVal: system == 'imperial' ? data.inputWeight! / 2.20462 : data.inputWeight!, minLimit: data.p3Weight, maxLimit: data.p97Weight)
        else GuidanceCard(title: 'Ideal Target Weight', targetValue: _formatWeight(data.idealWeightTarget), rangeText: 'Healthy range: ${_formatWeight(data.idealWeightMin)} to ${_formatWeight(data.idealWeightMax)}', icon: Icons.monitor_weight_outlined, color: Colors.blue),
      ],
    );
  }
}