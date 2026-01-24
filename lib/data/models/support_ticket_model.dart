import 'package:cloud_firestore/cloud_firestore.dart';

class SupportTicketModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final String status; // 'Pending', 'Resolved'
  final DateTime createdAt;
  final String? reply;

  SupportTicketModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.status,
    required this.createdAt,
    this.reply,
  });

  factory SupportTicketModel.fromFirestore(Map<String, dynamic> json, String id) {
    return SupportTicketModel(
      id: id,
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      senderRole: json['senderRole'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'Pending',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      reply: json['reply'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderRole': senderRole,
      'message': message,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'reply': reply,
    };
  }
}
