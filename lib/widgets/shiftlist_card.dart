import 'package:bell_exchange/firebase_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_utils.dart';
import '../database/messenger/chatroom.dart';
import '../database/schedule_entry.dart';
import '../datetime_utils.dart';
import '../screens/ChatroomScreen.dart';
import 'filter_iconlist.dart';

///A Card with stateful elements to be used in ExchangeScreen to show a clickable, interactive list element.

class ShiftlistCard extends StatefulWidget {
  const ShiftlistCard({super.key, required this.entry});
  final ScheduleEntry entry;


  @override
  ShiftlistCardState createState() => ShiftlistCardState();
}

class ShiftlistCardState extends State<ShiftlistCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
      setState(() {
        isExpanded = !isExpanded;
      });
    }, child: Card(
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: "${widget.entry.role} ${widget.entry.location}\n",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: "${widget.entry.weekday}, ${DateTimeUtils().getMonthFromDateTime(widget.entry.day)} ${widget.entry.day.day}${DateTimeUtils().getSuffixFromDateTime(widget.entry.day)}\n",
                        style: const TextStyle(fontSize: 24),
                      ),
                      TextSpan(
                        text: "${widget.entry.startTime} to ${widget.entry.endTime}",
                      ),
                    ],
                  ),
                ),
                Row(children: [loadFilterIcons(widget.entry)],),
                Visibility(visible: isExpanded,
                  child: Row(
                    children: [
                      // Add your buttons here
                      // Example:
                      ElevatedButton(
                        onPressed: _launchURLInApp,
                        child: Text('Take Shift'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          openChatroom();
                        },
                        child: Text('Message Shift Poster'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );

  }

  _launchURLInApp() async {
    final Uri url = Uri.parse('https://scheduleview.disney.com/trade');
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }

  loadFilterIcons(ScheduleEntry entryMasterList) {
    List<String> filterImages = [];
    bool value = false;
    if (entryMasterList.flags.transfer == true) {
      filterImages.add('lib/assets/transfers_icon.png' );
      value = true;
    }
    if (entryMasterList.flags.greeter == true) {
      filterImages.add('lib/assets/greeter_icon.png');
      value = true;
    }
    if (entryMasterList.flags.shuttle == true) {
      filterImages.add('lib/assets/shuttle_icon.png');
      value = true;
    }
    return IconList(icons: filterImages, visibility: value);
  }

  void openChatroom() {
    FirebaseAuth auth = FirebaseAuth.instance;
    FirebaseUtils firebaseUtils = FirebaseUtils();
    String currentUser = firebaseUtils.getCurrentUserID(auth);
    if(widget.entry.documentId != '' && currentUser != '') {
      String chatroomID = Chatroom.utils().generateRoomId(
          widget.entry.documentId, currentUser);
      Chatroom room = Chatroom(chatroomID,widget.entry.user,currentUser);
      Navigator.push(
          context,
          MaterialPageRoute(
          builder: (context) => ChatroomScreen(room: room),
    ));
    } else {
      AppUtils().toastie("Error retrieving Chatroom. Post may no longer exist.");
    }

  }
}