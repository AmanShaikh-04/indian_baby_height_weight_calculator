class AssessmentData {
  final double? inputWeight;
  final double? inputHeight;
  final String weightStatus;
  final String heightStatus;

  final double idealWeightMin;
  final double idealWeightMax;
  final double idealWeightTarget;
  final double p3Weight;
  final double p97Weight;

  final double idealHeightMin;
  final double idealHeightMax;
  final double idealHeightTarget;
  final double p3Height;
  final double p97Height;

  AssessmentData({
    this.inputWeight,
    this.inputHeight,
    required this.weightStatus,
    required this.heightStatus,
    required this.idealWeightMin,
    required this.idealWeightMax,
    required this.idealWeightTarget,
    required this.p3Weight,
    required this.p97Weight,
    required this.idealHeightMin,
    required this.idealHeightMax,
    required this.idealHeightTarget,
    required this.p3Height,
    required this.p97Height,
  });
}