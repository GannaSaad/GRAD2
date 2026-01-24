import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../api/config/di/di.dart';
import '../../../../domain/entities/request_entity.dart';
import '../../../../domain/use_cases/get_requests_use_case.dart';
import '../../../../domain/use_cases/add_request_use_case.dart';
import '../../../../domain/use_cases/update_request_status_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';

abstract class RequestState {}
class RequestInitial extends RequestState {}
class RequestLoading extends RequestState {}
class RequestSuccess extends RequestState {
  final List<RequestEntity> requests;
  RequestSuccess(this.requests);
}
class RequestFailure extends RequestState {
  final String message;
  RequestFailure(this.message);
}
class RequestAddedSuccessfully extends RequestState {
  final List<RequestEntity> requests;
  RequestAddedSuccessfully(this.requests);
}

@injectable
class RequestViewModel extends Cubit<RequestState> {
  final GetRequestsUseCase _getRequestsUseCase;
  final AddRequestUseCase _addRequestUseCase;
  final UpdateRequestStatusUseCase _updateRequestStatusUseCase;
  StreamSubscription? _subscription;
  List<RequestEntity> _currentRequests = [];

  RequestViewModel(
    this._getRequestsUseCase, 
    this._addRequestUseCase,
    this._updateRequestStatusUseCase,
  ) : super(RequestInitial());

  void fetchRequests() {
    emit(RequestLoading());
    final user = getIt<AuthCubit>().currentUser;
    if (user == null || user.assignedDoctorId == null) {
      emit(RequestFailure("Assigned doctor not found"));
      return;
    }

    _subscription?.cancel();
    _subscription = _getRequestsUseCase.call(user.assignedDoctorId!).listen(
      (requests) {
        _currentRequests = requests;
        emit(RequestSuccess(requests));
      },
      onError: (error) => emit(RequestFailure(error.toString())),
    );
  }

  Future<void> createRequest({
    required String itemName,
    required int quantity,
    required String supplier,
  }) async {
    final user = getIt<AuthCubit>().currentUser;
    if (user == null || user.assignedDoctorId == null) return;

    try {
      final request = RequestEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        itemName: itemName,
        quantity: quantity,
        supplier: supplier,
        status: 'Pending',
        date: DateTime.now(),
        doctorId: user.assignedDoctorId!,
      );
      
      await _addRequestUseCase.call(request);
      emit(RequestAddedSuccessfully(List.from(_currentRequests)));
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _updateRequestStatusUseCase.call(requestId, status);
      // Re-fetch is handled by the active stream subscription
    } catch (e) {
      emit(RequestFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
