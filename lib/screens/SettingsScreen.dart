import 'package:bell_exchange/firebase_utils.dart';
import 'package:flutter/material.dart';

import '../app_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'), // Set your app title here
      ),
      body: Column(
        children: [logOut()],
      ),
    );
  }

  initialize() {}

  logOut() {
    return ElevatedButton(onPressed: () {FirebaseUtils().signOff();
      AppUtils().popStackAndReturnToSignIn(context);}, child: const Text("Sign Out"));
  }


}
