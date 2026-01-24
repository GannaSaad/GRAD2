import 'package:injectable/injectable.dart';
import '../entities/appointment_entity.dart';
import '../repos/appointment_repo.dart';

@injectable
class GetTodayAppointmentsUseCase {
  final AppointmentRepo _appointmentRepo;

  GetTodayAppointmentsUseCase(this._appointmentRepo);

  Stream<List<AppointmentEntity>> call() {
    return _appointmentRepo.getTodayAppointments();
  }
}
