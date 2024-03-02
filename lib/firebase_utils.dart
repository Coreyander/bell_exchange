

import 'package:bell_exchange/screens/SettingsScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'Screens/UpdateUserScreen.dart';

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

  Future<DocumentSnapshot> getUserDocument(String userId) async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('user_database')
          .doc(userId)
          .get();
      return documentSnapshot;
    } catch (e) {
      print('Error getting user document: $e');
      throw e;
    }

  }

  Future<Map<String, dynamic>> getUserData() async {
    Map<String, dynamic> userData = {};
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = getCurrentUserID(auth);
    DocumentSnapshot userDocument = await getUserDocument(userId);
    if (userDocument.exists) {
      userData = userDocument.data() as Map<String, dynamic>? ?? {};
      return userData;
    } else {
      print('User document does not exist');
      return userData;
    }
  }



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

  ///Gets the name of the current active user logged in the app
  Future<String> getCurrentUserName() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      CollectionReference usersCollection = firestore.collection('user_database');
      DocumentSnapshot documentSnapshot = await usersCollection.doc(user.uid).get();
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('name')) {
        String name = data['name'];
        print(name);
        return name;
      } else {
        return 'Name not found';
      }
    } else {
      return 'No User Signed On';
    }
  }

  Future<String> getUserName(String userId) async {
    DocumentSnapshot documentSnapshot = await getUserDocument(userId);
    Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey('name')) {
      String name = data['name'];
      return name;
    } else {
      return 'Name not found';
    }
  }


  ///Requires a document reference for a user. Updates that user's name data.
  Future<void> updateName(DocumentReference userDocumentRef, String name) async {
    try {
      await userDocumentRef.update({'name': name});
      print('Name updated successfully');
    } catch (error) {
      print('Error updating name: $error');
    }
  }
  ///Requires a document reference for a user. Updates that user's hubID data.
  Future<void> updateHubId(DocumentReference userDocumentRef, String hubId) async {
    try {
      await userDocumentRef.update({'hubID': hubId});
      print('HubID updated successfully');
    } catch (error) {
      print('Error updating HubID: $error');
    }
  }
  ///Requires a document reference for a user. Updates that user's perner data.
  Future<void> updatePerner(DocumentReference userDocumentRef, String perner) async {
    try {
      await userDocumentRef.update({'perner': perner});
      print('Perner updated successfully');
    } catch (error) {
      print('Error updating Perner: $error');
    }
  }

  CollectionReference<Object?> getChatroomsForUser(String userId) {
    CollectionReference userCollection = FirebaseFirestore.instance.collection('user_data');
    DocumentReference userDocRef = userCollection.doc(userId);
    CollectionReference chatRoomsCollection = userDocRef.collection('chatrooms');
    return chatRoomsCollection;
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

  Future<void> deleteCurrentUser() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      User? user = auth.currentUser;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('user_database').doc(user?.uid);
      if (user != null) {
        await userDocRef.delete();
        await user.delete();
      } else {
        print('No user signed in.');
      }
    } catch (error) {
      print('Error deleting user account: $error');
    }
  }
}