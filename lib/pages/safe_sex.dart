import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:photo_consent/public_variables.dart';
import 'package:photo_consent/style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SafeSex extends StatefulWidget {
  final String participants;
  SafeSex({Key key, this.participants}) : super(key: key);
  @override
  _SafeSexState createState() => _SafeSexState();
}

class _SafeSexState extends State<SafeSex> {
  int checkBoxNo = 0;
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List _imageFile;
  bool checkValue = true;
  var myCheckBoxVar = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: checkBoxNo == 0 ? Colors.green : Colors.red,
      appBar: AppBar(
        backgroundColor: myAppBarColor,
        title: Container(
          child: Column(
            children: [
              Text('Safe sex preference.'),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(

          child: Column(
            children: [
              Screenshot(
                controller: screenshotController,
                child: Column(
                  children: [
                    Text('Check the box if you prefer to use safe sex practices:', style: TextStyle(color: Colors.white),),
                    for(var i =1; i<=int.parse(widget.participants); i++) ListTile(
                      leading: Checkbox(
                        checkColor: Colors.green,
                        activeColor: Colors.white,
                        value: myCheckBoxVar['$i'] == null ? checkValue : myCheckBoxVar['$i'],
                        onChanged: (bool value){
                          if(value == false){
                            setState(() {
                              myCheckBoxVar[i.toString()] = value;
                              checkBoxNo += 1;
                            });
                          }else{
                            setState(() {
                              myCheckBoxVar[i.toString()] = value;
                              checkBoxNo -=1;
                            });
                          }
                        },
                      ),
                      title: Text('Participant $i', style: TextStyle(color: Colors.white),),
                    )

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Colors.white,
                  child: Text('Save'),
                  minWidth: double.maxFinite,
                  height: 50,
                  onPressed: () async {
                    screenshotController
                        .capture()
                        .then((Uint8List image) async {
                      //print("Capture Done");
                      setState(() {
                        _imageFile = image;
                      });
                      final result =
                      await ImageGallerySaver.saveImage(image); // Save image to gallery,  Needs plugin  https://pub.dev/packages/image_gallery_saver
                      Fluttertoast.showToast(
                        msg: "Screenshot taken, image saved",
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        toastLength: Toast.LENGTH_SHORT,
                        fontSize: 16.0,
                        timeInSecForIosWeb: 2,
                      );
                    }).catchError((onError) {
                      print(onError);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MaterialButton(
                  color: Colors.white,
                  child: Text('Done'),
                  minWidth: double.maxFinite,
                  height: 50,
                  onPressed: (){
                    Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
