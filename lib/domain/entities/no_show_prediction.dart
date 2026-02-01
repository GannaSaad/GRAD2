class NoShowPrediction {
  final double probability; // The percentage returned by the API
  final String patientId;

  NoShowPrediction({required this.probability, required this.patientId});

  // Logic to determine risk level
  String get riskLevel {
    if (probability > 70) return "High Risk";
    if (probability > 30) return "Moderate Risk";
    return "Low Risk";
  }
}