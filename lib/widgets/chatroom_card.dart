import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../database/messenger/chatroom.dart';

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
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(child: Card(child: Column(
      children: [
Row(children: [
  //image(),
  name()
],)
      ],
    )), onTap: () {openChatroom();});
  }

image() {
    //TODO: Implement user images to load here
}
  name() async {
    String participantId = widget.chatroom.participant;
    String name = await firebaseUtils.getUserName(participantId);
  }
  openChatroom() {
    String userId = firebaseUtils.getCurrentUserID(auth);
    CollectionReference chatrooms = firebaseUtils.getChatroomsForUser(userId);
    //TODO: get the current chatroom associated with this card from the collection
  }
  initialize() {}
}
