import 'package:flutter/material.dart';
import 'package:photo_consent/route_generator.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(
        primaryColor: Colors.blue,
    ),
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
}


