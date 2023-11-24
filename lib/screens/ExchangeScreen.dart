import 'package:bell_exchange/database/schedule_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:time_range/time_range.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

import '../datetime_utils.dart';

/// Move the controller variables and focus date into individual cards so that they all have their own data
/// You can potentially do this by creating custom card class to send the variables to.

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Exchange'))),
      endDrawer: mySchedule(),
      body: Center(child: ListView(children: <Widget>[exchangeFeed()])),
      backgroundColor: Theme.of(context).canvasColor,
      floatingActionButton: fab(),
    );
  }

  mySchedule() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text(
                'This Drawer allows at a glance view of schedule and messages'),
          ),
          ExpansionTile(
            title: const Text('Messages'),
            children: <Widget>[
              ListTile(
                title: Text(""),
                onTap: () {
                  // Handle subitem 1 tap
                },
              ),
              ListTile(
                title: const Text('Subitem 2'),
                onTap: () {
                  // Handle subitem 2 tap
                },
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('My Schedule'),
            children: <Widget>[
              for (var i in Iterable.generate(14))
                ExpansionTile(
                  title: Text(
                      '${getDays().elementAt(i)} ${getDates().elementAt(i)}'),
                  initiallyExpanded: i == 0,
                  children: <Widget>[
                    ListTile(
                        title: const Text('Add +'),
                        onTap: () {
                          // Handle subitem 2 tap
                        }),
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }

  exchangeFeed() {
    return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection("/schedule_master_list")
            .get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<ScheduleEntry> entryMasterList = ScheduleEntry.utils().getScheduleMasterList(snapshot);
            return ListView.builder(itemCount: entryMasterList.length,itemBuilder: (context, index) {
              return Card(
      //TODO: Create card of schedule data
              );
            });
          }

        });
  }

  fab() {
    return FloatingActionButton(
      elevation: 0,
      onPressed: () => fabOnPressed(),
      tooltip: 'Increment',
      child: const Icon(Icons.add_chart),
    );
  }

  fabOnPressed() {
    Navigator.push(
        //FullFormCalender()
        context,
        MaterialPageRoute(builder: (context) => FullFormCalender()));
    Fluttertoast.showToast(
        msg: 'Make me do something!!!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  List<String> getDates() {
    List<String> dates = [];
    var today = DateTime.now();

    for (var i = 0; i < 14; i++) {
      var nextDate = today.add(Duration(days: i));
      var formattedDate = DateFormat('yyyy-MM-dd').format(nextDate);
      dates.add(formattedDate);
    }

    return dates;
  }

  List<String> getDays() {
    List<String> days = [];
    var today = DateTime.now();

    for (var i = 0; i < 14; i++) {
      var nextDay = today.add(Duration(days: i));
      var formattedDay = DateFormat('EEEE').format(nextDay);
      days.add(formattedDay);
    }

    return days;
  }
}

class FullFormCalender extends StatefulWidget {
  const FullFormCalender({super.key});
  @override
  State<StatefulWidget> createState() => _FullFormCalenderState();
}

class _FullFormCalenderState extends State<FullFormCalender> {
  List<DateTime?> _date = [
    DateTime.now(),
  ];
  TimeOfDay _start =
      TimeOfDay.fromDateTime(DateTime(1989, 2, 2, 9, 0, 0, 0, 0));
  TimeOfDay _end = TimeOfDay.fromDateTime(DateTime(1989, 2, 2, 17, 0, 0, 0, 0));
  ScheduleEntry myScheduleEntry = ScheduleEntry(
      "Bellperson",
      "CS",
      "",
      "",
      FirebaseAuth.instance.currentUser!.uid,
      ScheduleFlags(),
      DateTime.now(),
      DateTimeUtils().getWeekdayFromDateTime(DateTime.now()));
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Schedule'), // Set your app title here
        ),
        body: ListView(
          children: [
            Column(
              children: [calender(), timePicker(), shiftList(), buttonBar()],
            ),
          ],
        ));
  }

  initialize() {}

  calender() {
    return CalendarDatePicker2(
      config: CalendarDatePicker2Config(
          calendarType: CalendarDatePicker2Type.single),
      value: _date,
      onValueChanged: (date) => setState(() {
        _date = date;
        myScheduleEntry.day = _date[0]!;
        myScheduleEntry.weekday =
            DateTimeUtils().getWeekdayFromDateTime(_date[0]!);
      }),
    );
  }

  timePicker() {
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            "Start Time",
            textScaleFactor: 1.2,
          ),
          TimeRange(
              timeStep: 15,
              timeBlock: 15,
              activeTextStyle: TextStyle(color: Colors.white),
              onRangeCompleted: (range) => setState(() {
                    _start = range!.start;
                    _end = range.end;
                    myScheduleEntry.startTime =
                        "${_start.hour.toString().padLeft(2, "0")}${":"}${_start.minute.toString().padLeft(2, "0")}";
                    myScheduleEntry.endTime =
                        "${_end.hour.toString().padLeft(2, "0")}${":"}${_end.minute.toString().padLeft(2, "0")}";
                  }),
              firstTime: const TimeOfDay(hour: 00, minute: 00),
              lastTime: const TimeOfDay(hour: 24, minute: 00)),
          const Text(
            "End Time",
            textScaleFactor: 1.2,
          )
        ]));
  }

  shiftList() {
    return Text("${"My Shift\n"}"
        "${myScheduleEntry.role}${" "}${myScheduleEntry.location}${"\n"}"
        "${myScheduleEntry.weekday}${", "}${DateTimeUtils().getMonthFromDateTime(_date[0]!)}${" "}${myScheduleEntry.day.day}${DateTimeUtils().getSuffixFromDateTime(_date[0]!)}${"\n"}"
        "${_start.hour.toString().padLeft(2, "0")}${":"}${_start.minute.toString().padLeft(2, "0")}  to  "
        "${_end.hour.toString().padLeft(2, "0")}${":"}${_end.minute.toString().padLeft(2, "0")}");
  }

  buttonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(onPressed: () => addShift(), child: const Text('+')),
        ElevatedButton(onPressed: () => removeShift(), child: const Text('-')),
        ElevatedButton(
            onPressed: () => postShift(), child: const Text('Post Shifts')),
      ],
    );
  }

  postShift() {
    myScheduleEntry.createScheduleDayInFirebase();
    Fluttertoast.showToast(
        msg: 'Post a Shift Here!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  addShift() {
    setState(() {});
  }

  removeShift() {
    setState(() {});
  }
}
