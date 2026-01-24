import 'package:dentex_clean/data/models/support_ticket_model.dart';

abstract class SupportRemoteDataSource {
  Future<void> sendTicket(SupportTicketModel ticket);
  Stream<List<SupportTicketModel>> getTickets(String? role);
  Future<void> replyToTicket(String ticketId, String reply);
  Future<void> markAsResolved(String ticketId);
}
