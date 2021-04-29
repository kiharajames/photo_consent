import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:ui' as ui;
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
  VideoPlayerController _controllervideoplay;
  Future<void> _initializeVideoPlayerFuture;
  bool videoIsRecording = false;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  int showPlayVideoCard = 0;// don't show the card if the video is not recorded

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
    _controllervideoplay.dispose();

    super.dispose();
  }

  void initVideoState(String file) {
    // Create an store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.]
    setState(() {
      _controllervideoplay = VideoPlayerController.file(file);
      _initializeVideoPlayerFuture = _controllervideoplay.initialize();
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Take consent video'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.grey[100],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.blue[200],
                  child: Container(
                    margin: EdgeInsets.all(10),
                      child: Text('Please state the following: "I consent to physical activities up to and including intercourse with my partner, state name of partner"', style: TextStyle(

                      ),)),

                ),
                Card(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 3,
                            child: Column(
                              children: [
                                Card(
                                  child: SfSignaturePad(
                                    minimumStrokeWidth: 1,
                                    maximumStrokeWidth: 3,
                                    strokeColor: Colors.blue,
                                    backgroundColor: Colors.grey,
                                    key: signatureGlobalKey,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(icon: Icon(Icons.check, color: Colors.green,),
                                        onPressed: () async {
                                          final data = await signatureGlobalKey.currentState.toImage(pixelRatio: 3.0);
                                          final bytes = await data.toByteData(format: ui.ImageByteFormat.png);
                                          final status = await Permission.storage.status;
                                          if (!status.isGranted) {
                                            await Permission.storage.request();
                                          }

                                          final time = DateTime.now().toIso8601String().replaceAll('.', ':');
                                          final name = 'signature_$time';

                                          final result = await ImageGallerySaver.saveImage(bytes.buffer.asUint8List(), name: name);
                                          final isSuccess = result['isSuccess'];

                                          if (isSuccess) {
                                            Fluttertoast.showToast(
                                              msg: "Saved to signature folder",
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.green,
                                              textColor: Colors.white,
                                              toastLength: Toast.LENGTH_SHORT,
                                              fontSize: 16.0,
                                              timeInSecForIosWeb: 2,
                                            );
                                          } else {
                                            Fluttertoast.showToast(
                                              msg: "Failed to save signature",
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                              toastLength: Toast.LENGTH_SHORT,
                                              fontSize: 16.0,
                                              timeInSecForIosWeb: 2,
                                            );
                                          }
                                        }
                                    ),
                                    IconButton(icon: Icon(Icons.clear, color: Colors.red,),
                                        onPressed: (){
                                          signatureGlobalKey.currentState.clear();
                                        })
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex:3,
                            child: Column(
                              children: [
                                FutureBuilder<void>(
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
                                        setState(() {
                                          videoIsRecording = true;
                                          showPlayVideoCard = 1;
                                        });
                                      }
                                      if (_controller.value.isRecordingVideo) {
                                        XFile videoFile = await _controller.stopVideoRecording();
                                        print(videoFile.path);//and there is more in this XFile object
                                        initVideoState(videoFile.path);
                                        setState(() {
                                          videoIsRecording = false;
                                        });
                                      }
                                    }
                                ),
                                videoIsRecording == true ? Text('Stop recording') : Text('Start Recording')
                              ],
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
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
                ),
                showPlayVideoCard != 0 ? Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: Card(
                                child: _initializeVideoPlayerFuture != null ? FutureBuilder(
                                  future: _initializeVideoPlayerFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.done) {
                                      // If the VideoPlayerController has finished initialization, use
                                      // the data it provides to limit the aspect ratio of the VideoPlayer.
                                      return AspectRatio(
                                        aspectRatio: _controllervideoplay.value.aspectRatio,
                                        // Use the VideoPlayer widget to display the video.
                                        child: VideoPlayer(_controllervideoplay),
                                      );
                                    } else {
                                      // If the VideoPlayerController is still initializing, show a
                                      // loading spinner.
                                      return Center(child: CircularProgressIndicator());
                                    }
                                  },
                                ) : SizedBox(height: 0,),
                              ),
                            ),
                            Text(DateTime.now().toString()),
                            _initializeVideoPlayerFuture != null ? FloatingActionButton(
                              onPressed: () {
                                // Wrap the play or pause in a call to `setState`. This ensures the
                                // correct icon is shown
                                setState(() {
                                  // If the video is playing, pause it.
                                  if (_controllervideoplay.value.isPlaying) {
                                    _controllervideoplay.pause();
                                  } else {
                                    // If the video is paused, play it.
                                    _controllervideoplay.play();
                                  }
                                });
                              },
                              // Display the correct icon depending on the state of the player.
                              child: Icon(
                                _controllervideoplay.value.isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                            ) : SizedBox(height: 0,)

                          ],
                        ),
                      ],
                    ),
                  ),
                ) : Container(),
                Card(
                  elevation: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Sensteel app and it\'s affiliates are not responsible for providing consent or how this '
                        'app is used. By signing the box you are giving consent to your partner of physical activities up to'
                        'and including intercourse for a period of time not to exceed 24 hours from this timestamp: '+
                        DateTime.now().toString()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Colors.blue,
                    child: Text('Next'),
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: (){
                      Navigator.pushNamed(context, '/signing');
                    },
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}
