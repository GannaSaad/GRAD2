import 'package:injectable/injectable.dart';
import '../entities/support_ticket_entity.dart';
import '../repos/support_repo.dart';

@injectable
class SendSupportTicketUseCase {
  final SupportRepo _repository;

  SendSupportTicketUseCase(this._repository);

  Future<void> call(SupportTicketEntity ticket) {
    return _repository.sendSupportTicket(ticket);
  }
}
