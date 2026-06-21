import 'package:injectable/injectable.dart';
import '../repos/review_repo.dart';

@injectable
class AddReviewUseCase {
  final ReviewRepo _repository;

  AddReviewUseCase(this._repository);

  Future<void> execute({
    required String doctorId,
    required String patientId,
    required String patientName,
    String? patientImage,
    required int rating,
    required String comment,
  }) {
    return _repository.addReview(
      doctorId: doctorId,
      patientId: patientId,
      patientName: patientName,
      patientImage: patientImage,
      rating: rating,
      comment: comment,
    );
  }
}
