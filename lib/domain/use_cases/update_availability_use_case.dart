import 'package:injectable/injectable.dart';
import '../entities/availability_entity.dart';
import '../repos/appointment_repo.dart';

@injectable
class UpdateAvailabilityUseCase {
  final AppointmentRepo _repository;

  UpdateAvailabilityUseCase(this._repository);

  Future<void> call(AvailabilityEntity availability) {
    // We'll add this to AppointmentRepo to reuse the slot logic
    return _repository.updateAvailability(availability);
  }
}
