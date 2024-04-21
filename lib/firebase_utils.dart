

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'Screens/UpdateUserScreen.dart';
import 'app_utils.dart';
import 'database/my_user.dart';

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

  DocumentReference getUserDocumentReference() {
    DocumentReference docRef = FirebaseFirestore.instance.collection('user_database').doc(auth.currentUser?.uid);
    return docRef;
  }

  ///Returns only the data in the form of a Map from Firebase.
  ///If you want to return the data as a parsed object MyUser then use [getUserDataAsMyUser()]
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

  ///Returns data from Firebase on a user. If successful, this will parse the data
  ///into a [MyUser] Object and return the object.
  Future<MyUser> getUserDataAsMyUser() async {
    Map<String, dynamic> userData = {};
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = getCurrentUserID(auth);
    DocumentSnapshot userDocument = await getUserDocument(userId);
    if (userDocument.exists) {
      userData = userDocument.data() as Map<String, dynamic>? ?? {};
      try {
        String userID = userData['userID'];
        String name = userData['name'];
        String role = userData['role'];
        String hubID = userData['hubID'];
        String perner = userData['perner'];
        return MyUser(userID,name,role,hubID,perner);
      } catch (e) {
        return MyUser("","Error","","","");
      }
    } else {
      if (kDebugMode) {
        print('User document does not exist');
      }
      return MyUser("", "", "", "", "");
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

  ///Gets the role of the current active user logged in the app
  Future<String> getCurrentUserRole() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (user != null) {
      CollectionReference usersCollection = firestore.collection('user_database');
      DocumentSnapshot documentSnapshot = await usersCollection.doc(user.uid).get();
      Map<String, dynamic>? data = documentSnapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('role')) {
        String role = data['role'];
        print(role);
        return role;
      } else {
        return 'Role not found';
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

  Future<Uint8List?> getProfileImage(String uid) async {
    final storage = FirebaseStorage.instance;
    DocumentSnapshot documentSnapshot = await getUserDocument(
        uid);
    Map<String, dynamic>? data = documentSnapshot.data() as Map<String,
        dynamic>?;
    if (data != null && data.containsKey('profilePicture')) {
      String profilePictureURL = data['profilePicture'];
      Reference imageRef = storage.refFromURL(profilePictureURL);
      try {
        const twentyFiveMegabytes = 1024 * 1024 * 25;
        final Uint8List? image = await imageRef.getData(twentyFiveMegabytes);
        return image;
      }
      catch (e) {
        AppUtils().toastie("Error Retrieving Image Data");
        return Uint8List(0);
      }
    }
  }

  Stream<Uint8List> getProfileImageStream() {

    StreamController<Uint8List> streamController = StreamController<Uint8List>();
    Reference reference = FirebaseStorage.instance.ref().child('profileImages/${auth.currentUser?.uid}');
    reference.getData().then((data) {
      streamController.add(data!);
      }).catchError((error) {
      if (kDebugMode) {
        print('Error retrieving profile image: $error');
      }
      streamController.addError(error);
    });
    return streamController.stream;

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
  ///Requires a document reference for a user. Updates that user's role data.
  Future<void> updateRole(DocumentReference userDocumentRef, String role) async {
    try {
      await userDocumentRef.update({'role': role});
      print('Role updated successfully');
    } catch (error) {
      print('Error updating Role: $error');
    }
  }

  ///Gets the chatroom collection associated with the userId passed
  Future<List<DocumentSnapshot>> getChatrooms(String userId) async {
    CollectionReference chatroomCollection = FirebaseFirestore.instance.collection('chatrooms');
    Query queryParticipant = chatroomCollection.where('participant', isEqualTo: userId);
    Query queryOwner = chatroomCollection.where('owner', isEqualTo: userId);

    // Execute both queries concurrently
    List<QuerySnapshot> querySnapshots = await Future.wait([
      queryParticipant.get(),
      queryOwner.get(),
    ]);

    // Extract documents from query snapshots
    List<DocumentSnapshot> documents = [];
    for (QuerySnapshot snapshot in querySnapshots) {
      documents.addAll(snapshot.docs);
    }

    return documents;
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


    setProfilePicture(String uid, File file) async {
        final storage = FirebaseStorage.instance;
        await storage.ref('profileImages/$uid').putFile(file);
        String downloadURL = await storage.ref('profileImages/$uid').getDownloadURL();
        DocumentReference docReference = FirebaseFirestore.instance.collection('user_database').doc(uid);
        await docReference.set({'profilePicture':downloadURL}, SetOptions(merge: true));
    }



}