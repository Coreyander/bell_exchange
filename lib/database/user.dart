///This class represents a User. User data is mapped from Object to Map and stored in Firebase. Firebase updates or changes to data are based on the userID (Doc)

import 'package:bell_exchange/Database/schedule_entry.dart';

class User {
  String userID;
  String name;
  String role;
  String hubID;
  int perner;
  List<ScheduleEntry> schedule;
  UserFlags flags;

  User(this.userID, this.name, this.role, this.hubID, this.perner,
      this.schedule, this.flags);
}

class UserFlags {
  bool overnight = false;
  bool giving;
  bool taking;

  UserFlags(this.overnight, this.giving, this.taking);
}

createUserInFirebase() {}
changeUserInFirebase() {}
deleteUserInFirebase() {}
