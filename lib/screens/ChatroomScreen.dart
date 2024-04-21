import 'package:bell_exchange/firebase_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app_utils.dart';
import '../database/messenger/chatroom.dart';
import '../database/messenger/message.dart';

class ChatroomScreen extends StatefulWidget {
  const ChatroomScreen({super.key, required this.room});
  final Chatroom room;
  @override
  State<StatefulWidget> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  CollectionReference chatroomCollection =
      FirebaseFirestore.instance.collection('chatrooms');
  List<Message> messageStream = [];
  final TextEditingController _messageController = TextEditingController();
  dynamic _participantImage = AssetImage("lib/assets/profile_default.png");
  dynamic _ownerImage = AssetImage("lib/assets/profile_default.png");
  bool _roomLoading = true;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUtils firebaseUtils = FirebaseUtils();
  final GlobalKey _chatroomContainer = GlobalKey();
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: _roomLoading == true
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator()],
              )
            : Container(
                key: _chatroomContainer,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(6.0),
                child: Column(
                  children: <Widget>[
                    stream(),
                  ],
                ),
              ));
  }

  initialize() async {
    //Get the profile pictures of each party
    try {
      Uint8List? pbytes =
          await firebaseUtils.getProfileImage(widget.room.participant);
      if (pbytes?.lengthInBytes != 0) {
        _participantImage = MemoryImage(pbytes!);
      } else {
        _participantImage = const AssetImage("lib/assets/profile_default.png");
      }
    } catch (e) {
      if (kDebugMode) {
        print("No participant profile picture found");
      }
    }
    try {
      Uint8List? obytes =
          await firebaseUtils.getProfileImage(widget.room.owner);
      if (obytes?.lengthInBytes != 0) {
        _ownerImage = MemoryImage(obytes!);
      } else {
        _ownerImage = const AssetImage("lib/assets/profile_default.png");
      }
    } catch (e) {
      if (kDebugMode) {
        print("No participant profile picture found");
      }
    }
    //Creates a chatroom in Firebase if this is the first instance of it.
    try {
      DocumentSnapshot chatroomSnapshot =
          await chatroomCollection.doc(widget.room.chatroomId).get();
      if (!chatroomSnapshot.exists) {
        await chatroomCollection
            .doc(widget.room.chatroomId)
            .set(widget.room.parseToFirebaseDataStructure());
        print('Chatroom created.');
      }
    } catch (error) {
      AppUtils().toastie("Error opening Chatroom");
    }
    setState(() {
      _roomLoading = false;
    });
  }

  messageBar() {
    return Row(
      children: [
        SizedBox(
          height: 100,
          width: MediaQuery.of(context).size.width - 100,
          child: TextField(
            controller: _messageController,
          ),
        ),
        ElevatedButton(
            onPressed: () async {
              sendMessage();
            },
            child: const Text('Send'))
      ],
    );
  }

  sendMessage() async {
    print("sending message");
    Message newMessage = Message(firebaseUtils.getCurrentUserID(auth),
        widget.room.owner, DateTime.now(), _messageController.text);
    if (newMessage.payload != "") {
      try {
        print(widget.room.chatroomId);
        DocumentReference chatroomRef =
            chatroomCollection.doc(widget.room.chatroomId);
        DocumentSnapshot chatroomSnapshot = await chatroomRef.get();
        if (chatroomSnapshot.exists) {
          print("adding message to firebase");
          CollectionReference messagesCollection =
              chatroomRef.collection('messages');
          await messagesCollection
              .add(newMessage.parseToFirebaseDataStructure());
        } else {
          print("chat room did not exist");
        }
      } catch (error) {
        AppUtils().toastie(
            "Message not delivered. Check you Wifi Connection. \n If the problem persists, messages may have ended for this post.");
      }
    }
    _messageController.text = "";
  }

  participantImage() {
    return Container(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _participantImage,
          fit: BoxFit.fill,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  ownerImage() {
    return Container(
      height: 60.0,
      width: 60.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: _ownerImage,
          fit: BoxFit.fill,
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  ///This stream listens to the sub-collection 'messages' of the 'chatroom' collection in Firebase
  ///and sorts messages by either owner or participant based on the current user. The streams semantics
  ///can be found as a utility function of the Message class at lib/database/messenger
  stream() {
    double deviceHeight = MediaQuery.of(context).size.height;
    String? currentUser = auth.currentUser?.uid ?? '';
    return StreamBuilder(
        stream: chatroomCollection
            .doc(widget.room.chatroomId)
            .collection('messages')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          List<Message> messageStream =
              Message.utils().getMessageStream(snapshot);
          return Expanded(
              child: SingleChildScrollView(
            child: SizedBox(
              height: deviceHeight * 0.9,
              child: Column(
                children: [
                  Container(
                    height: deviceHeight * 0.7,
                    color: Colors.greenAccent,
                    child: ListView.builder(
                      itemCount: messageStream.length,
                      itemBuilder: (context, index) {
                        bool ifOwner =
                            messageStream[index].userId == currentUser;
                        return Row(
                            mainAxisAlignment: ifOwner
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              if (!ifOwner) Spacer(),
                              !ifOwner ? participantImage() : SizedBox(),
                              Flexible(
                                  flex: 14,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 14),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 22),
                                    decoration: BoxDecoration(
                                      color:
                                          ifOwner ? Colors.blue : Colors.grey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      messageStream[index].payload,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    ),
                                  )),
                              if (ifOwner) Spacer(),
                              ifOwner ? ownerImage() : SizedBox()
                            ]);
                      },
                    ),
                  ),
                  Expanded(
                    child: Container(

                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.only(left: 20, right: 8),
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextField(
                              controller: _messageController,
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                sendMessage();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color.fromARGB(
                                    255, 214, 225, 229),
                                shape: CircleBorder()
                              ),
                              child: const ImageIcon(AssetImage('lib/assets/send_message.png'), color: Colors.black,))
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
          // return SizedBox(
          //   height: MediaQuery.of(context).size.height,
          //   child: Column(
          //     children: [
          //       SizedBox(
          //         height: MediaQuery.of(context).size.height - 250,
          //         child: ListView.builder(
          //           itemCount: messageStream.length,
          //           itemBuilder: (context, index) {
          //             bool ifOwner = messageStream[index].userId == currentUser;
          //             return Row(
          //                 mainAxisAlignment: ifOwner
          //                     ? MainAxisAlignment.end
          //                     : MainAxisAlignment.start,
          //                 children: [
          //                   if (!ifOwner) Spacer(),
          //                   !ifOwner ? participantImage() : SizedBox(),
          //                   Flexible(
          //                       flex: 14,
          //                       child: Container(
          //                         padding: EdgeInsets.symmetric(
          //                             horizontal: 10, vertical: 14),
          //                         margin: EdgeInsets.symmetric(
          //                             horizontal: 8, vertical: 22),
          //                         decoration: BoxDecoration(
          //                           color: ifOwner ? Colors.blue : Colors.grey,
          //                           borderRadius: BorderRadius.circular(8),
          //                         ),
          //                         child: Text(
          //                           messageStream[index].payload,
          //                           style: TextStyle(
          //                               color: Colors.white, fontSize: 16),
          //                         ),
          //                       )),
          //                   if (ifOwner) Spacer(),
          //                   ifOwner ? ownerImage() : SizedBox()
          //                 ]);
          //           },
          //         ),
          //       ),
          //       Expanded(
          //           child: Row(
          //         children: [
          //           Container(
          //             child: Expanded(
          //               child: TextField(
          //                 controller: _messageController,
          //               ),
          //             ),
          //           ),
          //           ElevatedButton(
          //               onPressed: () async {
          //                 sendMessage();
          //               },
          //               child: const Text('Send'))
          //         ],
          //       )),
          //     ],
          //   ),
          // );
        });
  }
}
