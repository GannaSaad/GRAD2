import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.doctorId,
    required super.patientId,
    required super.patientName,
    super.patientImage,
    required super.rating,
    required super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientImage: data['patientImage'],
      rating: data['rating'] ?? 0,
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'patientImage': patientImage,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
