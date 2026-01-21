import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
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

  BookingViewModel(this._bookAppointmentUseCase, this._getBookedSlotsUseCase) : super(BookingInitial());

  List<String> currentBookedSlots = [];

  Future<void> fetchBookedSlots(String doctorId, DateTime date) async {
    emit(BookingLoading());
    try {
      final slots = await _getBookedSlotsUseCase.call(doctorId, date);
      currentBookedSlots = slots;
      emit(BookedSlotsLoaded(slots));
    } catch (e) {
      emit(BookingFailure(e.toString()));
    }
  }

  Future<void> book({
    required Doctor doctor,
    required DateTime date,
    required String time,
  }) async {
    emit(BookingLoading());
    try {
      final user = getIt<AuthCubit>().currentUser;
      if (user == null) throw Exception("User not authenticated");

      final appointment = AppointmentEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctorId: doctor.id,
        patientId: user.uid,
        doctorName: doctor.name,
        patientName: user.fullName ?? 'Patient',
        date: date,
        time: time,
        status: 'Pending',
        caseDescription: 'Initial Consultation',
        clinicName: 'Dentix Clinic',
        patientImage: 'assets/images/patient.jpeg',
        doctorImage: doctor.image,
      );

      await _bookAppointmentUseCase.call(appointment);
      emit(BookingSuccess());
    } catch (e) {
      emit(BookingFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
