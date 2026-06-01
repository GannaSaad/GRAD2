import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/availability_entity.dart';
import '../../../../domain/use_cases/update_availability_use_case.dart';
import '../../../../domain/repos/appointment_repo.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class AvailabilityState {}
class AvailabilityInitial extends AvailabilityState {}
class AvailabilityLoading extends AvailabilityState {}
class AvailabilitySaving extends AvailabilityState {}
class AvailabilitySuccess extends AvailabilityState {
  final List<String> publishedSlots;
  final List<String> selectedSlots;
  final List<String> bookedSlots;
  final DateTime date;
  AvailabilitySuccess(this.publishedSlots, this.selectedSlots, this.bookedSlots, this.date);
}
class AvailabilityFailure extends AvailabilityState {
  final String message;
  AvailabilityFailure(this.message);
}

@injectable
class AvailabilityViewModel extends Cubit<AvailabilityState> {
  final AppointmentRepo _appointmentRepo;
  final UpdateAvailabilityUseCase _updateAvailabilityUseCase;
  StreamSubscription? _availabilitySub;
  
  List<String> _publishedSlots = [];
  List<String> _newSelectedSlots = [];
  List<String> _bookedSlots = [];
  DateTime? _currentDate;

  AvailabilityViewModel(
    this._appointmentRepo,
    this._updateAvailabilityUseCase,
  ) : super(AvailabilityInitial());

  void getAvailability(DateTime date) async {
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(AvailabilityFailure("User not authenticated"));
      return;
    }

    final String targetDoctorId = (user.role?.toLowerCase() == 'doctor') 
        ? user.uid 
        : (user.assignedDoctorId ?? "");

    if (targetDoctorId.isEmpty) {
      emit(AvailabilityFailure("No doctor assigned to this account"));
      return;
    }

    final normalizedDate = DateTime(date.year, date.month, date.day);
    _currentDate = normalizedDate;
    _newSelectedSlots = [];
    emit(AvailabilityLoading());

    try {
      _bookedSlots = await _appointmentRepo.getBookedSlots(targetDoctorId, normalizedDate);
      
      _availabilitySub?.cancel();
      // Use .first or handle stream updates carefully so local removals aren't overwritten immediately
      final availability = await _appointmentRepo.getDoctorAvailability(targetDoctorId, normalizedDate).first;
      
      if (!isClosed && _currentDate == normalizedDate) {
        _publishedSlots = availability?.availableSlots ?? [];
        _emitCurrentState();
      }
    } catch (e) {
      if (!isClosed) emit(AvailabilityFailure(e.toString()));
    }
  }

  void _emitCurrentState() {
    if (_currentDate != null) {
      emit(AvailabilitySuccess(
        List.from(_publishedSlots), 
        List.from(_newSelectedSlots), 
        List.from(_bookedSlots), 
        _currentDate!
      ));
    }
  }

  void toggleSlot(String time) {
    if (_bookedSlots.contains(time)) return; // Cannot remove if a patient already booked it

    if (_publishedSlots.contains(time)) {
      // Remove from existing published slots
      _publishedSlots.remove(time);
    } else if (_newSelectedSlots.contains(time)) {
      // Toggle off a newly selected slot
      _newSelectedSlots.remove(time);
    } else {
      // Add a new slot
      _newSelectedSlots.add(time);
    }
    _emitCurrentState();
  }

  Future<void> saveAvailability() async {
    if (_currentDate == null) return;
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) return;

    final String targetDoctorId = (user.role?.toLowerCase() == 'doctor') 
        ? user.uid 
        : (user.assignedDoctorId ?? "");

    final prevState = state;
    emit(AvailabilitySaving());

    try {
      final totalAvailability = {..._publishedSlots, ..._newSelectedSlots}.toList();
      
      final availability = AvailabilityEntity(
        doctorId: targetDoctorId,
        date: _currentDate!,
        availableSlots: totalAvailability,
      );
      
      await _updateAvailabilityUseCase.call(availability);
      _newSelectedSlots = [];
      // Refresh to confirm final state from DB
      getAvailability(_currentDate!);
    } catch (e) {
      emit(AvailabilityFailure(e.toString()));
      emit(prevState);
    }
  }

  @override
  Future<void> close() {
    _availabilitySub?.cancel();
    return super.close();
  }
}
