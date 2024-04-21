import 'dart:async';

import 'package:bell_exchange/Screens/LogInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';

import '../animations/transitions.dart';
import '../app_utils.dart';
import '../database/my_user.dart';
import 'SignUpSplashScreen.dart';
import 'UpdateUserScreen.dart';
import 'ExchangeScreen.dart';
//TODO: Create error states for the fields
//TODO: Check Firebase for duplicate User ID & add error on dupe
//TODO: Add animations!
//TODO: Add theming to the fonts and background
//TODO: Get a little ringing bell animation in here!
//TODO: Add user ID parameters capped first character and no space

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with TickerProviderStateMixin {
  //Animations
  Transitions transitions = Transitions();
  late AnimationController _controller;
  late Animation<double> _animation;

  //Layout Thematics
  final double left = 5;
  final double top = 12;
  final double right = 5;
  final double bottom = 12;

  //Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _defaultController = TextEditingController();

  //State Variables
  String _passwordHintText = 'password must be at least 8 characters long';
  bool _usernameAsDisplayIsChecked = false;
  final Map<String, double> _textScaleFactor = {
    'userNameTextFactor': 1.3,
    'passwordTextFactor': 1.3,
    'confirmTextFactor': 1.3,
  };

  //Focus Nodes
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _displayNameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    Timer(Duration(seconds: 1), () {
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context,
          transitions.slide(const LogInScreen(title: "title",), 250, 1, 0),
        );
        return true;
      },
      child: Scaffold(
        body: Center(
          child: SafeArea(
            child: FadeTransition(
              opacity: _animation,
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
                    child: Column(
                      children: <Widget>[
                        userNameTextField(),
                        passwordTextField(),
                        confirmPasswordTextField(),
                      ],
                    ),
                  ),
                  displayNameText(),
                  displayNameFieldAndButton(),
                  submitButtonBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  userNameTextField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: TextField(
        controller: _usernameController,
        decoration: const InputDecoration(labelText: 'Username'),
      ),
    );
  }

  passwordTextField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: TextField(
        controller: _passwordController,
        decoration: const InputDecoration(
            labelText: 'Password',
            hintText: 'password must be at least 8 characters long'),
      ),
    );
  }

  confirmPasswordTextField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: TextField(
        controller: _confirmPasswordController,
        decoration: const InputDecoration(labelText: 'Confirm Password'),
      ),
    );
  }

  displayNameText() {
    return const Padding(
        padding: EdgeInsets.all(12),
        child: Text(
            'The following will be the name displayed to others if Alias mode is enable. \n\n If Alias is off, your real name will be used.'));
  }

  displayNameFieldAndButton() {
    return Column(children: <Widget>[
      Padding(
          padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
          child: TextField(
            controller: _displayNameController,
            focusNode: _displayNameFocusNode,
            textAlign: TextAlign.center,
            maxLength: 25,
          )),
    ]);
  }

  submitButtonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => submitButtonBarPushed(),
          child: const Text('Confirm Credentials'),
        )
      ],
    );
  }

  submitButtonBarPushed() {
    if (_passwordController.text == _confirmPasswordController.text &&
        _passwordController.text.length >= 8 &&
        _usernameController.text != '') {
      var email = _usernameController.text;
      if (EmailValidator.validate(email)) {
        registerUser(_usernameController.text, _passwordController.text);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const UpdateUserScreen()));
      } else {
        Fluttertoast.showToast(
            msg: 'Invalid email!',
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      }
    } else if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordFocusNode.requestFocus();
      Fluttertoast.showToast(
          msg: 'Passwords do not match!',
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
    }
  }

  void registerUser(String userName, String password) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userName,
        password: password,
      );

      // User registered successfully
      User user = userCredential.user!;
      String userID = FirebaseAuth.instance.currentUser!.uid;
      MyUser myUser = MyUser(userID, '', '', '', '');
      myUser.createUserInFirebase();
      AppUtils().toastie('User registered: ${user.uid}');
      print('User registered: ${user.uid}');
    } catch (e) {
      // Handle registration errors
      AppUtils().toastie('Error during registration: $e');
      print('Error during registration: $e');
    }
  }
}
