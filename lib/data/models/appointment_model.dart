import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/appointment_entity.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final String time;
  final String status;
  final String caseDescription;
  final String clinicName;
  final String? patientImage;
  final String? doctorImage;
  final bool isReceptionistBooking;

  AppointmentModel({
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
  });

  factory AppointmentModel.fromFirestore(Map<String, dynamic> json, String id) {
    return AppointmentModel(
      id: id,
      doctorId: json['doctorId'] ?? '',
      patientId: json['patientId'] ?? '',
      doctorName: json['doctorName'] ?? '',
      patientName: json['patientName'] ?? '',
      date: (json['date'] as Timestamp).toDate(),
      time: json['time'] ?? '',
      status: json['status'] ?? 'Pending',
      caseDescription: json['caseDescription'] ?? '',
      clinicName: json['clinicName'] ?? '',
      patientImage: json['patientImage'],
      doctorImage: json['doctorImage'],
      isReceptionistBooking: json['isReceptionistBooking'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'date': Timestamp.fromDate(date),
      'time': time,
      'status': status,
      'caseDescription': caseDescription,
      'clinicName': clinicName,
      'patientImage': patientImage,
      'doctorImage': doctorImage,
      'isReceptionistBooking': isReceptionistBooking,
    };
  }

  AppointmentEntity toEntity() {
    return AppointmentEntity(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      date: date,
      time: time,
      status: status,
      caseDescription: caseDescription,
      clinicName: clinicName,
      patientImage: patientImage,
      doctorImage: doctorImage,
      isReceptionistBooking: isReceptionistBooking,
    );
  }

  factory AppointmentModel.fromEntity(AppointmentEntity entity) {
    return AppointmentModel(
      id: entity.id,
      doctorId: entity.doctorId,
      patientId: entity.patientId,
      doctorName: entity.doctorName,
      patientName: entity.patientName,
      date: entity.date,
      time: entity.time,
      status: entity.status,
      caseDescription: entity.caseDescription,
      clinicName: entity.clinicName,
      patientImage: entity.patientImage,
      doctorImage: entity.doctorImage,
      isReceptionistBooking: entity.isReceptionistBooking,
    );
  }
}
