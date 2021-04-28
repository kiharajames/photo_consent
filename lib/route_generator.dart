import 'package:flutter/material.dart';
import 'package:photo_consent/pages/landing_page.dart';
import 'package:photo_consent/pages/photo_screen.dart';
import 'package:photo_consent/style.dart';
import 'package:photo_consent/pages/take_video.dart';

class RouteGenerator {

  static Route<dynamic> generateRoute(RouteSettings settings) {


    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => LandingPage());
      case '/photo_screen':
        CameraData args = settings.arguments;
        return MaterialPageRoute(builder: (_) => TakePictureScreen(camera: args.camera,participants: args.participants, selfieCamera: args.selfieCamera,));
      case '/take_video':
        TakeVideoScreenData args2 = settings.arguments;
        return MaterialPageRoute(builder: (_) => TakeVideo(camera2: args2.camera2,));
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