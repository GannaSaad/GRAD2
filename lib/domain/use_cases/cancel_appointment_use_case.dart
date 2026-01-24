import 'package:injectable/injectable.dart';
import '../repos/appointment_repo.dart';

@injectable
class CancelAppointmentUseCase {
  final AppointmentRepo _appointmentRepo;

  CancelAppointmentUseCase(this._appointmentRepo);

  Future<void> call(String appointmentId) {
    return _appointmentRepo.cancelAppointment(appointmentId);
  }
}
