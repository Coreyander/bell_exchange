import 'package:flutter/material.dart';

class IconList extends StatelessWidget {
  const IconList({super.key, required this.icons, required this.visibility});
  final List<String> icons;
  final bool visibility;

  @override
  Widget build(BuildContext context) {
    return Visibility(visible: visibility,
        child: SizedBox(
      height: 75,
      width: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: icons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(icons[index], height: 50, width: 50,),
          );
        },
      ),
    ));
  }
}
