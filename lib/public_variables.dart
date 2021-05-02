import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
Widget myCircularProgressBar = CircularProgressIndicator(backgroundColor: Colors.blue, valueColor: new AlwaysStoppedAnimation<Color>(Colors.black87),);
TextStyle myTitleStyle = TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20);

class CameraData{
  CameraDescription camera;
  CameraDescription selfieCamera;
  String participants;
  int participantsNo;
  CameraData({this.camera, this.participants, this.selfieCamera, this.participantsNo});
}
