import 'dart:core';

class AppValidator {
  AppValidator._();

  static String? validateEmail(String? val) {
    // Improved RegExp to support complex domains like .edu.eg
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$");
    
    if (val == null || val.trim().isEmpty) {
      return "Email can't be empty";
    } else if (!emailRegExp.hasMatch(val.trim())) {
      return "Enter a valid email address";
    } else {
      return null;
    }
  }

  static String? validatePassword(String? val) {
    // Standard secure password: min 8 chars, 1 upper, 1 lower, 1 digit, 1 special
    RegExp passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    
    if (val == null || val.isEmpty) {
      return "Password can't be empty";
    } else if (!passwordRegExp.hasMatch(val)) {
      return "Password must be at least 8 characters and include uppercase, lowercase, digit, and special character (@#\$&*~)";
    } else {
      return null;
    }
  }

  static String? validateRePassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return "Re-entered password can't be empty";
    } else if (val != password) {
      return "Passwords do not match";
    } else {
      return null;
    }
  }

  static String? validateName(String? val) {
    if (val == null || val.trim().isEmpty) {
      return "Name can't be empty";
    } else if (val.trim().length < 3) {
      return "Name must be at least 3 characters";
    } else {
      return null;
    }
  }

  static String? validatePhone(String? val) {
    RegExp phoneRegExp = RegExp(r'^\+?[0-9]{10,13}$');
    if (val == null || val.trim().isEmpty) {
      return "Phone number can't be empty";
    } else if (!phoneRegExp.hasMatch(val.trim())) {
      return "Enter a valid phone number";
    } else {
      return null;
    }
  }
}
