import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final String? patientImage;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;

  const ReviewEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    this.patientImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientId,
        patientName,
        patientImage,
        rating,
        comment,
        createdAt,
      ];
}
