import '../../models/appointment_model.dart';

abstract class AppointmentRemoteDataSource {
  Future<void> bookAppointment(AppointmentModel appointment);
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId);
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId);
  Stream<List<AppointmentModel>> getTodayAppointments();
  Future<void> cancelAppointment(String appointmentId);
  Future<void> rescheduleAppointment(String appointmentId, DateTime newDate, String newTime);
  Future<List<String>> getBookedSlots(String doctorId, DateTime date);
}
