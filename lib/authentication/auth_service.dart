import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      // Trigger the Google Sign In process
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      // If the user cancels the sign-in, googleSignInAccount will be null
      if (googleSignInAccount == null) return null;

      // Obtain GoogleSignInAuthentication for authentication
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      // Use GoogleSignInAuthentication to sign in to Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Sign in to Firebase with the Google credentials
      final UserCredential authResult = await _auth.signInWithCredential(credential);

      return authResult.user;
    } catch (error) {
      print("Error signing in with Google: $error");
      return null;
    }
  }

  // Add signOut method if needed
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
