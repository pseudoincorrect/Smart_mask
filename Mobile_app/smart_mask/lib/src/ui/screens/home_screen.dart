import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        sizedImage("assets/images/smart_mask_hardware.jpg", 250, 200),
        sizedImage("assets/images/smart_mask_altium.png", 250, 200),
        InkWell(
            child: Text(
              'Get all sources on Github !',
              style: TextStyle(fontSize: 20),
            ),
            onTap: () =>
                launch('https://github.com/pseudoincorrect/smart_mask')),
      ],
    );
  }
}

Widget sizedImage(String path, double width, double height) {
  return Image(
    image: new AssetImage(path),
    width: width,
    height: height,
    color: null,
    fit: BoxFit.scaleDown,
    alignment: Alignment.center,
  );
}
