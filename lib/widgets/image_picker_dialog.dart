import 'dart:io';
import 'package:bell_exchange/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../screens/ProfileScreen.dart';

class ImagePickerDialog extends StatefulWidget {
  const ImagePickerDialog({super.key});

  @override
  State<StatefulWidget> createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {
  FirebaseUtils firebaseUtils = FirebaseUtils();
  FirebaseAuth auth = FirebaseAuth.instance;
  File? _selectedImage;
  double _resizePictureHeight = 0.0;
  double _resizePictureWidth = 0.0;
  Color _background = ThemeData().dialogBackgroundColor;
  final GlobalKey _pictureContainer = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      backgroundColor: _background,
      children: [
        Column(children: [
          Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.height * 0.8,
              child: GestureDetector(
                onTap: () {
                  pickImageFromGallery();
                },
                child: Container(
                    key: _pictureContainer,
                    margin: EdgeInsets.all(12),
                    child: _selectedImage != null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Image.file(_selectedImage!,
                                    height: _resizePictureHeight,
                                    width: _resizePictureWidth),
                                Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Text("Tap picture to change selection",
                                      style: TextStyle(color: Colors.white)),
                                ),
                                Container(
                                    margin: EdgeInsets.only(top: 60),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        firebaseUtils.setProfilePicture(
                                            auth.currentUser!.uid, _selectedImage!);
                                        Navigator.pop(context); //pops Image Picker Dialog
                                        Navigator.pop(context);
                                      },
                                      child: Text("Confirm",
                                          style: TextStyle(
                                              fontSize: 21,
                                              color: Colors.white)),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.greenAccent),
                                        minimumSize:
                                            MaterialStateProperty.all<Size>(
                                                Size(150, 70)),
                                      ),
                                    ))
                              ])
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Please select an Image",
                                style: TextStyle(fontSize: 20),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "+",
                                style:
                                    TextStyle(fontSize: 70, color: Colors.grey),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )),
              ))
        ])
      ],
    );
  }

  ///Picks a image from the gallery and returns a [Future]
  ///[_resizePictureHeight] will resize a picture too large for the [Container]
  Future pickImageFromGallery() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnedImage == null) return;

    setState(() {
      _selectedImage = File(returnedImage.path);
      _resizePictureHeight = _pictureContainer.currentContext!.size!.height * 0.5;
      _resizePictureWidth = _pictureContainer.currentContext!.size!.width * 0.8;
      _background = Colors.black;
    });
  }




}
