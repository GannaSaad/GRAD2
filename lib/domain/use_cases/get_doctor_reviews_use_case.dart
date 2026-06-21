import 'package:injectable/injectable.dart';
import '../entities/review_entity.dart';
import '../repos/review_repo.dart';

@injectable
class GetDoctorReviewsUseCase {
  final ReviewRepo _repository;

  GetDoctorReviewsUseCase(this._repository);

  Stream<List<ReviewEntity>> call(String doctorId) {
    return _repository.getDoctorReviews(doctorId);
  }
}
