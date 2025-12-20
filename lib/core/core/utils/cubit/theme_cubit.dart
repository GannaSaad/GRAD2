import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static ThemeMode _currentMode = ThemeMode.dark;

  ThemeCubit() : super(_currentMode);

  static bool isDark() {
    return _currentMode == ThemeMode.dark;
  }

  void setLight() {
    _currentMode = ThemeMode.light;
    emit(ThemeMode.light);
  }

  void setDark() {
    _currentMode = ThemeMode.dark;
    emit(ThemeMode.dark);
  }

  void toggleTheme() {
    _currentMode =
    _currentMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(_currentMode);
  }
}
