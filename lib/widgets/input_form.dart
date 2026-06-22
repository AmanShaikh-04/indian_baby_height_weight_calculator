import 'package:flutter/material.dart';

class InputFormCard extends StatelessWidget {
  final TextEditingController ageController;
  final TextEditingController weightController;
  final TextEditingController heightController;

  final String system;
  final String ageUnit;
  final String quickCheckGender;
  final bool isQuickCheck;

  final Function(String) onAgeUnitChanged;
  final Function(String) onGenderChanged;
  final VoidCallback onCalculate;

  const InputFormCard({
    super.key,
    required this.ageController,
    required this.weightController,
    required this.heightController,
    required this.system,
    required this.ageUnit,
    required this.quickCheckGender,
    required this.isQuickCheck,
    required this.onAgeUnitChanged,
    required this.onGenderChanged,
    required this.onCalculate,
  });

  @override
  Widget build(BuildContext context) {
    String weightLabel = system == 'imperial' ? 'Weight (lbs)' : 'Weight (kg)';
    String heightLabel = system == 'imperial' ? 'Height (in)' : 'Height (cm)';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isQuickCheck) ...[
              Container(
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _buildGenderToggle('boys', 'Boy', Icons.boy, Colors.blue),
                    _buildGenderToggle('girls', 'Girl', Icons.girl, Colors.pink),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            TextField(
              controller: ageController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Age*',
                hintText: ageUnit == 'months' ? 'e.g. 30' : 'e.g. 2.5',
                prefixIcon: Icon(Icons.cake_outlined, color: Theme.of(context).colorScheme.primary),
                suffixIcon: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: ageUnit,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      items: const [
                        DropdownMenuItem(value: 'months', child: Text('Months')),
                        DropdownMenuItem(value: 'years', child: Text('Years'))
                      ],
                      onChanged: (val) => onAgeUnitChanged(val!),
                    ),
                  ),
                ),
                filled: true, fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(child: _buildTextField(context, weightController, weightLabel, '(Optional)', Icons.monitor_weight_outlined)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(context, heightController, heightLabel, '(Optional)', Icons.height)),
              ],
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: onCalculate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              child: const Text('Calculate Growth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isSelected ? color.shade100 : Colors.transparent, borderRadius: BorderRadius.circular(12)),
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

  Widget _buildTextField(BuildContext context, TextEditingController controller, String label, String hint, IconData icon) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey.shade400),
        filled: true, fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)),
      ),
    );
  }
}