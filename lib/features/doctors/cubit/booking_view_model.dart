import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../api/config/di/di.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/book_appointment_use_case.dart';
import '../../../../domain/use_cases/get_booked_slots_use_case.dart';
import '../../auth/auth_cubit/auth_cubit.dart';
import '../doctors_listing_screen.dart';

abstract class BookingState {}
class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}
class BookingSuccess extends BookingState {}
class BookingFailure extends BookingState {
  final String message;
  BookingFailure(this.message);
}
class BookedSlotsLoaded extends BookingState {
  final List<String> bookedSlots;
  BookedSlotsLoaded(this.bookedSlots);
}

@injectable
class BookingViewModel extends Cubit<BookingState> {
  final BookAppointmentUseCase _bookAppointmentUseCase;
  final GetBookedSlotsUseCase _getBookedSlotsUseCase;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingViewModel(this._bookAppointmentUseCase, this._getBookedSlotsUseCase) : super(BookingInitial());

  Future<void> fetchBookedSlots(String doctorId, DateTime date) async {
    emit(BookingLoading());
    try {
      final slots = await _getBookedSlotsUseCase.call(doctorId, date);
      emit(BookedSlotsLoaded(slots));
    } catch (e) {
      emit(BookingFailure(e.toString()));
    }
  }

  Future<void> book({
    required Doctor doctor,
    required DateTime date,
    required String time,
    String? patientId,
    String? patientName,
    String? patientPhone,
    String? caseDescription,
    bool isReceptionistBooking = false,
    bool isEmergency = false,
    String? emergencyReason,
    String? emergencyDescription,
  }) async {
    emit(BookingLoading());
    try {
      final user = getIt<AuthCubit>().currentUser;
      if (user == null) throw Exception("User not authenticated");

      String finalPatientId = patientId ?? user.uid;

      if (isReceptionistBooking && patientId == null && patientPhone != null) {
        finalPatientId = 'walkin_$patientPhone';
        try {
          await _firestore.collection('users').doc(finalPatientId).set({
            'uid': finalPatientId,
            'fullName': patientName,
            'phoneNumber': patientPhone,
            'role': 'patient',
            'assignedDoctorId': doctor.id, 
            'assignedDoctorName': doctor.name,
            'clinicName': doctor.clinic, // SYNC: Walk-in patient gets clinic info
            'createdAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        } catch (e) {
          print("Firestore Warning: Could not create walk-in user doc (Permission Denied).");
        }
      }

      final appointment = AppointmentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorId: doctor.id,
        patientId: finalPatientId,
        doctorName: doctor.name,
        patientName: patientName ?? user.fullName ?? 'Patient',
        date: date,
        time: time,
        status: isReceptionistBooking ? 'Confirmed' : (isEmergency ? 'Emergency Request Pending' : 'Confirmed'),
        caseDescription: isEmergency ? (emergencyReason ?? 'Emergency') : (caseDescription ?? 'Initial Consultation'),
        clinicName: doctor.clinic, // SYNC: Use the real clinic name from the Doctor object
        doctorImage: doctor.image,
        isReceptionistBooking: isReceptionistBooking,
        isEmergency: isEmergency,
        emergencyReason: emergencyReason,
        emergencyDescription: emergencyDescription,
      );

      await _bookAppointmentUseCase.call(appointment);
      emit(BookingSuccess());
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('permission-denied')) {
        errorMessage = "Permission Denied: The system could not save the appointment.";
      }
      emit(BookingFailure(errorMessage));
    }
  }
}
