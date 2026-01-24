import 'package:injectable/injectable.dart';
import '../entities/appointment_entity.dart';
import '../repos/appointment_repo.dart';

@injectable
class BookAppointmentUseCase {
  final AppointmentRepo _appointmentRepo;

  BookAppointmentUseCase(this._appointmentRepo);

  Future<void> call(AppointmentEntity appointment) {
    return _appointmentRepo.bookAppointment(appointment);
  }
}
