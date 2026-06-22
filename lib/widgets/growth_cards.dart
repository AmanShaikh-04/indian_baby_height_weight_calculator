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
    Color statusColor = isHealthy ? Colors.green.shade600 : Colors.orange.shade700;
    IconData statusIcon = isHealthy ? Icons.check_circle : Icons.info;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w600)), Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))]),
            const SizedBox(height: 12),
            Row(children: [Icon(statusIcon, color: statusColor, size: 20), const SizedBox(width: 8), Expanded(child: Text(status, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: statusColor)))]),
            const SizedBox(height: 16),
            VisualGauge(currentVal: currentVal, minLimit: minLimit, maxLimit: maxLimit),
            const SizedBox(height: 12),
            Text(rangeText, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.shade100, blurRadius: 4, offset: const Offset(0, 2))]), child: Icon(icon, color: color.shade700, size: 28)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 14, color: color.shade800, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text(targetValue, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: color.shade900)), const SizedBox(height: 4), Text(rangeText, style: TextStyle(fontSize: 12, color: color.shade700))])),
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
            Container(height: 8, decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.green.shade400, Colors.orange.shade300], stops: const [0.1, 0.5, 0.9]))),
            FractionallySizedBox(widthFactor: position, child: Align(alignment: Alignment.centerRight, child: Container(width: 16, height: 16, decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.black87, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 4, offset: const Offset(0, 2))])))),
          ],
        ),
        const SizedBox(height: 4),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Low', style: TextStyle(fontSize: 10, color: Colors.grey.shade500)), Text('High', style: TextStyle(fontSize: 10, color: Colors.grey.shade500))])
      ],
    );
  }
}

// NEW: Share and Brag Card for organic engagement
class ShareBragCard extends StatelessWidget {
  final String displaySnippet;
  final VoidCallback onShare;

  const ShareBragCard({super.key, required this.displaySnippet, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.purple.shade50, Colors.pink.shade50],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.purple.shade600),
                      const SizedBox(width: 8),
                      Text('Growth Milestone 🌟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.purple.shade800)),
                    ]
                ),
                const SizedBox(height: 12),
                Text(
                  displaySnippet,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.purple.shade900, height: 1.4, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onShare,
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share with Friends'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    elevation: 3,
                  ),
                )
              ],
            )
        )
    );
  }
}