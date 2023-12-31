import 'package:bell_exchange/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../database/my_user.dart';
import 'ExchangeScreen.dart';

///Map
///From: SignUp Screen
///To: Exchange Screen
///This screen is used to add basic user data that will be used
///to interact with the Exchange page and other users.
///
enum Role { bellperson, dispatcher}

FirebaseAuth auth = FirebaseAuth.instance;

class CreateUserScreen extends StatefulWidget {
  const CreateUserScreen({super.key});
  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  //Layout Thematics
  final double left = 5;
  final double top = 12;
  final double right = 5;
  final double bottom = 12;

  //State Variables
  Role selectedRole = Role.bellperson;
  String selectedRoleText = '';
  String userID = FirebaseUtils().getCurrentUserID(auth);
  TextEditingController nameController = TextEditingController();
  TextEditingController hubIDController = TextEditingController();
  TextEditingController pernerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SafeArea(
          child: ListView(
        children: <Widget>[
          nameTextField(),
          hubIDTextField(),
          pernerTextField(),
          rolePopupMenu(),
          confirmButton()
        ],
      )),
    ));
  }

  nameTextField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: TextField(
        controller: nameController,
        decoration: const InputDecoration(labelText: 'Name'),
      ),
    );
  }

  rolePopupMenu() {
    return Padding(
        padding: EdgeInsets.fromLTRB(left, top, right, bottom),
        child: Row(children: [
          const Text('Select Role: '),
          PopupMenuButton<Role>(
            initialValue: selectedRole,
            // Callback that sets the selected popup menu item.
            onSelected: (Role item) {
              setState(() {
                selectedRole = item;
                if(selectedRole == Role.bellperson) {
                  selectedRoleText = 'Bellperson';
                }
                else if(selectedRole == Role.dispatcher) {
                  selectedRoleText = 'Dispatcher';
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Role>>[
              const PopupMenuItem<Role>(
                value: Role.bellperson,
                child: Text('Bellperson'),
              ),
              const PopupMenuItem<Role>(
                value: Role.dispatcher,
                child: Text('Dispatcher'),
              ),
            ],
          ),
          Text(selectedRoleText)
        ]));
  }

  hubIDTextField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: TextField(
        controller: hubIDController,
        decoration: const InputDecoration(labelText: 'Hub ID'),
      ),
    );
  }

  pernerTextField() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: TextField(
        controller: pernerController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(labelText: 'Perner'),
      ),
    );
  }

  confirmButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: ElevatedButton(child: const Text('Confirm'), onPressed: () => onPress())
    );
  }

  onPress() {
      MyUser user = MyUser(userID, nameController.text, selectedRoleText, hubIDController.text, pernerController.text);
      user.createUserInFirebase();
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ExchangeScreen()));
    //TODO: Create Flag choices, right now they are all set to False
  }

}
