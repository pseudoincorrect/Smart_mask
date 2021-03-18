//  Drop Button
//
//  Description:
//      Wrapper aroung DropdownButton widget used for instance to
//      Select a sensor

import 'package:flutter/material.dart';

class DropButton extends StatelessWidget {
  final String value;
  final void Function(String) onChanged;
  final List<String> items;

  const DropButton({Key key, this.value, this.onChanged, this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value.toUpperCase()),
        );
      }).toList(),
    );
  }
}
