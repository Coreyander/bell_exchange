import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
class AppUtils {
  toastie(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  toaster(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_LONG);
  }

  popStackAndReturnToSignIn(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // replace with the route name of your LogInScreen
          (route) => false, // this predicate will remove all routes
    );
  }
}
