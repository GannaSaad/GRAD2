import 'package:equatable/equatable.dart';

class SupportTicketEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final String status; // 'Pending', 'Resolved'
  final DateTime createdAt;
  final String? reply;

  const SupportTicketEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.status,
    required this.createdAt,
    this.reply,
  });

  SupportTicketEntity copyWith({
    String? status,
    String? reply,
  }) {
    return SupportTicketEntity(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderRole: senderRole,
      message: message,
      status: status ?? this.status,
      createdAt: createdAt,
      reply: reply ?? this.reply,
    );
  }

  @override
  List<Object?> get props => [id, senderId, senderName, senderRole, message, status, createdAt, reply];
}
