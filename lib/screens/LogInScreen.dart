import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'ExchangeScreen.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key, required this.title});
  final String title;

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  auth() {
    toast();
    String givenUsername = _usernameController.text.toLowerCase();
    String givenPassword = _passwordController.text;
    if (givenUsername == 'test' && givenPassword == 'test') {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ExchangeScreen()));
    }
  }

  toast() {
    Fluttertoast.showToast(
        msg: 'Button Pressed!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
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
              buttonBar()
            ],
          ),
        ),
        backgroundColor: Theme.of(context).canvasColor
    );
  }

  passwordTextField() {
    return Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          decoration: const InputDecoration(hintText: 'password'),
          controller: _passwordController,
        ));
  }

  bellExchangeGif() {
    return Image.asset(
        'lib/assets/bell_exchange_animation.gif',
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover
        );
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
          onPressed: auth,
          child: const Text('Log'),
        ),
        ElevatedButton(onPressed: toast, child: const Text('Sign Up'))
      ],
    ));
  }
}
