import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ExchangeScreen extends StatefulWidget {
  const ExchangeScreen({super.key});

  @override
  State<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
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
      onPressed: fabToast,
      tooltip: 'Increment',
      child: const Icon(Icons.add_chart),
    );
  }

  fabToast() {
    Fluttertoast.showToast(
        msg: 'Make me do something!!!',
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT);
  }
}
