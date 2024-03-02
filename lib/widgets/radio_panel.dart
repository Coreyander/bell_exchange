import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../app_utils.dart';


///Radio Panel for the ExchangeScreen schedule entry form
class RadioPanel extends StatefulWidget {
  ///key & requirements
  const RadioPanel({super.key, required this.onRoleSelected, required this.onFlagSelected});
  ///callbacks
  final void Function(String) onRoleSelected;
  final void Function(Map<String, bool>) onFlagSelected;
  ///statefulness
  @override
  State<StatefulWidget> createState() => _RadioPanelState();
}

List<String> radioValue = ['Dispatcher', 'Bellperson'];

class _RadioPanelState extends State<RadioPanel> {
  List<bool> checkboxes = [false, false, false];
  bool filterVisible = true;
  String currentValue = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile(title: const Text ('Dispatcher'), value: radioValue[0], groupValue: currentValue, onChanged: (value) {
          setState(() {
            currentValue = value.toString();
            widget.onRoleSelected(currentValue);
            filterVisible = true;
          });
        }),
        Visibility(visible: filterVisible, child: Column(children: [
          CheckboxListTile(title: const Text('shuttles'), value: checkboxes[0], onChanged: (bool? value) {
            setState(() {
              checkboxes[0] = value!;
              if (value == true) {
                addFlag('shuttle');
                AppUtils().toastie("shuttles true");
              }
              else if (value == false){
                removeFlag('shuttle');
                AppUtils().toastie("shuttles false");
              }
            });
          }),
          CheckboxListTile(title: const Text('transfer'), value: checkboxes[1], onChanged: (bool? value) {
            setState(() {
              checkboxes[1] = value!;
              if (value == true) {
                addFlag('transfer');
              }
              else if (value == false) {
                removeFlag('transfer');
              }
            });
          }),
          CheckboxListTile(title: const Text('greeter'), value: checkboxes[2], onChanged: (bool? value) {
            setState(() {
              checkboxes[2] = value!;
              if (value == true) {
                addFlag('greeter');
              }
              else if (value == false) {
                removeFlag('greeter');
              }
            });
          }),
        ],)),
        RadioListTile(title: const Text ('Bellperson'), value: radioValue[1], groupValue: currentValue, onChanged: (value) {
          setState(() {
            currentValue = value.toString();
            widget.onRoleSelected(currentValue);
            filterVisible = false;
          });
        }),
      ]
    );
  }

  void addFlag(String flag) {
    Map<String, bool> add = {flag:true};
    widget.onFlagSelected(add);
  }

  void removeFlag(String flag) {
    Map<String, bool> remove = {flag:false};
    widget.onFlagSelected(remove);
  }

}