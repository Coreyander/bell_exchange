///A column of checkboxes. Used for filter menus throughout the app.
///1. In ExchangeScreen

import 'package:bell_exchange/database/schedule_filters.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckboxPanel extends StatefulWidget {
  const CheckboxPanel({super.key});
  @override
  State<StatefulWidget> createState() => _CheckboxPanelState();
}

class _CheckboxPanelState extends State<CheckboxPanel> {
  Map<String, bool> checkboxValuesBP = ScheduleFiltersBellperson().asMap();
  Map<String, bool> checkboxValuesDS = ScheduleFiltersDispatcher().asMap();


  @override
  void initState() {
    loadCheckboxState(checkboxValuesDS);
    loadCheckboxState(checkboxValuesBP);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Expanded(child: Column(
        children: [
          bellpersonFilterColumn()
        ],
      ),)
        ,
        Expanded(child: Column(
          children: [
            dispatcherFilterColumn()
          ],
        ),)
      ],
    );
  }

  bellpersonFilterColumn() {
    Map<String, bool> filters = checkboxValuesBP;

    return Column(
      children: filters.keys.map((String filter) {
        return CheckboxListTile(
          title: Text(ScheduleFiltersBellperson().getText(filter)),
          value: filters[filter] ?? false,
          onChanged: (bool? isChecked) {
            if (isChecked != null) {
              setState(() {
                filters[filter] = isChecked;
                updateCheckboxState(filter, checkboxValuesBP[filter]!);
              });
            }
          },
        );
      }).toList(),
    );
  }

  dispatcherFilterColumn() {
    Map<String, bool> filters = checkboxValuesDS;

    return Column(
      children: filters.keys.map((filter) {
        return CheckboxListTile(
          title: Text(ScheduleFiltersDispatcher().getText(filter)),
          value: filters[filter] ?? false,
          onChanged: (bool? isChecked) {
            if (isChecked != null) {
              setState(() {
                filters[filter] = isChecked;
                updateCheckboxState(filter, checkboxValuesDS[filter]!);
              });
            }
          },
        );
      }).toList(),
    );
  }

  Future<void> loadCheckboxState(Map<String, bool> filters) async {
    // Sets the filter values to the ones in saved preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      for (var key in filters.keys) {
        if (prefs.getBool(key) != null) {
          filters[key] = prefs.getBool(key)!;
        }
      }
    });
  }

  Future<void> updateCheckboxState(String key, bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }
}
