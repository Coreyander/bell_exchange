import 'dart:typed_data';

import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database/messenger/chatroom.dart';
import '../screens/ChatroomScreen.dart';

///A UI component that displays a chatroom. Clicking the card navigates to the displayed chatroom
///The chatroom Object being used to create a card has fields for ownerId, participantId, and chatroomId
///the requirement chatroom needs a Chatroom Object with data to fill out the fields in the card
class ChatroomCard extends StatefulWidget {
  const ChatroomCard({super.key, required this.chatroom});
  final Chatroom chatroom;
  @override
  State<StatefulWidget> createState() => _ChatroomCardState();
}

class _ChatroomCardState extends State<ChatroomCard> {
  FirebaseUtils firebaseUtils = FirebaseUtils();
  FirebaseAuth auth = FirebaseAuth.instance;
  dynamic _decorationImage = AssetImage("lib/assets/profile_default.png");
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Card(
            child: Container(
          height: 60,
          child: Row(
            children: [image(), name()],
          ),
        )),
        onTap: () {
          goToRoom();
        });
  }

  image() {
    return Container(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _decorationImage,
          fit: BoxFit.fill,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  name() {
    return FutureBuilder<String>(
      future: firebaseUtils.getUserName(widget.chatroom.participant),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text(
              'Error: ${snapshot.error}'); // Show error message if fetching fails
        } else {
          return Container(
            margin: EdgeInsets.only(left: 20),
              child: Text(
            snapshot.data ?? '',
            style: TextStyle(fontSize: 20),
          )); // Show the name if fetched successfully
        }
      },
    );
  }

  goToRoom() {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatroomScreen(room: widget.chatroom),
        ));
  }

  initialize() async {
    try {
      Uint8List? bytes =
          await firebaseUtils.getProfileImage(widget.chatroom.participant);
      if (bytes?.lengthInBytes != 0) {
        setState(() {
          _decorationImage = MemoryImage(bytes!);
        });
      } else {
        _decorationImage = const AssetImage("lib/assets/profile_default.png");
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }
}
