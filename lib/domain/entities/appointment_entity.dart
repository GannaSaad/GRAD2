import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final String time;
  final String status; // 'Pending', 'Confirmed', 'Cancelled', 'Completed'
  final String caseDescription;
  final String clinicName;
  final String? patientImage;
  final String? doctorImage;

  const AppointmentEntity({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.time,
    required this.status,
    required this.caseDescription,
    required this.clinicName,
    this.patientImage,
    this.doctorImage,
  });

  @override
  List<Object?> get props => [
        id,
        doctorId,
        patientId,
        doctorName,
        patientName,
        date,
        time,
        status,
        caseDescription,
        clinicName,
      ];
}
