import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_utils.dart';

class RoleChangeDialog extends StatefulWidget {
  final String currentRole;
  const RoleChangeDialog({super.key, required this.currentRole});


  @override
  State<StatefulWidget> createState() => _RoleChangeDialogState();
}

class _RoleChangeDialogState extends State<RoleChangeDialog> {
  List<String> radioValue = ['Bellperson', 'Dispatcher'];
  String currentValue = "";
  late DocumentReference userRef;
  FirebaseUtils firebaseUtils = FirebaseUtils();
  FirebaseAuth auth = FirebaseAuth.instance;
 @override
 initState() {
   super.initState();
   userRef = firebaseUtils.getUserDocumentReference();
   currentValue = widget.currentRole;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(children: [
          Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 5, left: 8, right: 8),
            child: const Column(
              children: [
                Text("Role Change",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                    )),
                Text(
                    "\nYou may edit your role here. Note that this does not affect the shifts you see on the Exchange. "
                    "\n\nYou may only have one role so it is advised that this reflects your normal scheduling to help people trade with you!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Column(
            children: [
              RadioListTile(title: const Text ('Bellperson'), value: radioValue[0], groupValue: currentValue, onChanged: (value) {
                setState(() {
                  currentValue = value.toString();
                });
              }),
              RadioListTile(title: const Text ('Dispatcher'), value: radioValue[1], groupValue: currentValue, onChanged: (value) {
                setState(() {
                  currentValue = value.toString();
                });
              }),
            ],
          ),
          Container(
            child: ElevatedButton(onPressed: () {
              firebaseUtils.updateRole(userRef, currentValue);
              Navigator.pop(context);
              AppUtils().toastie("Role Updated");
            }, child: const Text("Confirm"),)
          )
        ]),
      )
    ]);
  }

  Future<void> setUserRole() async {
    currentValue = await firebaseUtils.getCurrentUserRole();

  }
}
