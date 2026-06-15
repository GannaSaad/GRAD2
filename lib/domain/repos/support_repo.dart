import '../entities/support_ticket_entity.dart';

abstract class SupportRepo {
  Future<void> sendSupportTicket(SupportTicketEntity ticket);
  Stream<List<SupportTicketEntity>> getSupportTickets(String? role); // role can be 'doctor' or 'patient'
  Future<void> replyToTicket(String ticketId, String reply);
  Future<void> markAsResolved(String ticketId);
}
