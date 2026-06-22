import 'package:flutter/material.dart';
import 'age_input_field.dart';

class InputFormCard extends StatelessWidget {
  final TextEditingController yearsController;
  final TextEditingController monthsController;
  final TextEditingController weightController;
  final TextEditingController heightController;

  final String system;
  final String quickCheckGender;
  final bool isQuickCheck;

  final String calcMode;
  final Function(String) onCalcModeChanged;
  final Function(String) onGenderChanged;
  final VoidCallback onCalculate;

  const InputFormCard({
    super.key,
    required this.yearsController,
    required this.monthsController,
    required this.weightController,
    required this.heightController,
    required this.system,
    required this.quickCheckGender,
    required this.isQuickCheck,
    required this.calcMode,
    required this.onCalcModeChanged,
    required this.onGenderChanged,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    String weightLabel = system == 'imperial' ? 'Weight (lbs)' : 'Weight (kg)';
    String heightLabel = system == 'imperial' ? 'Height (in)' : 'Height (cm)';

    return Card(
      // We removed elevation and shape here so it inherits the 32px bouncy radius from main.dart
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isQuickCheck) ...[
              Container(
                // Updated radius to 24 to match the new playful theme
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(24)),
                child: Row(
                  children: [
                    _buildGenderToggle('boys', 'Boy', Icons.boy, Colors.blue),
                    _buildGenderToggle('girls', 'Girl', Icons.girl, Colors.pink),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'full', label: FittedBox(child: Text('Full Check'))),
                  ButtonSegment(value: 'ideal_height', label: FittedBox(child: Text('Ideal Height'))),
                  ButtonSegment(value: 'ideal_weight', label: FittedBox(child: Text('Ideal Weight'))),
                ],
                selected: {calcMode},
                onSelectionChanged: (newSelection) => onCalcModeChanged(newSelection.first),
                style: ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap, visualDensity: VisualDensity.compact),
              ),
            ),
            const SizedBox(height: 24),

            AgeInputField(
                yearsController: yearsController,
                monthsController: monthsController,
                showAutoCalcHint: !isQuickCheck
            ),

            const SizedBox(height: 20),

            if (calcMode == 'full')
              Row(
                children: [
                  Expanded(child: _buildTextField(context, heightController, heightLabel, 'Required', Icons.height)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(context, weightController, weightLabel, 'Required', Icons.monitor_weight_outlined)),
                ],
              )
            else if (calcMode == 'ideal_height')
              _buildTextField(context, weightController, weightLabel, 'Required', Icons.monitor_weight_outlined)
            else if (calcMode == 'ideal_weight')
                _buildTextField(context, heightController, heightLabel, 'Required', Icons.height),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: onCalculate,
              // Removed the hardcoded style! It will now automatically pull the chunky shape and colors from main.dart
              child: const Text('Calculate Growth', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderToggle(String genderValue, String label, IconData icon, MaterialColor color) {
    bool isSelected = quickCheckGender == genderValue;
    return Expanded(
      child: GestureDetector(
        onTap: () => onGenderChanged(genderValue),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: isSelected ? color.shade100 : Colors.transparent, borderRadius: BorderRadius.circular(24)), // 24px Pill shape
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: isSelected ? color.shade800 : Colors.grey, size: 28),
                const SizedBox(width: 8),
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? color.shade800 : Colors.grey))
              ]
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, String hint, IconData icon, {TextInputType inputType = const TextInputType.numberWithOptions(decimal: true)}) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      // CRITICAL FIX: Removed all hardcoded borders, fills, and radii.
      // It will now inherit the exact bouncy theme we set globally!
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}