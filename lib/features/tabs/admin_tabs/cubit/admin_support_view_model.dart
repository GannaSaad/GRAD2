import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/support_ticket_entity.dart';
import '../../../../domain/repos/support_repo.dart';

abstract class AdminSupportState {}
class AdminSupportInitial extends AdminSupportState {}
class AdminSupportLoading extends AdminSupportState {}
class AdminSupportSuccess extends AdminSupportState {
  final List<SupportTicketEntity> tickets;
  AdminSupportSuccess(this.tickets);
}
class AdminSupportFailure extends AdminSupportState {
  final String message;
  AdminSupportFailure(this.message);
}

@injectable
class AdminSupportViewModel extends Cubit<AdminSupportState> {
  final SupportRepo _supportRepo;
  StreamSubscription? _subscription;

  AdminSupportViewModel(this._supportRepo) : super(AdminSupportInitial());

  void fetchTickets(String role) {
    emit(AdminSupportLoading());
    _subscription?.cancel();
    _subscription = _supportRepo.getSupportTickets(role).listen(
      (tickets) => emit(AdminSupportSuccess(tickets)),
      onError: (e) => emit(AdminSupportFailure(e.toString())),
    );
  }

  Future<void> respondToTicket(String ticketId, String reply) async {
    try {
      await _supportRepo.replyToTicket(ticketId, reply);
    } catch (e) {
      emit(AdminSupportFailure(e.toString()));
    }
  }

  Future<void> markAsResolved(String ticketId) async {
    try {
      await _supportRepo.markAsResolved(ticketId);
    } catch (e) {
      emit(AdminSupportFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
