import '../models/assessment_data.dart';

class GrowthEngine {
  // Calculates everything and returns a single AssessmentData object
  static AssessmentData evaluate({
    required Map<String, dynamic> growthData,
    required String gender,
    required int ageMonths,
    required double? rawWeight,
    required double? rawHeight,
    required String system,
  }) {
    double? calcWeightKg = rawWeight;
    double? calcHeightCm = rawHeight;

    if (system == 'imperial') {
      if (calcWeightKg != null) calcWeightKg = rawWeight! / 2.20462;
      if (calcHeightCm != null) calcHeightCm = rawHeight! * 2.54;
    }

    // Mathematical Validations
    if (calcWeightKg != null && (calcWeightKg < 1 || calcWeightKg > 150)) {
      throw '⚠️ Please enter a realistic weight.';
    }
    if (calcHeightCm != null && (calcHeightCm < 30 || calcHeightCm > 250)) {
      throw '⚠️ Please enter a realistic height.';
    }

    final List<dynamic> weightChart = growthData[gender]['weight'];
    final List<dynamic> heightChart = growthData[gender]['height'];

    final matchedWeightRow = weightChart.firstWhere((row) => row['age_months'] >= ageMonths, orElse: () => weightChart.last);
    final matchedHeightRow = heightChart.firstWhere((row) => row['age_months'] >= ageMonths, orElse: () => heightChart.last);

    double p3W = (matchedWeightRow['p3'] as num).toDouble();
    double iWM = (matchedWeightRow['p15'] as num).toDouble();
    double iWT = (matchedWeightRow['p50'] as num).toDouble();
    double iWMx = (matchedWeightRow['p85'] as num).toDouble();
    double p97W = (matchedWeightRow['p97'] as num).toDouble();

    double p3H = (matchedHeightRow['p3'] as num).toDouble();
    double iHM = (matchedHeightRow['p15'] as num).toDouble();
    double iHT = (matchedHeightRow['p50'] as num).toDouble();
    double iHMx = (matchedHeightRow['p85'] as num).toDouble();
    double p97H = (matchedHeightRow['p97'] as num).toDouble();

    String wStatus = '';
    if (calcWeightKg != null) {
      if (calcWeightKg < p3W) wStatus = 'Needs Doctor\'s Advice (Very Low)';
      else if (calcWeightKg < iWM) wStatus = 'On the Lighter Side';
      else if (calcWeightKg <= iWMx) wStatus = 'Perfectly Healthy Weight 🌟';
      else if (calcWeightKg <= p97W) wStatus = 'On the Heavier Side';
      else wStatus = 'Needs Doctor\'s Advice (High Weight)';
    }

    String hStatus = '';
    if (calcHeightCm != null) {
      if (calcHeightCm < p3H) hStatus = 'Needs Doctor\'s Advice (Very Short)';
      else if (calcHeightCm < iHM) hStatus = 'On the Shorter Side';
      else if (calcHeightCm <= iHMx) hStatus = 'Perfectly Healthy Height 🌟';
      else if (calcHeightCm <= p97H) hStatus = 'Taller than Average';
      else hStatus = 'Very Tall for their Age';
    }

    return AssessmentData(
      inputWeight: rawWeight,
      inputHeight: rawHeight,
      weightStatus: wStatus,
      heightStatus: hStatus,
      idealWeightMin: iWM,
      idealWeightMax: iWMx,
      idealWeightTarget: iWT,
      p3Weight: p3W,
      p97Weight: p97W,
      idealHeightMin: iHM,
      idealHeightMax: iHMx,
      idealHeightTarget: iHT,
      p3Height: p3H,
      p97Height: p97H,
    );
  }

  static int estimatePercentile(double value, double p3, double p15, double p50, double p85, double p97) {
    if (value <= p3) return 3;
    if (value <= p15) return 3 + ((value - p3) / (p15 - p3) * 12).round();
    if (value <= p50) return 15 + ((value - p15) / (p50 - p15) * 35).round();
    if (value <= p85) return 50 + ((value - p50) / (p85 - p50) * 35).round();
    if (value <= p97) return 85 + ((value - p85) / (p97 - p85) * 12).round();
    return 99;
  }

  // Unified string generator
  static String generateBragMessage({
    required AssessmentData data,
    required String childName,
    required String gender,
    required String system,
    required bool isForSocialShare,
  }) {
    String genderDisplay = gender == 'boys' ? 'boys' : 'girls';
    List<String> displayLines = [];
    List<String> shareLines = [];

    shareLines.add("*🌟 Baby Growth Milestone! 🌟*\n");
    shareLines.add("*$childName* is growing wonderfully! 👶✨\n");

    bool bragged = false;

    if (data.inputHeight != null) {
      double heightCm = system == 'imperial' ? (data.inputHeight! * 2.54) : data.inputHeight!;
      int hPercentile = estimatePercentile(heightCm, data.p3Height, data.idealHeightMin, data.idealHeightTarget, data.idealHeightMax, data.p97Height);

      if (data.heightStatus.contains('Healthy') || data.heightStatus.contains('Taller than Average')) {
        bragged = true;
        displayLines.add("📏 $childName is taller than $hPercentile% of Indian $genderDisplay!");
        shareLines.add("📏 *Height:* *$childName* is taller than *$hPercentile%* of Indian $genderDisplay! 🦒");
      }
    }

    if (data.inputWeight != null) {
      double weightKg = system == 'imperial' ? (data.inputWeight! / 2.20462) : data.inputWeight!;
      int wPercentile = estimatePercentile(weightKg, data.p3Weight, data.idealWeightMin, data.idealWeightTarget, data.idealWeightMax, data.p97Weight);

      if (data.weightStatus.contains('Healthy')) {
        bragged = true;
        displayLines.add("⚖️ $childName is healthier & stronger than $wPercentile% of Indian $genderDisplay!");
        shareLines.add("⚖️ *Weight:* *$childName* is healthier & stronger than *$wPercentile%* of Indian $genderDisplay! 💪");
      }
    }

    if (!bragged) {
      displayLines.add("📈 Tracking $childName's growth milestones!");
      shareLines.add("📈 Tracking *$childName's* growth milestones with care! 🍼");
    }

    if (isForSocialShare) {
      shareLines.add("\nCheck your baby's growth with the *Indian Baby Growth Calculator* app! 👇");
      shareLines.add("🔗 https://play.google.com/store/apps/details?id=com.healthcare.indian_baby_height_weight_calculator.indian_baby_height_weight_calculator");
      return shareLines.join('\n');
    }

    return displayLines.join('\n\n');
  }
}