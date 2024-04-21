import 'package:bell_exchange/app_utils.dart';
import 'package:bell_exchange/database/my_user.dart';
import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpGoogleScreen extends StatefulWidget {
  const SignUpGoogleScreen({super.key});
  @override
  State<StatefulWidget> createState() => _SignUpGoogleScreenState();
}

class _SignUpGoogleScreenState extends State<SignUpGoogleScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hubidController = TextEditingController();
  final TextEditingController _pernerController = TextEditingController();
  FirebaseUtils firebaseUtils = FirebaseUtils();

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
       //Will delete the user auth if back is pressed before submitting info
        firebaseUtils.deleteCurrentUser();
        Navigator.pushReplacementNamed(context,'/login');
        return true;
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Form(
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _hubidController,
                    decoration: const InputDecoration(labelText: 'Hub ID'),
                  ),
                  TextField(
                    controller: _pernerController,
                    decoration: const InputDecoration(labelText: 'Perner'),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                onFormSubmit();
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  initialize() {}

  hubID() {
    return TextField();
  }

  onFormSubmit() async {
    print('form submitting');
    FirebaseAuth auth = FirebaseAuth.instance;
    String userId = firebaseUtils.getCurrentUserID(auth);
    DocumentSnapshot userData = await firebaseUtils.getUserDocument(userId);
    print('user data retrieved');
    if(userData.exists) {
      firebaseUtils.updateName(userData.reference, _nameController.text);
      firebaseUtils.updateHubId(userData.reference, _hubidController.text);
      firebaseUtils.updatePerner(userData.reference, _pernerController.text);
    }
    if(context.mounted) {
      print('navigation initiated');
      Navigator.pushReplacementNamed(context, '/exchange');
    }
    AppUtils().toastie("User ${_nameController.text} Created Successfully! \n Welcome to the Bell Exchange!");
  }



  name() {}
  perner() {}
  role() {}
}
