import 'dart:typed_data';
import 'package:camera/camera.dart';
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
  //some data is not needed here, just convenience in passing the data around the screens.
  final CameraDescription camera;
  final CameraDescription selfieCamera;
  final String participants;
  final int participantNo;
  final safeSexAcceptance;
  SafeSex({Key key, this.selfieCamera, this.participants, this.camera, this.participantNo, this.safeSexAcceptance}) : super(key: key);
  @override
  _SafeSexState createState() => _SafeSexState();
}

class _SafeSexState extends State<SafeSex> {
  int checkBoxNo = 0;
  ScreenshotController screenshotController = ScreenshotController();
  Uint8List _imageFile;
  bool checkValue = true;
  var myCheckBoxVar = {};
  int acceptance = 0;
  int decline = 0;
  int reload;

  @override
  void initState() {
    super.initState();
    reloadPage();//reloading page so that the logic for the  color background is loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: decline == 0 ? Colors.green : acceptance == 0 ? Colors.green : Colors.red,
      appBar: AppBar(
        backgroundColor: myAppBarColor,
        title: Container(
          child: Column(
            children: [
              Text('Safe sex preference'),
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
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                  color: Colors.white,
                    child: Column(
                  children: [
                    for(var i =1; i<=widget.participantNo; i++) showConsentResult(widget.safeSexAcceptance, i)

                  ],
                ))),
              ),
              decline == 0 ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Congratulations, the conditions for affirmative consent has been met, for this snapshot in time.\n\n'
                    'Thank you for using sentual app. \n\n'
                    'Be safe and have fun!'),
              ): acceptance == 0 ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Congratulations, the conditions for affirmative consent has been met, for this snapshot in time.\n\n'
                        'Thank you for using sentual app. \n\n'
                        'Be safe and have fun!'),

                  ) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Unfortunately uniform consent has not been given, by all parties.\n\n'
                    'Please discuss the situation, expectations and restart the app. \n'
                ),
              ) ,
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

  showConsentResult(Map consentMap, i){
    if(consentMap['$i'] == true){
      setState(() {
        acceptance += 1;
      });
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          tileColor: Colors.white,
          leading: Icon(Icons.check, color: Colors.green, size: 30.0,),
          // Checkbox(
          //   checkColor: Colors.green,
          //   activeColor: Colors.white,
          //   value: myCheckBoxVar['$i'] == null ? checkValue : myCheckBoxVar['$i'],
          //   onChanged: (bool value){
          //     if(value == false){
          //       setState(() {
          //         myCheckBoxVar[i.toString()] = value;
          //         checkBoxNo += 1;
          //       });
          //     }else{
          //       setState(() {
          //         myCheckBoxVar[i.toString()] = value;
          //         checkBoxNo -=1;
          //       });
          //     }
          //   },
          // ),
          subtitle: Text('Prefers to use safe sex practices.', style: TextStyle(color: Colors.black)),
          title: Text('Participant $i', style: TextStyle(color: Colors.black),),
        ),
      );
    }else{
      setState(() {
        decline += 1;
      });
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          tileColor: Colors.white,
          leading: Icon(Icons.cancel, color: Colors.red, size: 30.0,),
          subtitle: Text('Does not prefer to use safe sex practices.', style: TextStyle(color: Colors.black)),
          title: Text('Participant $i', style: TextStyle(color: Colors.black),),
        ),
      );
    }
  }
  void reloadPage() {
    Future.delayed(const Duration(seconds: 1), (){
      setState((){
        reload  = 1;
      });
    });
  }
}
