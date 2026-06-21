import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/review_entity.dart';
import '../../domain/repos/review_repo.dart';
import '../models/review_model.dart';

@Injectable(as: ReviewRepo)
class ReviewRepoImpl implements ReviewRepo {
  final FirebaseFirestore _firestore;

  ReviewRepoImpl(this._firestore);

  @override
  Future<void> addReview({
    required String doctorId,
    required String patientId,
    required String patientName,
    String? patientImage,
    required int rating,
    required String comment,
  }) async {
    final review = ReviewModel(
      id: '', // Will be set by Firestore
      doctorId: doctorId,
      patientId: patientId,
      patientName: patientName,
      patientImage: patientImage,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('reviews').add(review.toFirestore());
  }

  @override
  Stream<List<ReviewEntity>> getDoctorReviews(String doctorId) {
    return _firestore
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }

  @override
  Future<double> getDoctorAverageRating(String doctorId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('doctorId', isEqualTo: doctorId)
        .get();

    if (snapshot.docs.isEmpty) return 0.0;

    final ratings = snapshot.docs.map((doc) => (doc.data()['rating'] ?? 0) as int).toList();
    final sum = ratings.fold<int>(0, (prev, rating) => prev + rating);
    return sum / ratings.length;
  }

  @override
  Future<bool> hasCompletedAppointment(String patientId, String doctorId) async {
    final snapshot = await _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'Completed')
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    await _firestore.collection('reviews').doc(reviewId).delete();
  }

  @override
  Future<bool> hasReviewedDoctor(String patientId, String doctorId) async {
    final snapshot = await _firestore
        .collection('reviews')
        .where('patientId', isEqualTo: patientId)
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
