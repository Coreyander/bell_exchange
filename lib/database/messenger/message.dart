import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

///Message Schema:
///User ID
///Recipient's ID
///Time Stamp
///Payload


class Message {
    String userId = '';
    String recipientId = '';
    DateTime timeStamp = DateTime.now();
    String payload = '';

    Message.utils();
    Message(this.userId, this.recipientId, this.timeStamp, this.payload);

    //Firebase Data structure
    ///This takes the data of the object and adds it to a map suitable for parsing to Firebase
    Map<String, dynamic> parseToFirebaseDataStructure() {
      return {
        'userId': userId,
        'recipientId': recipientId,
        'timestamp': Timestamp.fromDate(timeStamp), //Firestore uses Timestamp for DateTime
        'payload': payload,
      };
    }

    List<Message> getMessageStream(AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.data == null) {
        return []; // Return an empty list if snapshot.data is null
      }
      List<Message> messageStream = snapshot.data!.docs.map((DocumentSnapshot doc) {
        Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
        return Message(
          docData['userId'] ?? '',
          docData['recipientId'] ?? '',
          docData['timestamp'].toDate() ?? DateTime.timestamp(),
          docData['payload'] ?? '',
        );
    }).toList();
      messageStream.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));
      return messageStream;
}}
