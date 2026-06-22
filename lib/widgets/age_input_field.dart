import 'package:flutter/material.dart';

class AgeInputField extends StatelessWidget {
  final TextEditingController yearsController;
  final TextEditingController monthsController;
  final bool showAutoCalcHint;

  const AgeInputField({
    super.key,
    required this.yearsController,
    required this.monthsController,
    required this.showAutoCalcHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
            '  Age*',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 14, fontWeight: FontWeight.w700)
        ),
        const SizedBox(height: 8),
        Container(
          // CRITICAL FIX: Upgraded to 24px radius and thicker border to match the fun theme inputs!
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.cake_rounded, color: Theme.of(context).colorScheme.primary),
              ),
              Expanded(
                child: TextField(
                  controller: yearsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent, // Disable standard background
                  ),
                ),
              ),
              Text('Years', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),

              const SizedBox(width: 12),
              Container(width: 2, height: 32, color: const Color(0xFFE2E8F0)), // Thicker divider
              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: monthsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent, // Disable standard background
                  ),
                ),
              ),
              Text('Months', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w700)),
              const SizedBox(width: 20),
            ],
          ),
        ),

        if (showAutoCalcHint)
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 12.0),
            child: Text('Age is calculated automatically, but you can adjust it.', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          ),
      ],
    );
  }
}