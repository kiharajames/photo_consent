import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:photo_consent/public_variables.dart';
import 'package:photo_consent/style.dart';

class TakeVideo extends StatefulWidget {
  final CameraDescription camera2;
  TakeVideo({Key key, this.camera2}) : super(key: key);
  @override
  _TakeVideoState createState() => _TakeVideoState();
}

class _TakeVideoState extends State<TakeVideo> {
  bool checkValue = false;
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera2,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.

    _initializeControllerFuture= _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take consent video'),
      ),
      body: Container(
        color: Colors.grey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text('Please state the following:', style: TextStyle(fontSize: 17),),
              Card(
                color: Colors.blue[200],
                child: Container(
                  margin: EdgeInsets.all(10),
                    child: Text('"I consent to physical activities up to and including intercourse with my partner, state name of partner"', style: TextStyle(

                    ),)),

              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  SizedBox(
                    height: 230,
                    child: Card(
                      elevation: 10,
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            // If the Future is complete, display the preview.
                            return CameraPreview(_controller);
                          } else {
                            // Otherwise, display a loading indicator.
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    ),
                  ),
                  FloatingActionButton(
                      child: Icon(Icons.crop_square),
                      backgroundColor: Colors.redAccent,
                      onPressed: () async {
                        //get storage path

                        final Directory appDirectory = await getApplicationDocumentsDirectory();
                        final String videoDirectory = '${appDirectory.path}/Videos';
                        await Directory(videoDirectory).create(recursive: true);
                        final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
                        final String filePath = '$videoDirectory/${currentTime}.mp4';

                        if (!_controller.value.isRecordingVideo) {
                          _controller.startVideoRecording();
                        }
                        if (_controller.value.isRecordingVideo) {
                          XFile videoFile = await _controller.stopVideoRecording();
                          print(videoFile.path);//and there is more in this XFile object
                        }
                      }
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    flex: 2,
                    child: Checkbox(value: checkValue,
                        onChanged: (bool value){
                      setState(() {
                        checkValue = value;
                      });
                        }
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Text('I prefer my partner perform practices deemed as "safe sex practice" or risk losing my consent', style: TextStyle(fontWeight: FontWeight.bold),),)
                ],
              )
            ],

          ),
        ),
      ),
    );
  }
}
