import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '../../../data/repos/review_repo_impl.dart';
import '../../../domain/repos/review_repo.dart';
import '../../../domain/use_cases/add_review_use_case.dart';
import '../../../domain/use_cases/delete_review_use_case.dart';
import '../../../domain/use_cases/get_doctor_reviews_use_case.dart';

/// Manual DI registration for Review system
/// Call this in configureDependencies() after getIt.init()
void registerReviewDependencies(GetIt getIt) {
  // Repository - use FirebaseFirestore.instance directly
  getIt.registerLazySingleton<ReviewRepo>(
    () => ReviewRepoImpl(FirebaseFirestore.instance),
  );

  // Use Cases
  getIt.registerLazySingleton(() => AddReviewUseCase(getIt<ReviewRepo>()));
  getIt.registerLazySingleton(() => GetDoctorReviewsUseCase(getIt<ReviewRepo>()));
  getIt.registerLazySingleton(() => DeleteReviewUseCase(getIt<ReviewRepo>()));
}
