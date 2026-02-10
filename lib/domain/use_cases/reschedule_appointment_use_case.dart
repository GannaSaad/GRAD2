import 'package:injectable/injectable.dart';
import '../repos/appointment_repo.dart';

@injectable
class RescheduleAppointmentUseCase {
  final AppointmentRepo _appointmentRepo;

  RescheduleAppointmentUseCase(this._appointmentRepo);

  Future<void> call(String appointmentId, DateTime newDate, String newTime) {
    return _appointmentRepo.rescheduleAppointment(appointmentId, newDate, newTime);
  }
}
