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
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13, fontWeight: FontWeight.w600)
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Icon(Icons.cake_outlined, color: Theme.of(context).colorScheme.primary),
              ),
              Expanded(
                child: TextField(
                  controller: yearsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(hintText: '0', hintStyle: TextStyle(color: Colors.grey.shade400), border: InputBorder.none),
                ),
              ),
              Text('Years', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),

              const SizedBox(width: 12),
              Container(width: 1.5, height: 28, color: Colors.grey.shade300),
              const SizedBox(width: 12),

              Expanded(
                child: TextField(
                  controller: monthsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                  decoration: InputDecoration(hintText: '0', hintStyle: TextStyle(color: Colors.grey.shade400), border: InputBorder.none),
                ),
              ),
              Text('Months', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
            ],
          ),
        ),

        if (showAutoCalcHint)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Text('Age is calculated automatically, but you can adjust it if needed.', style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
          ),
      ],
    );
  }
}