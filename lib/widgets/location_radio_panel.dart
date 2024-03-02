import 'package:flutter/material.dart';

import '../app_utils.dart';

class LocationRadioPanel extends StatefulWidget {
  const LocationRadioPanel({super.key,required this.onLocationSelect});
  final void Function(String) onLocationSelect;
  @override
  State<StatefulWidget> createState() => _LocationRadioPanelState();
}

Map<String, String> radioValue = {
  'CS': 'Coronado Springs',
  'RIR': 'Riviera',
  'JH': 'Jambo House',
  'KV': 'Kidani Village',
  'SSR': 'Saratoga Springs',
  'GF': 'Grand Floridian',
  'FQ': 'French Quarter',
  'RS': 'Riverside',
  'OKW': 'Old Key West',
  'PY': 'Polynesian',
  'CBR': 'Caribbean'
};

class _LocationRadioPanelState extends State<LocationRadioPanel> {
  String currentValue = "";

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: radioValue.length,
            itemBuilder: (context, index) {
              var entry = radioValue.entries.elementAt(index);
              var key = entry.key;
              var value = entry.value;

              return RadioListTile(
                title: Text(value),
                value: key,
                groupValue: currentValue,
                onChanged: (selectedValue) {
                  setState(() {
                    currentValue = selectedValue.toString();
                    widget.onLocationSelect(key);
                    AppUtils().toastie("DEBUG: Location key changed to $key");
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
