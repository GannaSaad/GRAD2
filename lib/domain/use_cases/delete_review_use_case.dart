import 'package:injectable/injectable.dart';
import '../repos/review_repo.dart';

@injectable
class DeleteReviewUseCase {
  final ReviewRepo _repository;

  DeleteReviewUseCase(this._repository);

  Future<void> call(String reviewId) {
    return _repository.deleteReview(reviewId);
  }
}
