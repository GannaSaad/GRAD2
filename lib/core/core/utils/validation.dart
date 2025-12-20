import 'dart:core';

class AppValidator {
  AppValidator._();

  static String? validateEmail(String?val){
    RegExp emailRegExp = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if(val==null||val.isEmpty){
      return "Email can't be empty";
    } else if(!emailRegExp.hasMatch(val)){
      return "Enter a valid email";
    }else{
      return null;
    }
  }
  static String? validatePassword(String?val){
    RegExp passwordRegExp = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
    if(val==null||val.isEmpty){
      return "Password can't be empty";
    }else if(!passwordRegExp.hasMatch(val)){
      return "Password must contain at least one uppercase letter, one lowercase letter, one digit, and one special character";

    } else if(val.length<6){
      return "Password must be at least 6 characters";
    }else{
      return null;
    }
  }
  static String? validateRePassword(String?val,String?password){
    if(val==null||val.isEmpty){
      return "Re-entered password can't be empty";
    }else if(val!=password){
      return "Password does not match";
    }else{
      return null;
    }
  }
  static String? validateName(String?val){
    if(val==null||val.isEmpty){
      return "Name can't be empty";
    }else if(val.length<3){
      return "Name must be at least 3 characters";
    }else{
      return null;
    }
  }
  static String? validatePhone(String?val){
    RegExp phoneRegExp = RegExp(r'^\+?[0-9]{10,13}$');
    if(val==null||val.isEmpty){
      return "Phone number can't be empty";
    }else if(!phoneRegExp.hasMatch(val)){
      return "Enter a valid phone number";
    }else{
      return null;
    }
  }


}