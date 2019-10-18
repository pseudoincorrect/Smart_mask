import 'package:flutter/material.dart';
import 'package:mask/src/widgets/navigation_buttons.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TestButtons"),
      ),
      body: Column(
        children: <Widget>[
          Text("HOME"),
          NavigationButtons(),
        ],
      ),
    );
  }
}
