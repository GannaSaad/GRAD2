import 'package:injectable/injectable.dart';
import '../entities/appointment_entity.dart';
import '../repos/appointment_repo.dart';

@injectable
class GetPatientAppointmentsUseCase {
  final AppointmentRepo _appointmentRepo;

  GetPatientAppointmentsUseCase(this._appointmentRepo);

  Stream<List<AppointmentEntity>> call(String patientId) {
    return _appointmentRepo.getPatientAppointments(patientId);
  }
}
