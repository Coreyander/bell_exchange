import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:time_range/time_range.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

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
      body: Center(
          child: ListView(children: <Widget>[
        //exchangeFeed()
      ])),
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
    // ListView.builder(
    //   itemCount: items.length, // Number of items in the list
    //   itemBuilder: (BuildContext context, int index) {
    //     return ListTile(
    //       title: Text(items[index]), // Get the data for the current index
    //     );
    //   },
    // )
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
        context, MaterialPageRoute(builder: (context) => FullFormCalender()));
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

class FullFormDateScroll extends StatefulWidget {
  const FullFormDateScroll({super.key});
  @override
  State<FullFormDateScroll> createState() => _FullFormDateScrollState();
}

class _FullFormDateScrollState extends State<FullFormDateScroll> {
  int shiftCards = 2;
  //@override
  List<EasyInfiniteDateTimelineController> controllers = [];
  List<DateTime> focusDate = [];
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() {
    controllers = List.generate(
        shiftCards, (index) => EasyInfiniteDateTimelineController());
    focusDate = List.generate(shiftCards, (index) => DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Schedule'), // Set your app title here
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: shiftCards,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Card(
                    child: scheduleItem(index),
                  ),
                );
              },
            ),
          ),
          buttonBar(),
        ],
      ),
    );
  }

  scheduleItem(int index) {
    return Column(
      children: [
        EasyInfiniteDateTimeLine(
          controller: controllers.elementAt(index),
          firstDate: DateTime(2023),
          focusDate: focusDate.elementAt(index),
          lastDate: DateTime(2023, 12, 31),
          onDateChange: (selectedDate) {
            setState(() {
              focusDate[index] = selectedDate;
            });
          }),
          TimeRange(
              timeBlock: 30,
              onRangeCompleted: (range) => setState(() => print(range)),
              firstTime: const TimeOfDay(hour: 00, minute: 00),
              lastTime: const TimeOfDay(hour: 24, minute: 00)),
      ],
    );
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
    Fluttertoast.showToast(
        msg:
            'Info: ${focusDate.elementAt(0)!.day} ${focusDate.elementAt(0)!.month} ${focusDate.elementAt(0)!.weekday}',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }

  addShift() {
    setState(() {
      shiftCards++;
      controllers.add(EasyInfiniteDateTimelineController());
      focusDate.add(DateTime.now());
    });
  }

  removeShift() {
    setState(() {
      if (shiftCards > 1) {
        shiftCards--;
        controllers.removeLast();
        focusDate.removeLast();
      }
    });
  }
}

class FullFormCalender extends StatefulWidget {
  const FullFormCalender({super.key});
  @override
  State<StatefulWidget> createState() => _FullFormCalenderState();
  
}

class _FullFormCalenderState extends State<FullFormCalender> {
  List<DateTime?> _dates = [
    DateTime.now(),
  ];
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
      body: Column(
        children: [
          calender(),
          timePicker(),
          shiftList(),
          buttonBar()
        ],
      ),
    );
  }

  initialize() {

  }

  calender() {
    return CalendarDatePicker2(
      config: CalendarDatePicker2Config(
        calendarType: CalendarDatePicker2Type.single
      ),
      value: _dates,
      onValueChanged: (dates) => _dates = dates,
    );
  }

  timePicker() {}

  shiftList() {}

  buttonBar() {}
}