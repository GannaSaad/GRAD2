import 'package:injectable/injectable.dart';
import '../repos/appointment_repo.dart';

@injectable
class GetBookedSlotsUseCase {
  final AppointmentRepo _appointmentRepo;

  GetBookedSlotsUseCase(this._appointmentRepo);

  Future<List<String>> call(String doctorId, DateTime date) {
    return _appointmentRepo.getBookedSlots(doctorId, date);
  }
}
