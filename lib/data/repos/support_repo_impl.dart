import 'package:injectable/injectable.dart';
import 'package:dentex_clean/data/data_sources/remote/support_remote_data_source.dart';
import 'package:dentex_clean/data/models/support_ticket_model.dart';
import 'package:dentex_clean/domain/entities/support_ticket_entity.dart';
import 'package:dentex_clean/domain/repos/support_repo.dart';

@Injectable(as: SupportRepo)
class SupportRepositoryImpl implements SupportRepo {
  final SupportRemoteDataSource _remoteDataSource;

  SupportRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> sendSupportTicket(SupportTicketEntity ticket) {
    return _remoteDataSource.sendTicket(SupportTicketModel(
      id: ticket.id,
      senderId: ticket.senderId,
      senderName: ticket.senderName,
      senderRole: ticket.senderRole,
      message: ticket.message,
      status: ticket.status,
      createdAt: ticket.createdAt,
      reply: ticket.reply,
    ));
  }

  @override
  Stream<List<SupportTicketEntity>> getSupportTickets(String? role) {
    return _remoteDataSource.getTickets(role).map((models) {
      return models.map((m) => SupportTicketEntity(
        id: m.id,
        senderId: m.senderId,
        senderName: m.senderName,
        senderRole: m.senderRole,
        message: m.message,
        status: m.status,
        createdAt: m.createdAt,
        reply: m.reply,
      )).toList();
    });
  }

  @override
  Future<void> replyToTicket(String ticketId, String reply) {
    return _remoteDataSource.replyToTicket(ticketId, reply);
  }

  @override
  Future<void> markAsResolved(String ticketId) {
    return _remoteDataSource.markAsResolved(ticketId);
  }
}
