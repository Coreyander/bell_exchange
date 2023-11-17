import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  filterFeed() {}


}