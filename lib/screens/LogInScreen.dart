import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_utils.dart';
import '../authentication/auth_service.dart';
import 'ExchangeScreen.dart';
import 'SignUpScreen.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LogInScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LogInScreen({super.key, required this.title});
  final String title;

  @override
  State<LogInScreen> createState() => _LogInScreenState();

}

class _LogInScreenState extends State<LogInScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isChecked = false;
  String rememberedName = '';
  String rememberedPass = '';
  final Future<SharedPreferences> _preferences =
      SharedPreferences.getInstance();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCheckboxState();
    loadRememberedUser();
    if(isChecked) {
      _usernameController.text = rememberedName;
      _passwordController.text = rememberedPass;
    }
  }

  void login() async {
    try {
      String givenUsername = _usernameController.text.toLowerCase();
      String givenPassword = _passwordController.text;

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: givenUsername,
        password: givenPassword,
      );

      if (userCredential.user != null) {
        // Authentication successful, navigate to ExchangeScreen
        if (context.mounted) {
          updateRememberedUser(_usernameController.text, _passwordController.text);
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const ExchangeScreen()));
        }
      } else {
        Fluttertoast.showToast(
            msg: "Log In Failed.",
            toastLength: Toast
                .LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.black,
            textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Log In Failed.",
          toastLength: Toast
              .LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              bellExchangeGif(),
              usernameTextField(),
              passwordTextField(),
              rememberMeCheckbox(),
              buttonBar(),
              googleSignInButton()
            ],
          ),
        ),
        backgroundColor: Theme.of(context).canvasColor);
  }

  passwordTextField() {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          decoration: const InputDecoration(hintText: 'password'),
          controller: _passwordController,
        ));
  }

  rememberMeCheckbox() {
    return Row(children: [
      Checkbox(
        value: isChecked,
        onChanged: (bool? newValue) {
          updateCheckboxState(newValue!);
        },
      ),
      const Text('Remember Me')
    ],);


  }

  bellExchangeGif() {
    return Image.asset('lib/assets/bell_exchange_animation.gif',
        width: MediaQuery.of(context).size.width, fit: BoxFit.cover);
  }

  textOne() {
    return const Text('Bell Exchange');
  }

  usernameTextField() {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          decoration: const InputDecoration(hintText: 'username'),
          controller: _usernameController,
        ));
  }

  buttonBar() {
    return Center(
        child: ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => login(),
          child: const Text('Log'),
        ),
        ElevatedButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpScreen())),
            child: const Text('Sign Up'))
      ],
    ));
  }

  googleSignInButton() {
    return SignInButton(
      Buttons.Google,
      onPressed: () async {
        User? user = await _authService.signInWithGoogle();

        if (user != null) {
          AppUtils().toastie('User signed in: ${user.displayName}');
          if(context.mounted) {
            Navigator.popAndPushNamed(context, '/exchange');
          }
        } else {
          AppUtils().toastie('Google Sign-In failed or was canceled.');
        }
      },
    );
  }

  Future<void> loadCheckboxState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isChecked = prefs.getBool('isChecked') ?? true;
    });
  }

  Future<void> updateCheckboxState(bool newValue) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isChecked = newValue;
    });
    prefs.setBool('isChecked', isChecked);
  }

  Future<void> loadRememberedUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberedName = prefs.getString('rememberedName') ?? '';
      rememberedPass = prefs.getString('rememberedPass') ?? '';
      _usernameController.text = rememberedName;
      _passwordController.text = rememberedPass;
    });
  }

  Future<void> updateRememberedUser(String name, String pass) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if(isChecked) {
      prefs.setString('rememberedName', name);
      prefs.setString('rememberedPass', pass);
    }
    else if(!isChecked) {
      await prefs.remove('rememberedName');
      await prefs.remove('rememberedPass');
      _usernameController.text = '';
      _passwordController.text = '';
    }
  }
}
