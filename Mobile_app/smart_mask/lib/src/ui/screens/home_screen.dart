import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Card(
            child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: sizedImage("assets/images/smart_mask_hardware.jpg", 250, 200),
        )),
        Card(
            child: Padding(
          padding:
              const EdgeInsets.only(top: 5, bottom: 5, left: 20, right: 20),
          child: sizedImage("assets/images/smart_mask_altium.png", 250, 200),
        )),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'Get all sources on ', style: TextStyle(fontSize: 20)),
              TextSpan(
                text: 'Github',
                style: TextStyle(color: Colors.blue, fontSize: 20),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launch('https://github.com/pseudoincorrect/smart_mask');
                  },
              ),
              TextSpan(text: ' !', style: TextStyle(fontSize: 20)),
            ],
          ),
        )
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
