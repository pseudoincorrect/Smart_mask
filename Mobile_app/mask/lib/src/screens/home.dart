import 'package:flutter/material.dart';
import 'package:mask/src/widgets/db_control_buttons.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TestButtons"),
      ),
      body: Center(child: TestButtons()),
    );
  }
}
