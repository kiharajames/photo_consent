import 'package:flutter/material.dart';
const TextStyle app_style = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);

const InputDecoration input1 = InputDecoration(
  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0),),
);

const InputDecoration input2 = InputDecoration(
  labelText: '******',
  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black, width: 2.0),),
);


Color myAppBarColor = Colors.blue;
Color myIconThemeColor = Colors.black;

class MyStyles extends StatefulWidget {



  @override
  _MyStylesState createState() => _MyStylesState();
}

class _MyStylesState extends State<MyStyles> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
