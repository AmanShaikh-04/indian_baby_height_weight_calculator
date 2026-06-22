import 'package:flutter/material.dart';

class AssessmentCard extends StatelessWidget {
  final String title;
  final String value;
  final String status;
  final bool isHealthy;
  final String rangeText;
  final double currentVal;
  final double minLimit;
  final double maxLimit;

  const AssessmentCard({super.key, required this.title, required this.value, required this.status, required this.isHealthy, required this.rangeText, required this.currentVal, required this.minLimit, required this.maxLimit});

  @override
  Widget build(BuildContext context) {
    Color statusColor = isHealthy ? Colors.green.shade600 : Theme.of(context).colorScheme.tertiary; // Use theme alert color
    IconData statusIcon = isHealthy ? Icons.check_circle_rounded : Icons.info_rounded;

    return Card(
      // Completely inherits the 32px shape and thick borders from main.dart
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600)), Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 12),
            Row(children: [Icon(statusIcon, color: statusColor, size: 24), const SizedBox(width: 8), Expanded(child: Text(status, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)))]),
            const SizedBox(height: 20),
            VisualGauge(currentVal: currentVal, minLimit: minLimit, maxLimit: maxLimit),
            const SizedBox(height: 16),
            Text(rangeText, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class GuidanceCard extends StatelessWidget {
  final String title;
  final String targetValue;
  final String rangeText;
  final IconData icon;
  final MaterialColor color;

  const GuidanceCard({super.key, required this.title, required this.targetValue, required this.rangeText, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.shade50,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            // Removed drop shadow to make it flat, soft, and modern
            Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(icon, color: color.shade700, size: 32)
            ),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 15, color: color.shade800, fontWeight: FontWeight.w800)), const SizedBox(height: 4), Text(targetValue, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color.shade900)), const SizedBox(height: 4), Text(rangeText, style: TextStyle(fontSize: 13, color: color.shade700, fontWeight: FontWeight.w500))])),
          ],
        ),
      ),
    );
  }
}

class VisualGauge extends StatelessWidget {
  final double currentVal;
  final double minLimit;
  final double maxLimit;

  const VisualGauge({super.key, required this.currentVal, required this.minLimit, required this.maxLimit});

  @override
  Widget build(BuildContext context) {
    double range = maxLimit - minLimit;
    double visualMin = minLimit - (range * 0.1);
    double visualMax = maxLimit + (range * 0.1);
    double position = ((currentVal - visualMin) / (visualMax - visualMin)).clamp(0.0, 1.0);

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 12, decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.green.shade400, Colors.orange.shade300], stops: const [0.1, 0.5, 0.9]))),
            FractionallySizedBox(widthFactor: position, child: Align(alignment: Alignment.centerRight, child: Container(width: 20, height: 20, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black87, width: 3))))), // Made slider pip slightly thicker and flatter
          ],
        ),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Low', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600)), Text('High', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w600))])
      ],
    );
  }
}

class ShareBragCard extends StatelessWidget {
  final String displaySnippet;
  final VoidCallback onShare;

  const ShareBragCard({super.key, required this.displaySnippet, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Removed local elevation and shape! Inherits the giant bouncy border automatically
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32), // Upped from 16 to 32 to match Fun Theme Card shape
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary.withOpacity(0.15), Theme.of(context).colorScheme.secondary.withOpacity(0.15)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Theme.of(context).colorScheme.primary, size: 28),
                      const SizedBox(width: 8),
                      Text('Growth Milestone 🌟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Theme.of(context).colorScheme.primary)),
                    ]
                ),
                const SizedBox(height: 16),
                Text(
                  displaySnippet,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Share with Friends'),
                  // STRIPPED completely! It now automatically becomes a chunky,
                  // colorful pill-shaped button by inheriting from main.dart
                )
              ],
            )
        )
    );
  }
}