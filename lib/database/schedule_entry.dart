import 'my_user.dart';

///This class represents a day or night scheduled and the user associated with it.

enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
  tomorrow
}

class ScheduleEntry {
  String role;
  String location;
  Day day;
  Day endDay = Day.tomorrow;
  double startTime;
  double endTime;
  double hours = 0;
  MyUser user;
  ScheduleFlags flags;

  //Day shift
  ScheduleEntry(this.role, this.location, this.day, this.startTime,
      this.endTime, this.user, this.flags) {
    //Only supporting Military Time
    hours = endTime - startTime;

    //Night shift
    if (flags.overnight == true) {
      switch (day) {
        case Day.monday:
          endDay = Day.tuesday;
          break;
        case Day.tuesday:
          endDay = Day.wednesday;
          break;
        case Day.wednesday:
          endDay = Day.thursday;
          break;
        case Day.thursday:
          endDay = Day.friday;
          break;
        case Day.friday:
          endDay = Day.saturday;
          break;
        case Day.saturday:
          endDay = Day.sunday;
          break;
        case Day.sunday:
          endDay = Day.monday;
          break;
        case Day.tomorrow:
          /**
          Day.tomorrow is the "null" initializer for endDay so the UI still has something to display
          (example: a day shift has been flagged for overnight AFTER being posted as a day shift)
          however day will never equal Day.tomorrow and this case should never execute
          **/
          break;
      }
    }
  }
}

class ScheduleFlags {
  bool overnight;
  bool overtime;
  bool covered;
  ScheduleFlags(this.overnight, this.overtime, this.covered);
}

createScheduleDayInFirebase() {}
changeScheduleDayInFirebase() {}
deleteScheduleDayInFirebase() {}
