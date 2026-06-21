import '../entities/review_entity.dart';

abstract class ReviewRepo {
  /// Add a new review for a doctor
  Future<void> addReview({
    required String doctorId,
    required String patientId,
    required String patientName,
    String? patientImage,
    required int rating,
    required String comment,
  });

  /// Get all reviews for a specific doctor
  Stream<List<ReviewEntity>> getDoctorReviews(String doctorId);

  /// Get average rating for a doctor
  Future<double> getDoctorAverageRating(String doctorId);

  /// Check if patient has completed appointment with doctor
  Future<bool> hasCompletedAppointment(String patientId, String doctorId);

  /// Delete a review (admin only)
  Future<void> deleteReview(String reviewId);

  /// Check if patient already reviewed this doctor
  Future<bool> hasReviewedDoctor(String patientId, String doctorId);
}
