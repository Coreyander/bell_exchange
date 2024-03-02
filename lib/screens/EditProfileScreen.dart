import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<StatefulWidget> createState() => _EditProfileScreenState();

}

class _EditProfileScreenState extends State<EditProfileScreen> {

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Header'), // Set your app title here
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }

  initialize() {

  }

}