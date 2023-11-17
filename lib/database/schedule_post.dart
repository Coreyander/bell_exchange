import 'package:bell_exchange/Database/schedule_entry.dart';

///This class is for the form to post a ScheduleDay.

/// This is currently a clone of the ScheduleEntry class until the message system is coded
/// REMOVE THIS COMMENT WHEN TODO IS COMPLETE!
///

class SchedulePost {
  int month;
  int date;
  int weekdayNumber;
  String weekday = '';
  String role = '';
  String location = '';

  //TODO: add messages to a SchedulePosted
  SchedulePost(this.month, this.date, this.weekdayNumber);
}

createSchedulePostInFirebase() {}
changeSchedulePostInFirebase() {}
deleteSchedulePostInFirebase() {}