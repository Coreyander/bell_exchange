import 'dart:async';
import 'package:flutter/material.dart';
import 'SignUpGoogleScreen.dart';
import 'SignUpScreen.dart';
///Splash screen
class SignUpSplash extends StatefulWidget {
  final int path;
  const SignUpSplash({super.key,required this.path});

  @override
  _SignUpSplashState createState() => _SignUpSplashState();
}

class _SignUpSplashState extends State<SignUpSplash>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 4),
    );
    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && widget.path == 1) {
          Navigator.pushReplacement(context, _routeOne());
        }
        if (status == AnimationStatus.completed && widget.path == 2) {
          Navigator.pushReplacement(context, _routeTwo());
        }
      });

    // Start the animation
    _controller.forward();
  }

  //route to creating new user from pass and username
  Route _routeOne() {
    return PageRouteBuilder(
      maintainState: false,
      pageBuilder: (context, animation, secondaryAnimation) => SignUpScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  //route from the Google login button
  Route _routeTwo() {
    return PageRouteBuilder(
      maintainState: false,
      pageBuilder: (context, animation, secondaryAnimation) => SignUpGoogleScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        //Navigator.popUntil(context, ModalRoute.withName('/login'));
        Navigator.pushReplacementNamed(context, '/login');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          // You can add any widgets you want to display during the splash screen
          child: FadeTransition(
            opacity: _animation,
            child: Text(
              'Welcome to the Bell Exchange',
              textScaleFactor: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
