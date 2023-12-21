import 'package:bell_exchange/database/schedule_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../datetime_utils.dart';
import '../widgets/checkbox_panel.dart';

/// Move the controller variables and focus date into individual cards so that they all have their own data
/// You can potentially do this by creating custom card class to send the variables to.

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final List<bool> _isExpanded = [false];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Exchange'))),
      endDrawer: mySchedule(),
      body:
          Center(child: Column(children: <Widget>[filters(), exchangeFeed()])),
      backgroundColor: Theme.of(context).canvasColor,
      floatingActionButton: fab(),
    );
  }

  mySchedule() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Row(
              children: [
                ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    child: const Row(
                      children: [Icon(Icons.settings), Text("Settings")],
                    )),
              ],
            ),
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

  filters() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded[index] = isExpanded;
        });
      },
      children: [
        ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(title: Text('Filters'));
            },
            body: Column(children: [
              const CheckboxPanel(),
              ElevatedButton(
                  onPressed: () => setState(() {
                        _isExpanded[0] = false;
                        applyFilter();
                      }),
                  child: const Text('Apply'))
            ]),
            isExpanded: _isExpanded[0])
      ],
    );
  }

  exchangeFeed() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("/schedule_master_list")
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            List<ScheduleEntry> entryMasterList =
                ScheduleEntry.utils().getScheduleMasterList(snapshot);
            return Expanded(
              child: ListView.builder(
                  itemCount: entryMasterList.length,
                  itemBuilder: (context, index) {
                    return Card(
                      elevation: 5,
                      child: Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: RichText(
                            text: TextSpan(
                                text:
                                    "${entryMasterList[index].role}${" "}${entryMasterList[index].location}${"\n"}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "${entryMasterList[index].weekday}${", "}${DateTimeUtils().getMonthFromDateTime(entryMasterList[index].day)}${" "}${entryMasterList[index].day.day}${DateTimeUtils().getSuffixFromDateTime(entryMasterList[index].day)}${"\n"}",
                                      style: const TextStyle(fontSize: 24)),
                                  TextSpan(
                                      text:
                                          "${entryMasterList[index].startTime}  to  "
                                          "${entryMasterList[index].endTime}"),
                                ]),
                          )),
                    );
                  }),
            );
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
        MaterialPageRoute(builder: (context) => const FullFormCalender()));
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

  void applyFilter() {}
}

class FullFormCalender extends StatefulWidget {
  const FullFormCalender({super.key});
  @override
  State<StatefulWidget> createState() => _FullFormCalenderState();
}

class _FullFormCalenderState extends State<FullFormCalender> {
  ///Initializing the data to set the date to today on the calender
  List<DateTime?> _date = [
    DateTime.now(),
  ];
  TimeOfDay _start =
      TimeOfDay.fromDateTime(DateTime(1989, 2, 2, 9, 0, 0, 0, 0));
  TimeOfDay _end = TimeOfDay.fromDateTime(DateTime(1989, 2, 2, 17, 0, 0, 0, 0));

  ///Initialing a 'blank' schedule entry to be filled out by the form
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
          title: const Text('Add Schedule'),
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

  ///Create a calender. The original date should be set to the current date
  ///and is moved to the lambda value from setState when onValueChanged is triggered by the user.
  ///The day and weekday are updated accordingly for the Schedule Entry.
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

  ///Sets the Schedule Entry to have the data from the Start time and End time based
  ///on the ranges chosen by the user.
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

  shiftFlags() {}

  ///Creates a String representation of all the data for the Schedule Entry and displays it to the user.
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
        msg: 'Shift is Posting!',
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
