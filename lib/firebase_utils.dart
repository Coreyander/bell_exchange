import 'package:bell_exchange/screens/SettingsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Screens/CreateUserScreen.dart';

class FirebaseUtils {
  /*
  * Use cases to develop:
  *
  * - I'm opening the app to sign up
  * - I'm opening the app to change my password
  * - I'm opening the app but I forgot my password
  * - I'm opening the app to log in
  * - I'm adding a scheduled day to give away
  * - I'm deleting a scheduled day, I changed my mind
  * - I'm changing filters to see specific days
  * - I'm changing filters to see specific roles
  * - I'm reading the shift exchange Facebook feed from the app
  * - I'm sending a message to a user
  * - I'm requesting a trade to pick up
  * - I'm requesting a trade to give away
  * - I'm just looking
  *
  *
  *
  * */

  authUserWithPassword() {}

  authUserWithGoogle() {}

  authUserWithFacebook() {}

  String getCurrentUserID(FirebaseAuth auth) {
    User? user = auth.currentUser;
    if (user != null) {
      String userId = user.uid;
      return userId;
    } else {
      // No user is signed in
      return '';
    }
  }

  signOff() async {
    GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      await auth.signOut();
      await googleSignIn.signOut();
      Fluttertoast.showToast(
          msg: "Logged off Successful. See Ya Real Soon!",
          toastLength: Toast
              .LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "There was a problem logging off.",
          toastLength: Toast
              .LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
    filterFeed() {}
  }
}