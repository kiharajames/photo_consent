import 'package:flutter/material.dart';
import 'package:photo_consent/pages/landing_page.dart';
import 'package:photo_consent/pages/photo_screen.dart';
import 'package:photo_consent/style.dart';
import 'package:photo_consent/pages/take_video.dart';
import 'package:photo_consent/pages/signing.dart';
import 'package:photo_consent/public_variables.dart';
import 'package:photo_consent/pages/safe_sex.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {


    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LandingPage());
      case '/photo_screen':
        CameraData args = settings.arguments;
        return MaterialPageRoute(builder: (_) => TakePictureScreen(camera: args.camera,participants: args.participants, selfieCamera: args.selfieCamera, participantNo: args.participantsNo,));
      case '/take_video':
        CameraData args = settings.arguments;
        return MaterialPageRoute(builder: (_) => TakeVideo(camera: args.camera,participants: args.participants, selfieCamera: args.selfieCamera, participantNo: args.participantsNo,));
      case '/signing':
        CameraData args = settings.arguments;
        return MaterialPageRoute(builder: (_) => Signing(camera: args.camera,participants: args.participants, selfieCamera: args.selfieCamera, participantNo: args.participantsNo,));
      case '/safe_sex':
        var args = settings.arguments;
        return MaterialPageRoute(builder: (_) => SafeSex(participants: args,));
        default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: myAppBarColor,
          iconTheme: IconThemeData(color: myIconThemeColor),
          title: Text(
            'Error',
            style: app_style,
          ),
        ),
        body: Center(
          child: Text(
            'There has been aan error',
            style: app_style,
          ),
        ),
      );
    });
  }
}