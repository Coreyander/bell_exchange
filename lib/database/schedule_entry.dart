
///This class represents a day or night scheduled and the user associated with it.
///This class with an empty constructor can be used to access Firebase methods that
///manipulate or change the Data Structure. This consolidates all uses of the data struct
///to this file to make updates or changes to the parsing easier in the future.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../datetime_utils.dart';

class ScheduleEntry {
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
  Map<String, dynamic> toMap() {
    return {
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
    Map<String, dynamic> scheduleData = toMap();
    await scheduleMasterList.doc("$user${"-"}${DateTimeUtils().getMonthFromDateTime(day)}${"-"}${DateTimeUtils().getWeekdayFromDateTime(day)}${"-"}${DateTime.now().year}").set(scheduleData);
  }

  changeScheduleDayInFirebase() {}
  deleteScheduleDayInFirebase() {}

  List<ScheduleEntry> getScheduleMasterList(AsyncSnapshot<QuerySnapshot> snapshot) {
    List<ScheduleEntry> entryMasterList = snapshot.data!.docs.map((DocumentSnapshot doc) {
      Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
      return ScheduleEntry(docData['role'] ?? '',
          docData['location'] ?? '',
          docData['startTime'] ?? '',
          docData['endTime'] ?? '',
          docData['user'] ?? '',
          docData['flags'] ?? <String, dynamic> {},
          docData['day'] ?? DateTime.now(),
          docData['weekday'] ?? '');
    }).toList();
    return entryMasterList;
  }
}

class ScheduleFlags {
  bool overnight = false;
  bool overtime = false;
  bool covered = false;

  ScheduleFlags();

  Map<String, dynamic> toMap() {
    return {
      'overnight': overnight,
      'overtime': overtime,
      'covered': covered,
    };
  }

}

