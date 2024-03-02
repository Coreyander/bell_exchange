import 'package:bell_exchange/database/my_user.dart';
import 'package:bell_exchange/database/schedule_entry.dart';
import 'package:bell_exchange/firebase_utils.dart';
import 'package:bell_exchange/widgets/shiftlist_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:time_range/time_range.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../app_utils.dart';
import '../datetime_utils.dart';
import '../widgets/checkbox_panel.dart';
import '../widgets/location_radio_panel.dart';
import '../widgets/radio_panel.dart';

/// Move the controller variables and focus date into individual cards so that they all have their own data
/// You can potentially do this by creating custom card class to send the variables to.

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final List<bool> _isExpanded = [false];
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUtils utils = FirebaseUtils();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Exchange'))),
      endDrawer: exchangeDrawer(),
      body: Center(
        child: Column(children: <Widget>[filters(), exchangeFeed()]),
      ),
      backgroundColor: Theme.of(context).canvasColor,
      floatingActionButton: fab(),
    );
  }

  exchangeDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              children: [
                  Icon(Icons.person_2_rounded),
                FutureBuilder<String>(
                  future: utils.getCurrentUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      String userName = snapshot.data!;
                      return Text(userName);
                    }
                  },
                ),
              ],
            ),
          ),
          ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Row(
                children: [Icon(Icons.settings), Text("Settings")],
              )),
          ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Row(
                children: [Icon(Icons.mail_outline), Text("Messages")],
              )),
          ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/settings'),
              child: const Row(
                children: [Icon(Icons.photo_album_rounded), Text("My Profile")],
              )),
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
              child: RefreshIndicator(
            onRefresh: () async {
              entryMasterList = ScheduleEntry.utils().getScheduleMasterList(snapshot);
              return Future.delayed(const Duration(seconds: 1));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  top: 15.0, bottom: 90.0, left: 5.0, right: 5.0),
              itemCount: entryMasterList.length,
              itemBuilder: (context, index) {
                return ShiftlistCard(entry: entryMasterList[index]);
              },
            ),
          ));
        }
      },
    );
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
}

class FullFormCalender extends StatefulWidget {
  const FullFormCalender({super.key});
  @override
  State<StatefulWidget> createState() => _FullFormCalenderState();
}

class _FullFormCalenderState extends State<FullFormCalender> {
  final List<bool> _isExpanded = [false, false];

  ///Initializing the data to set the date to today on the calender
  List<DateTime?> _date = [
    DateTime.now(),
  ];
  TimeOfDay _start =
      TimeOfDay.fromDateTime(DateTime(1989, 2, 2, 9, 0, 0, 0, 0));
  TimeOfDay _end = TimeOfDay.fromDateTime(DateTime(1989, 2, 2, 17, 0, 0, 0, 0));

  ///Initialing a 'blank' schedule entry to be filled out by the form
  /// Initial role must match the first radio button in role selection (Currently: Dispatcher)
  ScheduleEntry myScheduleEntry = ScheduleEntry(
      "",
      "",
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
              children: [
                calender(),
                timePicker(),
                shiftFlags(),
                shiftList(),
                buttonBar()
              ],
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

  shiftFlags() {
    Map<String, dynamic> flagMap = myScheduleEntry.flags.toMap();
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _isExpanded[index] = isExpanded;
        });
      },
      children: [
        ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(title: Text('Role'));
            },
            body: Column(children: [
              RadioPanel(onRoleSelected: (String role) {
                setState(() {
                  myScheduleEntry.role = role;
                });
              }, onFlagSelected: (Map<String, bool> flag) {
                setState(() {
                  flagMap.forEach((key, value) {
                    if (flag.containsKey('shuttle')) {
                      myScheduleEntry.flags.shuttle = flag.values.first;
                    } else if (flag.containsKey('greeter')) {
                      myScheduleEntry.flags.greeter = flag.values.first;
                    } else if (flag.containsKey('transfer')) {
                      myScheduleEntry.flags.transfer = flag.values.first;
                    }
                  });
                });
              }),
              ElevatedButton(
                  onPressed: () => setState(() {
                        _isExpanded[0] = false;
                      }),
                  child: const Text('Apply'))
            ]),
            isExpanded: _isExpanded[0]),
        ExpansionPanel(
            headerBuilder: (BuildContext context, bool isExpanded) {
              return const ListTile(title: Text('Location'));
            },
            body: Column(children: [
              LocationRadioPanel(
                onLocationSelect: (String location) {
                  myScheduleEntry.location = location;
                },
              ),
              ElevatedButton(
                  onPressed: () => setState(() {
                        _isExpanded[1] = false;
                      }),
                  child: const Text('Apply'))
            ]),
            isExpanded: _isExpanded[1])
      ],
    );
  }

  ///Creates a String representation of all the data for the Schedule Entry and displays it to the user.
  shiftList() {
    return Text("${"My Shift\n"}"
        "${myScheduleEntry.role}${" "}${myScheduleEntry.location}${"\n"}"
        "${myScheduleEntry.weekday}${", "}${DateTimeUtils().getMonthFromDateTime(_date[0]!)}${" "}${myScheduleEntry.day.day}${DateTimeUtils().getSuffixFromDateTime(_date[0]!)}${"\n"}"
        "${_start.hour.toString().padLeft(2, "0")}${":"}${_start.minute.toString().padLeft(2, "0")}  to  "
        "${_end.hour.toString().padLeft(2, "0")}${":"}${_end.minute.toString().padLeft(2, "0")}${"\n"}"
        "${"Transfers? "}${myScheduleEntry.flags.transfer}${"\n"}"
        "${"Greeter? "}${myScheduleEntry.flags.greeter}${"\n"}"
        "${"Shuttles? "}${myScheduleEntry.flags.shuttle}${"\n"}");
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
    if (myScheduleEntry.role == "") {
      AppUtils().toastie("Please Select a Role!");
    } else if (myScheduleEntry.location == "") {
      AppUtils().toastie("Please Select a Location!");
    } else {
      if (myScheduleEntry.user == "") {
        AppUtils().toastie("Unable to post shift, user not found.");
      } else {
        myScheduleEntry.documentId =
            "${myScheduleEntry.user.toString()}${"-"}${DateTimeUtils().getMonthFromDateTime(myScheduleEntry.day)}${"-"}${DateTimeUtils().getWeekdayFromDateTime(myScheduleEntry.day)}${"-"}${DateTime.now().year}";
        myScheduleEntry.createScheduleDayInFirebase();
        AppUtils().toastie(myScheduleEntry.documentId.toString());
        AppUtils().toastie('Shift is Posting!');
      }
    }
  }

  addShift() {
    setState(() {});
  }

  removeShift() {
    setState(() {});
  }
}
