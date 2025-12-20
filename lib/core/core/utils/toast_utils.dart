import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils{


  static Future<bool?> toast({required String msg,required Color bgColor,required Color txtColor}){
    return Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: bgColor,
        textColor: txtColor,
        fontSize: 16.0
    );
  }
}