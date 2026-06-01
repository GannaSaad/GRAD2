import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
import '../../../data/data_sources/remote/appointment_remote_data_source.dart';
import '../../../data/models/appointment_model.dart';
import '../../../domain/entities/availability_entity.dart';

@Injectable(as: AppointmentRemoteDataSource)
class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final FirebaseFirestore _firestore;

  AppointmentRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> bookAppointment(AppointmentModel appointment) async {
    try {
      await _firestore
          .collection('appointments')
          .doc(appointment.id)
          .set(appointment.toFirestore());
    } catch (e) {
      throw Exception('Failed to book appointment: ${e.toString()}');
    }
  }

  @override
  Stream<List<AppointmentModel>> getPatientAppointments(String patientId) {
    return _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<AppointmentModel>> getDoctorAppointments(String doctorId) {
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Stream<List<AppointmentModel>> getTodayAppointments() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return _firestore
        .collection('appointments')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Completed',
      });
    } catch (e) {
      throw Exception('Failed to complete appointment: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': 'Cancelled',
      });
    } catch (e) {
      throw Exception('Failed to cancel appointment: ${e.toString()}');
    }
  }

  @override
  Future<void> rescheduleAppointment(
      String appointmentId, DateTime newDate, String newTime) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'date': Timestamp.fromDate(newDate),
        'time': newTime,
        'status': 'Rescheduled',
      });
    } catch (e) {
      throw Exception('Failed to reschedule appointment: ${e.toString()}');
    }
  }

  @override
  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update appointment status: ${e.toString()}');
    }
  }

  @override
  Future<void> resolveEmergency(String appointmentId, String status, bool isEmergency) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'isEmergency': isEmergency,
      });
    } catch (e) {
      throw Exception('Failed to resolve emergency: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getBookedSlots(String doctorId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .where('status', isNotEqualTo: 'Cancelled')
          .get();

      return snapshot.docs.map((doc) => doc.data()['time'] as String).toList();
    } catch (e) {
      throw Exception('Failed to fetch booked slots: ${e.toString()}');
    }
  }

  @override
  Future<void> updateAvailability(AvailabilityEntity availability) async {
    final dateKey = DateFormat('yyyy-MM-dd').format(availability.date);
    try {
      await _firestore
          .collection('availability')
          .doc('${availability.doctorId}_$dateKey')
          .set({
        'doctorId': availability.doctorId,
        'date': Timestamp.fromDate(availability.date),
        'availableSlots': availability.availableSlots,
      });
    } catch (e) {
      throw Exception('Failed to update availability: ${e.toString()}');
    }
  }

  @override
  Stream<AvailabilityEntity?> getDoctorAvailability(String doctorId, DateTime date) {
    final dateKey = DateFormat('yyyy-MM-dd').format(date);
    return _firestore
        .collection('availability')
        .doc('${doctorId}_$dateKey')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final data = doc.data()!;
      return AvailabilityEntity(
        doctorId: data['doctorId'],
        date: (data['date'] as Timestamp).toDate(),
        availableSlots: List<String>.from(data['availableSlots']),
      );
    });
  }
}
