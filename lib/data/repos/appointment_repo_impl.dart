import 'package:injectable/injectable.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/entities/availability_entity.dart';
import '../../domain/repos/appointment_repo.dart';
import '../data_sources/remote/appointment_remote_data_source.dart';
import '../models/appointment_model.dart';

@Injectable(as: AppointmentRepo)
class AppointmentRepoImpl implements AppointmentRepo {
  final AppointmentRemoteDataSource _remoteDataSource;

  AppointmentRepoImpl(this._remoteDataSource);

  @override
  Future<void> bookAppointment(AppointmentEntity appointment) {
    return _remoteDataSource.bookAppointment(AppointmentModel.fromEntity(appointment));
  }

  @override
  Stream<List<AppointmentEntity>> getPatientAppointments(String patientId) {
    return _remoteDataSource.getPatientAppointments(patientId).map(
          (list) => list.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Stream<List<AppointmentEntity>> getDoctorAppointments(String doctorId) {
    return _remoteDataSource.getDoctorAppointments(doctorId).map(
          (list) => list.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Stream<List<AppointmentEntity>> getTodayAppointments() {
    return _remoteDataSource.getTodayAppointments().map(
          (list) => list.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> cancelAppointment(String appointmentId) {
    return _remoteDataSource.cancelAppointment(appointmentId);
  }

  @override
  Future<void> completeAppointment(String appointmentId) {
    return _remoteDataSource.completeAppointment(appointmentId);
  }

  @override
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newDate, String newTime) {
    return _remoteDataSource.rescheduleAppointment(
        appointmentId, newDate, newTime);
  }

  @override
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) {
    return _remoteDataSource.getBookedSlots(doctorId, date);
  }

  @override
  Future<void> updateAvailability(AvailabilityEntity availability) {
    return _remoteDataSource.updateAvailability(availability);
  }

  @override
  Stream<AvailabilityEntity?> getDoctorAvailability(String doctorId, DateTime date) {
    return _remoteDataSource.getDoctorAvailability(doctorId, date);
  }
}
