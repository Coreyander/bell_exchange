import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';

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
      body: Center(child: ListView(children: <Widget>[
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
    Navigator.push(context, MaterialPageRoute(builder: (context) => FullForm()));
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

class FullForm extends StatefulWidget {
  const FullForm({super.key});
  @override
  State<FullForm> createState() => _FullFormState();
}

class _FullFormState extends State<FullForm> {

  final EasyInfiniteDateTimelineController _controller =
  EasyInfiniteDateTimelineController();
  DateTime? _focusDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Full Screen Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            easyInfiniteDateTimeLine(),
            buttonBar(),
          ],
        ),
      ),
    );
  }

  easyInfiniteDateTimeLine() {
    return EasyInfiniteDateTimeLine(
      controller: _controller,
      firstDate: DateTime(2023),
      focusDate: _focusDate,
      lastDate: DateTime(2023, 12, 31),
      onDateChange: (selectedDate) {
        setState(() {
          _focusDate = selectedDate;
        });
      },
    );
  }

  buttonBar() {
    return ButtonBar(children: [
      ElevatedButton(onPressed: () => postShift(), child: const Text('Post Shift'))
    ],);
  }

  postShift() {

    Fluttertoast.showToast(
        msg: 'Info: ${_focusDate!.day} ${_focusDate!.month} ${_focusDate!.weekday}',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }
}
