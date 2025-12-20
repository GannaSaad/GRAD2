import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

  void startSplash() {
    Timer(const Duration(seconds: 2), () {
      emit(state.copyWith(status: SplashStatus.finished));
    });
  }
}