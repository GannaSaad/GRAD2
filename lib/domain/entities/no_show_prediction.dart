class NoShowPrediction {
  final String patientId;
  final double probability;
  final int appointments;
  final int cancellations;
  final int pending;

  NoShowPrediction({
    required this.patientId,
    required this.probability,
    this.appointments = 0,
    this.cancellations = 0,
    this.pending = 0,
  });

  // This adds the logic to show text instead of just numbers
  String get riskLevel {
    if (probability > 70) return "High Risk";
    if (probability > 30) return "Moderate Risk";
    return "Low Risk";
  }
}