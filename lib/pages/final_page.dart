import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_consent/public_variables.dart';
import 'package:photo_consent/style.dart';


class FinalPage extends StatefulWidget {
  @override
  _FinalPageState createState() => _FinalPageState();
}

class _FinalPageState extends State<FinalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: myAppBarColor,
        title: Container(
          child: Column(
            children: [
              Text('Thank You'),
            ],
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('We appreciate you using Sentual app for your consenting needs. '),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('At this time affirmative consent has been given by all parties. Files have been saved to the '
                'phone\s internal storage.'),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: MaterialButton(
              color: Colors.white,
              child: Text('Finish'),
              minWidth: double.maxFinite,
              height: 50,
              onPressed: (){
                SystemNavigator.pop();
              },
            ),
          )
        ],
      ),
    );
  }
}
