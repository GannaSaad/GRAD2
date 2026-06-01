import 'package:injectable/injectable.dart';
import '../repos/appointment_repo.dart';

@injectable
class CompleteAppointmentUseCase {
  final AppointmentRepo _appointmentRepo;

  CompleteAppointmentUseCase(this._appointmentRepo);

  Future<void> call(String id) {
    return _appointmentRepo.completeAppointment(id);
  }
}
