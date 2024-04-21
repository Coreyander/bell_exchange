import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
      appBar: AppBar(),
      body: Column(
        children: [chatrooms()],
      ),
    );
  }

  chatrooms() {
    List<Chatroom> chatrooms = [];
    String currentUser = firebaseUtils.getCurrentUserID(auth);
    Stream<List<DocumentSnapshot<Object?>>> chatroomsStream(String currentUser) async* {
      yield await firebaseUtils.getChatrooms(currentUser);
    }
    Stream<List<DocumentSnapshot>> stream = chatroomsStream(currentUser);
    return Expanded(
      child: StreamBuilder(
          stream: stream,
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              try {
                chatrooms =
                Chatroom.utils().parseFromFirebaseChatrooms(snapshot.data!);
              } catch (e) {
                if (kDebugMode) {
                  print('no chatrooms exist for this user, or parsing from Firebase failed.');
                }
                chatrooms = [];
              }
              return ListView.builder(
                  itemCount: chatrooms.length,
                  itemBuilder: (context, index) {
                    return ChatroomCard(chatroom: chatrooms[index]);
                  });
            }
          }),
    );
  }

  initialize() {}
}
