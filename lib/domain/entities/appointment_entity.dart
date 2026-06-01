import 'package:equatable/equatable.dart';

class AppointmentEntity extends Equatable {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final String time;
  final String status; // 'Pending', 'Confirmed', 'Cancelled', 'Completed', 'Emergency Request Pending'
  final String caseDescription;
  final String clinicName;
  final String? patientImage;
  final String? doctorImage;
  final bool isReceptionistBooking;
  final bool isEmergency;
  final String? emergencyReason;
  final String? emergencyDescription;

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
    this.isReceptionistBooking = false,
    this.isEmergency = false,
    this.emergencyReason,
    this.emergencyDescription,
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
        isReceptionistBooking,
        isEmergency,
        emergencyReason,
        emergencyDescription,
      ];

  AppointmentEntity copyWith({
    String? status,
  }) {
    return AppointmentEntity(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      date: date,
      time: time,
      status: status ?? this.status,
      caseDescription: caseDescription,
      clinicName: clinicName,
      patientImage: patientImage,
      doctorImage: doctorImage,
      isReceptionistBooking: isReceptionistBooking,
      isEmergency: isEmergency,
      emergencyReason: emergencyReason,
      emergencyDescription: emergencyDescription,
    );
  }
}
