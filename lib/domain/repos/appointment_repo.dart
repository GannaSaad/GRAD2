import '../entities/appointment_entity.dart';
import '../entities/availability_entity.dart';

abstract class AppointmentRepo {
  Future<void> bookAppointment(AppointmentEntity appointment);
  Stream<List<AppointmentEntity>> getPatientAppointments(String patientId);
  Stream<List<AppointmentEntity>> getDoctorAppointments(String doctorId);
  Stream<List<AppointmentEntity>> getTodayAppointments();
  Future<void> cancelAppointment(String appointmentId);
  Future<void> completeAppointment(String appointmentId);
  Future<void> rescheduleAppointment(String appointmentId, DateTime newDate, String newTime);
  Future<List<String>> getBookedSlots(String doctorId, DateTime date);
  
  // Added for doctor availability management
  Future<void> updateAvailability(AvailabilityEntity availability);
  Stream<AvailabilityEntity?> getDoctorAvailability(String doctorId, DateTime date);
}
