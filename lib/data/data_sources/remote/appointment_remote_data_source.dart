import '../../models/appointment_model.dart';
import '../../../domain/entities/availability_entity.dart';

abstract class AppointmentRemoteDataSource {
  Future<void> bookAppointment(AppointmentModel appointment);
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId);
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId);
  Stream<List<AppointmentModel>> getTodayAppointments();
  Future<void> cancelAppointment(String appointmentId);
  Future<void> completeAppointment(String appointmentId);
  Future<void> rescheduleAppointment(String appointmentId, DateTime newDate, String newTime);
  Future<List<String>> getBookedSlots(String doctorId, DateTime date);
  
  // Added for doctor availability management
  Future<void> updateAvailability(AvailabilityEntity availability);
  Stream<AvailabilityEntity?> getDoctorAvailability(String doctorId, DateTime date);
}
