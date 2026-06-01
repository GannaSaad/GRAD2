import 'package:injectable/injectable.dart';
import '../entities/appointment_entity.dart';
import '../repos/appointment_repo.dart';

@injectable
class GetDoctorAppointmentsUseCase {
  final AppointmentRepo _appointmentRepo;

  GetDoctorAppointmentsUseCase(this._appointmentRepo);

  Stream<List<AppointmentEntity>> call(String doctorId) {
    return _appointmentRepo.getDoctorAppointments(doctorId);
  }
}
