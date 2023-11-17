import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:email_validator/email_validator.dart';

import 'CreateUserScreen.dart';
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

class _SignUpScreenState extends State<SignUpScreen> {

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
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SafeArea(
                child: ListView(children: <Widget>[
      Padding(
          padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
          child: Column(
            children: <Widget>[
              signUpInstructions(),
              userNameText(),
              userNameField()
            ],
          )),
      Padding(
          padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
          child: Column(children: [passwordText(), passwordField()])),
      Padding(
          padding: const EdgeInsets.fromLTRB(5, 12, 5, 12),
          child: Column(
              children: [confirmPasswordText(), confirmPasswordField()])),
      displayNameText(),
      displayNameFieldAndButton(),
      submitButtonBar()
    ]))));
  }

  signUpInstructions() {
    return const Column(children: [
      Text(
        'Welcome to the Bell Exchange!\n\n',
        textScaleFactor: 1.4,
        textAlign: TextAlign.center,
      ),
      Text(
        'Set Email and Password to sign in with below.\n',
        textAlign: TextAlign.start,
      ),
    ]);
  }

  userNameText() {
    return Text('Enter Email: ',
        textScaleFactor: _textScaleFactor['userNameTextFactor'] ?? 1.0);
  }

  userNameField() {
    return Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            setState(() {
              _textScaleFactor['userNameTextFactor'] = 1.3;
            });
          } else {
            setState(() {
              _textScaleFactor['userNameTextFactor'] = 1.0;
            });
          }
        },
        child: TextField(
          controller: _usernameController,
          focusNode: _userNameFocusNode,
          textAlign: TextAlign.center,
          maxLength: 25,
        ));
  }

  passwordText() {
    return Text('Enter Password: ',
        textScaleFactor: _textScaleFactor['passwordTextFactor'] ?? 1.0);
  }

  passwordField() {
    return Focus(
      onFocusChange: (hasFocus) {
        if (hasFocus) {
          setState(() {
            _passwordHintText = '';
            _textScaleFactor['passwordTextFactor'] = 1.3;
          });
        } else {
          setState(() {
            print('lost focus'); //DEBUG
            _passwordHintText = 'password must be at least 8 characters long';
            _textScaleFactor['passwordTextFactor'] = 1.0;
          });
        }
      },
      child: TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        textAlign: TextAlign.center,
        obscureText: true,
        maxLength: 100,
        decoration: InputDecoration(hintText: _passwordHintText),
      ),
    );
  }

  confirmPasswordText() {
    return Text('Confirm Password: ',
        textScaleFactor: _textScaleFactor['confirmTextFactor'] ?? 1.0);
  }

  confirmPasswordField() {
    return Focus(
        onFocusChange: (hasFocus) {
          if (hasFocus) {
            setState(() {
              _textScaleFactor['confirmTextFactor'] = 1.3;
            });
          } else {
            setState(() {
              _textScaleFactor['confirmTextFactor'] = 1.0;
            });
          }
        },
        child: TextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: true,
          textAlign: TextAlign.center,
        ));
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
     // Row(mainAxisAlignment: MainAxisAlignment.center, children: [
     //   Padding(
     //       padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
     //       child: SizedBox(
     //         height: 30,
     //         width: 30,
     //         child: CheckMark(
     //           active: _usernameAsDisplayIsChecked,
     //           curve: Curves.decelerate,
     //           duration: const Duration(milliseconds: 500),
     //         ),
     //       )),
     //   ElevatedButton(
     //       onPressed: () => displayNameButtonPressed(),
     //       child: const Text('Use Email as Display Name'))
     // ]),
    ]);
  }


  /// This was a button that changed display name to match the username,
  /// however later I realized that Firebase only auths password with email addresses.
  /// TODO: Either delete this code altogether or explore custom sign in options OR redo it with regex to ignore DNS of email names.
  /// *
  //displayNameButtonPressed() {
  //  ///If the displayname button is pressed, the sign in ID will copy over to displayname.
  //  ///If it is deselected, a third controller, defaultController, clears its text and stops the mimic behavior
  //  ///by assigning the displayNameController to the default. A checkmark animation alerts the user if they are
  //  ///mimicking the fields or not.
//
  //  if (_usernameAsDisplayIsChecked == true) {
  //    _defaultController.text = "";
  //    _displayNameController = _defaultController;
  //    _usernameAsDisplayIsChecked = false;
  //    setState(() {
  //      _usernameAsDisplayIsChecked = false;
  //    });
  //    if (_displayNameController.text == _usernameController.text) {
  //      _displayNameController.text = '';
  //    }
  //  } else if (_usernameAsDisplayIsChecked != true) {
  //    _usernameAsDisplayIsChecked = true;
  //    Fluttertoast.showToast(
  //        msg: 'Display Name Copied!',
  //        gravity: ToastGravity.BOTTOM,
  //        toastLength: Toast.LENGTH_SHORT);
  //    setState(() {
  //      _usernameAsDisplayIsChecked = true;
  //    });
  //    _displayNameController.text = _usernameController.text;
  //    _displayNameController = _usernameController;
  //  }
  //}

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
        _passwordController.text.length >= 8 && _usernameController.text != '') {
      var email = _usernameController.text;
      if(EmailValidator.validate(email)) {
        registerUser(_usernameController.text, _passwordController.text);
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const CreateUserScreen()));
      }
      else {
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
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: userName,
        password: password,
      );

      // User registered successfully
      User user = userCredential.user!;
      print('User registered: ${user.uid}');
    } catch (e) {
      // Handle registration errors
      print('Error during registration: $e');
    }
  }
}
