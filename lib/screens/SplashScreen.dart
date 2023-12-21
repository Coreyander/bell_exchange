import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key, required String title});


  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;

    // Schedule a delayed task for navigation
    Future.delayed(const Duration(seconds: 2), () {
      if(_auth.currentUser != null) {

        Navigator.popAndPushNamed(context, '/exchange');
      }
      else {
        Navigator.popAndPushNamed(context, '/login');
      }
    });
    return const Scaffold(
      body: Center(
        child: Text('Splash Screen'),
      ),
    );
  }

}
