import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../database/messenger/chatroom.dart';
import '../widgets/chatroom_card.dart';

///Displays all chatrooms for the current user

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<StatefulWidget> createState() => _MessagesScreenState();

}

class _MessagesScreenState extends State<MessagesScreen> {
FirebaseUtils firebaseUtils = FirebaseUtils();
FirebaseAuth auth = FirebaseAuth.instance;

@override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'), // Set your app title here
      ),
      body: Column(
        children: [
            chatrooms()
        ],
      ),
    );
  }

  
  chatrooms() {
    String currentUser = firebaseUtils.getCurrentUserID(auth);
    CollectionReference chatrooms = firebaseUtils.getChatroomsForUser(currentUser);
    StreamBuilder(stream: chatrooms.snapshots(), builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        List<Chatroom> chatrooms = Chatroom.utils().getChatrooms(snapshot);
        return ListView.builder(itemCount: chatrooms.length, itemBuilder: (context, index) {
          return ChatroomCard(chatroom: chatrooms[index]);
        });
      }
    });
  }
  initialize() {

  }

}