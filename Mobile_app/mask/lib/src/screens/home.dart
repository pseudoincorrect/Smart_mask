import 'package:flutter/material.dart';
import 'package:mask/src/widgets/navigation_buttons.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(child: Text("Home")),
//        NavigationButtons(),
      ],
    );
  }
}
