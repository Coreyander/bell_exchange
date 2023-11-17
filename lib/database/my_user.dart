///This class represents a User. User data is mapped from Object to Map and stored in Firebase. Firebase updates or changes to data are based on the userID (Doc)

import 'package:bell_exchange/Database/schedule_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyUser {
  String userID;
  String name;
  String role;
  String hubID;
  String perner;
  List<ScheduleEntry> schedule = [];
  Map<String, bool> flags = {'overnight': false, 'giving': false, 'taking': false};

  MyUser(this.userID, this.name, this.role, this.hubID, this.perner);

  Future<void> createUserInFirebase() async {
    CollectionReference users = FirebaseFirestore.instance.collection('user_database');

    Map<String, dynamic> dataObject = {
      'userID': userID,
      'name': name,
      'role': role,
      'hubID': hubID,
      'perner': perner,
      'schedule': schedule,
      'flags': flags
    };

    await users.doc(userID).set(dataObject);
        
  }

  changeUserInFirebase() {}
  deleteUserInFirebase() {}
}

