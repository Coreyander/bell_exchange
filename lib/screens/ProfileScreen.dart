import 'dart:async';
import 'dart:typed_data';

import 'package:bell_exchange/database/my_user.dart';
import 'package:bell_exchange/firebase_utils.dart';
import 'package:bell_exchange/widgets/image_picker_dialog.dart';
import 'package:bell_exchange/widgets/role_change_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseUtils firebaseUtils = FirebaseUtils();
  FirebaseAuth auth = FirebaseAuth.instance;
  dynamic _decorationImage = const AssetImage("lib/assets/whitespace.png");
  String _lastImageURL = "";
  bool _profilePictureIsLoading = false;
  MyUser user = MyUser("", "", "", "", "");
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'), // Set your app title here
      ),
      body: Column(
        children: [
          name(),
          profileImage(),
          editImageButton(),
          role(),
          editRoleButton(),
          credentialsText(),
          hubID(),
          perner()
        ],
      ),
    );
  }

  initialize() async {
    user = await firebaseUtils.getUserDataAsMyUser();
  }

  openImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Upload Image From'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () async {
                showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return ImagePickerDialog();
                          });
              },
              child: const Text('Gallery'),
            ),
            SimpleDialogOption(
              onPressed: () {/* Handle option 2 */},
              child: const Text('Camera'),
            ),
          ],
        );
      },
    );
  }

  loadProfileImage() async {
    _profilePictureIsLoading = true;
    try {
      Uint8List? bytes = await firebaseUtils.getProfileImage(auth.currentUser!.uid);
      if (bytes?.lengthInBytes != 0) {
        setState(() {
          _decorationImage = MemoryImage(bytes!);
          _profilePictureIsLoading = false;
        });
      } else {
        _decorationImage = const AssetImage("lib/assets/profile_default.png");
        _profilePictureIsLoading = false;
      }
    } catch (e) {
      print('Error loading image: $e');
      _profilePictureIsLoading = false;
    }
  }

  name() {
    return Text(user.name, style: const TextStyle(fontSize: 34));
  }

  profileImage() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('user_database').doc(auth.currentUser?.uid).snapshots(), // Assuming you have a stream for profile image updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData && snapshot.data != null) {
          String? imageURL = snapshot.data!.get('profilePicture');
          if (_lastImageURL != imageURL) {
            _lastImageURL = imageURL!;
            loadProfileImage();
          }
          return _profilePictureIsLoading == true
              ?
          const CircularProgressIndicator()
              :
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _decorationImage,
                fit: BoxFit.fill,
              ),
              shape: BoxShape.circle,
            ),
          );
        } else {
          // If there's no data, return a default image
          return Container(
            margin: const EdgeInsets.only(top: 20),
            height: 200.0,
            width: 200.0,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: const AssetImage("lib/assets/profile_default.png"),
                fit: BoxFit.fill,
              ),
              shape: BoxShape.circle,
            ),
          );
        }
      },
    );
  }

  editImageButton() {
    return Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(right: 40),
        child: ElevatedButton(
            onPressed: () {
              openImagePickerDialog();
              },
            child: const Text('Edit Image')));
  }

  role() {
    return Container(
        margin: const EdgeInsets.only(top: 10),
        child: StreamBuilder<DocumentSnapshot>(
            stream: firebaseUtils.getUserDocumentReference().snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // If connection state is waiting, return a placeholder or loading indicator
                return CircularProgressIndicator();
              }
              else if (snapshot.hasError) {
                // If there's an error, handle it accordingly
                return Text('Error: ${snapshot.error}');
              }
              else if (snapshot.hasData && snapshot.data != null) {
                String role = snapshot.data!['role'] ?? '';
                if (role != '') {
                  user.role = role;
                }
                return Text(
                  role,
                  style: const TextStyle(fontSize: 22),
                );
              }
              else {
                return const Text(
                  "Role: No Role Found",
                  style: TextStyle(fontSize: 22),
                );
              }
            }));
  }

  editRoleButton() {
    return Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(right: 40),
        child: ElevatedButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return RoleChangeDialog(
                    currentRole: user.role,
                  );
                });
          },
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(80, 30))),
          child: const Text("Edit"),
        ));
  }

  credentialsText() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 30),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: 2,
                ),
              )),
              child: Text(
                "Credentials",
                style: TextStyle(fontSize: 22),
              ),
            )
          ],
        ));
  }

  hubID() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 30, top: 20),
        child: Row(
          children: [
            Text("HubID:     ", style: TextStyle(fontSize: 21)),
            Text(user.hubID, style: TextStyle(fontSize: 17))
          ],
        ));
  }

  perner() {
    return Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(left: 30),
        child: Row(
          children: [
            Text(
              "Perner:     ",
              style: TextStyle(fontSize: 21),
            ),
            Text(user.perner, style: TextStyle(fontSize: 17))
          ],
        ));
  }
}
