import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

///A Chatroom is an interface screen in which:
///1. The current authenticated user is the owner of the room (messages display on right)
///   The current user can be identified by their userID through Firebase auth
///2. The other participant is not the owner, but has messages including the owner's userID (messages display on the left)
///3. Messages are loaded by timestamp, for oldest to newest
///4. A Chatroom has a unique ID in the form of userID-participantId so that more than one chatroom with the same two people cannot be created
///To use Firebase calls, construct an Object with Chatroom.utils()
///To create a chatroom Object, construct an Object with Chatroom(String, String, String)
class Chatroom {
  String chatroomId = '';
  String owner = '';
  String participant = '';

  Chatroom.utils();
  Chatroom(this.chatroomId, this.owner, this.participant);

  //Firebase Data structure
  ///This takes the data of and object and adds it to a map suitable for parsing to Firebase
  Map<String, dynamic> parseToFirebaseDataStructure() {
    return {
      'chatroomId': chatroomId,
      'owner': owner,
      'participant': participant,
    };
  }

  ///Accepts all snapshots in the chatroom collection from Firebase and parses it to a List<Chatroom> Object Array
  List<Chatroom> getChatrooms(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<Chatroom> chatrooms = snapshot.data!.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      return Chatroom(
          docData['chatroomId'] ?? '',
          docData['owner'] ?? '',
          docData['participant'] ?? '',
      );
    }).toList();
    return chatrooms;
  }
}