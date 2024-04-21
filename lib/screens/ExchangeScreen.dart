import 'dart:async';

import 'package:bell_exchange/database/schedule_entry.dart';
import 'package:bell_exchange/firebase_utils.dart';
import 'package:bell_exchange/widgets/shiftlist_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import '../app_utils.dart';
import '../datetime_utils.dart';
import '../widgets/checkbox_panel.dart';
import '../widgets/location_radio_panel.dart';
import '../widgets/role_radio_panel.dart';

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
              onPressed: () => Navigator.pushNamed(context, '/messages'),
              child: const Row(
                children: [Icon(Icons.mail_outline), Text("Messages")],
              )),
          ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
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
              entryMasterList =
                  ScheduleEntry.utils().getScheduleMasterList(snapshot);
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
  final List<bool> _isRoleExpanded = [false];
  final List<bool> _isLocationExpanded = [false];
  final StreamController<String> _startTimeTextController =
      StreamController<String>();
  final StreamController<String> _endTimeTextController = StreamController<String>();
  final StreamController<String> _roleDisplayTextController = StreamController<String>();
  final StreamController<String> _locationDisplayTextController = StreamController<String>();
  final ScrollController _scrollController = ScrollController();


  final GlobalKey _chooseLocationEnd = GlobalKey(); //key for a Container widget directly after chooseLocation() for calculating a ScrollController Offset

  ///Initializing the data to set the date to today on the calender
  List<DateTime?> _date = [
    DateTime.now(),
  ];

  ///Initialing a 'blank' schedule entry to be filled out by the form
  /// Initial role must match the first radio button in role selection (Currently: Dispatcher)
  ScheduleEntry myScheduleEntry = ScheduleEntry(
      "",
      "",
      "",
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
        appBar: AppBar(),
        body: SingleChildScrollView(
          controller: _scrollController,
          child:
            Column(
              children: [
                calender(),
                Container(padding: EdgeInsets.all(6)),
                chooseRole(),
                Container(padding: EdgeInsets.all(6)),
                chooseLocation(),
                Container(key: _chooseLocationEnd, padding: EdgeInsets.all(6)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async => selectStartTime(),
                        child: StreamBuilder(
                            stream: _startTimeTextController.stream,
                            builder: (context, snapshot) {
                              return startTimeDisplay(
                                  myScheduleEntry.startTime);
                            }))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () async => selectEndTime(),
                        child: StreamBuilder(
                            stream: _endTimeTextController.stream,
                            builder: (context, snapshot) {
                              return endTimeDisplay(myScheduleEntry.endTime);
                            }))
                  ],
                ),
                //shiftList(),
                buttonBar()
              ],
            ),
        ));
  }

  initialize() {}

  ///Create a calender. The original date should be set to the current date
  ///and is moved to the lambda value from setState when onValueChanged is triggered by the user.
  ///The day and weekday are updated accordingly for the Schedule Entry.
  calender() {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xDFD1E3E1),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: CalendarDatePicker2(
          config: CalendarDatePicker2Config(
              calendarType: CalendarDatePicker2Type.single),
          value: _date,
          onValueChanged: (date) => setState(() {
            _date = date;
            myScheduleEntry.day = _date[0]!;
            myScheduleEntry.weekday =
                DateTimeUtils().getWeekdayFromDateTime(_date[0]!);
          }),
        ),
      );
  }

  chooseRole() {
    Map<String, dynamic> flagMap = myScheduleEntry.flags.toMap();
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _isRoleExpanded[index] = isExpanded;
          });
        },
        children: [
          ExpansionPanel(
              backgroundColor: const Color(0xffdcfcef),
            canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(title: StreamBuilder(
                    stream: _roleDisplayTextController.stream,
                    builder: (context, snapshot) {
                      return roleDisplay();
                    }));
              },
              body: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xfff4fffb),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(children: [
                  RadioPanel(onRoleSelected: (String role) {
                    setState(() {
                      myScheduleEntry.role = role;
                      _roleDisplayTextController.add(myScheduleEntry.role);
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
                ]),
              ),
              isExpanded: _isRoleExpanded[0]),
        ],
      ),
    );
  }

  chooseLocation() {
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _isLocationExpanded[index] = isExpanded;
              });
              if (isExpanded) {
                RenderBox? renderObject = _chooseLocationEnd.currentContext?.findRenderObject() as RenderBox?;
                double? offset = renderObject?.localToGlobal(Offset.zero).dy;
                AppUtils().toastie(offset.toString());
                _scrollController.animateTo(
                  800,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease,
                );
              }
            },
            children: [
              ExpansionPanel(
                  backgroundColor: const Color(0xffdcfcef),
                canTapOnHeader: true,
                  headerBuilder: (BuildContext context, bool isExpanded) {
                    return ListTile(title: StreamBuilder(
                        stream: _locationDisplayTextController.stream,
                        builder: (context, snapshot) {
                          return locationDisplay();
                        }));
                  },
                  body: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xfff4fffb),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(children: [
                      LocationRadioPanel(
                        onLocationSelect: (String location) {
                          myScheduleEntry.location = location;
                          setState(() {
                            _isLocationExpanded[0] = false; // Close the ExpansionPanel
                          });
                        },
                      ),
                    ]),
                  ),
                  isExpanded: _isLocationExpanded[0])
            ]));
  }

  ///Creates a String representation of all the data for the Schedule Entry and displays it to the user.
  shiftList() {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
                  "${myScheduleEntry.role}${" "}${myScheduleEntry.location}${"\n"}"
                  "${myScheduleEntry.weekday}${", "}${DateTimeUtils().getMonthFromDateTime(_date[0]!)}${" "}${myScheduleEntry.day.day}${DateTimeUtils().getSuffixFromDateTime(_date[0]!)}${"\n"}"
                  "${myScheduleEntry.startTime}  to  "
                  "${myScheduleEntry.endTime}"
                  "${"Transfers? "}${myScheduleEntry.flags.transfer}${"\n"}"
                  "${"Greeter? "}${myScheduleEntry.flags.greeter}${"\n"}"
                  "${"Shuttles? "}${myScheduleEntry.flags.shuttle}${"\n"}",
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }


  buttonBar() {
    return ButtonBar(
      alignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 120,
          height: 48,
          child: ElevatedButton(
            onPressed: () => postShift(),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 22), // Adjust text size
            ),
            child: const Text('Post'),
          ),
        ),
      ],
    );
  }

  postShift() async {
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
        await Future.delayed(const Duration(seconds: 3));
        if(mounted) {
          Navigator.pop(context);
          Navigator.push(
            //FullFormCalender()
              context,
              MaterialPageRoute(builder: (context) => const FullFormCalender()));
        }
      }
      AppUtils().toastie('Post Complete!');
    }
  }

  selectStartTime() async {
    var selectedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog(
          initialTime: TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.input,
        );
      },
    );
    if (selectedTime != null) {
      String startTime =
          "${selectedTime.hour.toString().padLeft(2, "0")}${":"}${selectedTime.minute.toString().padLeft(2, "0")}";
      myScheduleEntry.startTime = startTime;
      _startTimeTextController.add(myScheduleEntry.startTime);
    } else {
      if (kDebugMode) {
        print('No time selected or dialog dismissed');
      }
    }
  }

  selectEndTime() async {
    var selectedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return TimePickerDialog(
          initialTime: TimeOfDay.now(),
          initialEntryMode: TimePickerEntryMode.input,
        );
      },
    );
    if (selectedTime != null) {
      String endTime = "${selectedTime.hour.toString().padLeft(2, "0")}${":"}${selectedTime.minute.toString().padLeft(2, "0")}";
      myScheduleEntry.endTime = endTime;
      _endTimeTextController.add(myScheduleEntry.endTime);
    }
  }

  startTimeDisplay(String time) {
    if (time == "") {
      time = "Select Start Time";
      return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topLeft,
          child: Text(time,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 22)));
    }
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.topLeft,
        child: Text("Start Time: $time",
            textAlign: TextAlign.center, style: TextStyle(fontSize: 22)));
  }

  endTimeDisplay(String time) {
    if (time == "") {
      time = "Select End Time";
      return Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.topLeft,
          child: Text(time,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 22)));
    }
    return Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        alignment: Alignment.topLeft,
        child: Text("End Time: $time",
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 22)));
  }

  roleDisplay() {
    String roleDisplay = myScheduleEntry.role;
    if(roleDisplay == "") {
      return const Text("Role");
    }
    return Text("Role           |  ${myScheduleEntry.role}",);
  }

  locationDisplay() {
    String locationDisplay = myScheduleEntry.location;
    if(locationDisplay == "") {
      return const Text("Location");
    }
    return Text("Location    |  ${myScheduleEntry.location}",);
  }
}
