import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/support_ticket_entity.dart';
import '../../../../domain/use_cases/send_support_ticket_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class SupportState {}
class SupportInitial extends SupportState {}
class SupportLoading extends SupportState {}
class SupportSuccess extends SupportState {}
class SupportFailure extends SupportState {
  final String message;
  SupportFailure(this.message);
}

@injectable
class SupportViewModel extends Cubit<SupportState> {
  final SendSupportTicketUseCase _sendSupportTicketUseCase;

  SupportViewModel(this._sendSupportTicketUseCase) : super(SupportInitial());

  Future<void> sendTicket(String message) async {
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(SupportFailure("User not authenticated"));
      return;
    }

    emit(SupportLoading());
    try {
      final ticket = SupportTicketEntity(
        id: '', // Firestore will generate
        senderId: user.uid,
        senderName: user.fullName ?? 'Unknown',
        senderRole: user.role ?? 'patient',
        message: message,
        status: 'Pending',
        createdAt: DateTime.now(),
      );
      
      await _sendSupportTicketUseCase.call(ticket);
      emit(SupportSuccess());
    } catch (e) {
      emit(SupportFailure(e.toString()));
    }
  }
}
