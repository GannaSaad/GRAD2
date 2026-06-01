import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/get_today_appointments_use_case.dart';

abstract class ReceptionistHomeState {}
class ReceptionistHomeInitial extends ReceptionistHomeState {}
class ReceptionistHomeLoading extends ReceptionistHomeState {}
class ReceptionistHomeSuccess extends ReceptionistHomeState {
  final List<AppointmentEntity> appointments;
  ReceptionistHomeSuccess(this.appointments);
}
class ReceptionistHomeFailure extends ReceptionistHomeState {
  final String message;
  ReceptionistHomeFailure(this.message);
}

@injectable
class ReceptionistHomeViewModel extends Cubit<ReceptionistHomeState> {
  final GetTodayAppointmentsUseCase _getTodayAppointmentsUseCase;

  ReceptionistHomeViewModel(this._getTodayAppointmentsUseCase) : super(ReceptionistHomeInitial());

  void getTodaySchedule() {
    emit(ReceptionistHomeLoading());
    _getTodayAppointmentsUseCase.call().listen(
      (appointments) {
        emit(ReceptionistHomeSuccess(appointments));
      },
      onError: (error) {
        emit(ReceptionistHomeFailure(error.toString()));
      },
    );
  }
}
