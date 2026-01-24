import 'package:equatable/equatable.dart';

class AvailabilityEntity extends Equatable {
  final String doctorId;
  final DateTime date;
  final List<String> availableSlots;

  const AvailabilityEntity({
    required this.doctorId,
    required this.date,
    required this.availableSlots,
  });

  @override
  List<Object?> get props => [doctorId, date, availableSlots];
}
