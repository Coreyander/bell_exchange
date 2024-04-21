
///This class represents a day or night scheduled and the user associated with it.
///This class with an empty constructor can be used to access Firebase methods that
///manipulate or change the Data Structure. This consolidates all uses of the data struct
///to this file to make updates or changes to the parsing easier in the future.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../datetime_utils.dart';

class ScheduleEntry {
  String documentId = '';
  String role = '';
  String location = '';
  String startTime = '';
  String endTime = '';
  double hours = 0;
  String user = '';
  ScheduleFlags flags = ScheduleFlags();
  DateTime day = DateTime.now();
  String weekday = '';

  // Use to access Firebase methods
  ScheduleEntry.utils();

  // Object Data structure
  ScheduleEntry(
      this.documentId,
      this.role,
      this.location,
      this.startTime,
      this.endTime,
      this.user,
      this.flags,
      this.day,
      this.weekday,
      );

  //Firebase Data structure
  ///This takes the data of and object and adds it to a map suitable for parsing to Firebase
  Map<String, dynamic> parseToFirebaseDataStructure() {
    return {
      'documentId': documentId,
      'role': role,
      'location': location,
      'startTime': startTime,
      'endTime': endTime,
      'hours': hours,
      'user': user,
      'flags': flags.toMap(), // Convert ScheduleFlags to Map
      'day': Timestamp.fromDate(day), // Convert DateTime to Firestore Timestamp
      'weekday': weekday,
    };
  }

  ///Creating a schedule follows the syntax userID-Month-Day-Year and uses the Firestore set() method
  ///meaning a user should only be able to post 1 shift per day and reposting will override the previous
  ///shift posted for that day with the new time, role, location, etc..
  Future<void> createScheduleDayInFirebase() async {
    CollectionReference scheduleMasterList = FirebaseFirestore.instance.collection('schedule_master_list');
    Map<String, dynamic> scheduleData = parseToFirebaseDataStructure();
    await scheduleMasterList.doc(documentId).set(scheduleData);
  }

  changeScheduleDayInFirebase() {}
  deleteScheduleDayInFirebase(List<ScheduleEntry> entryMasterList) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    for(ScheduleEntry entry in entryMasterList) {
      if(entry.day.isBefore(DateTime.now())) {
        try {
          DocumentReference documentReference = firestore.collection('schedule_master_list').doc(entry.documentId);
          DocumentSnapshot documentSnapshot = await documentReference.get();
          if (documentSnapshot.exists) {
            await documentReference.delete();
            print('Document with ID $documentId deleted successfully.');
          } else {
            print('Document with ID $documentId does not exist.');
          }
        } catch (e) {
          print('Error deleting document: $e');
        }
      }
  }

  }

  ///Takes a schedule entry from Firebase and parses it to a data object ScheduleEntry
  List<ScheduleEntry> getScheduleMasterList(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ScheduleEntry> entryMasterList = snapshot.data!.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;

      return ScheduleEntry(
          docData['documentId'] ?? '',
          docData['role'] ?? '',
          docData['location'] ?? '',
          docData['startTime'] ?? '',
          docData['endTime'] ?? '',
          docData['user'] ?? '',
          ScheduleFlags.fromMap(docData['flags']), //Expecting a Map<String, dynamic>
          docData['day'].toDate() ?? DateTime.timestamp(), //Expecting a TimeStamp
          docData['weekday'] ?? '');
    }).toList();
    deleteScheduleDayInFirebase(entryMasterList);
    return entryMasterList;
  }
}

///To update the code for ScheduleFlags, it must be added in the class as a bool, in the toMap() function as
///a key/value pair (to parse to Firebase), and in the factory function (to parse back into a ScheduleEntry)
class ScheduleFlags {

  bool overnight = false;
  bool morning = false;
  bool evening = false;
  bool transfer = false;
  bool shuttle = false;
  bool greeter = false;

  ScheduleFlags();


  Map<String, dynamic> toMap() {
    return {
      'overnight': overnight,
      'morning': morning,
      'evening': evening,
      'transfer': transfer,
      'shuttle': shuttle,
      'greeter': greeter
    };
  }

  factory ScheduleFlags.fromMap(Map<String, dynamic> map) {
    ScheduleFlags schFlags = ScheduleFlags();
    schFlags.overnight = map['overnight'] ?? false;
    schFlags.morning = map['morning'] ?? false;
    schFlags.evening = map['evening'] ?? false;
    schFlags.transfer = map['transfer'] ?? false;
    schFlags.shuttle = map['shuttle'] ?? false;
    schFlags.greeter = map['greeter'] ?? false;
    return schFlags;
  }
}

