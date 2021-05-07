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
import 'package:tapioca/tapioca.dart';

class TakeVideo extends StatefulWidget {
  final CameraDescription camera;
  final CameraDescription selfieCamera;
  final String participants;
  final int participantNo;
  TakeVideo({Key key, this.selfieCamera, this.participants, this.camera, this.participantNo}) : super(key: key);
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
  String checkNextPage;
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  int showPlayVideoCard = 0;// don't show the card if the video is not recorded
  //editing the video
  final tapiocaBalls = [
    TapiocaBall.textOverlay("${DateTime.now().toString()}",200,600,20,Color(0xFF00E344)),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.selfieCamera,
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
        backgroundColor: myAppBarColor,
        title: Column(
          children: [
            Text('Take consent video'),
            Text('Participant ${widget.participantNo}'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 10,
                  color: Colors.green[200],
                  child: Container(
                    margin: EdgeInsets.all(10),
                      child: Text('Please state the following: "I consent to physical activities up to and including intercourse with my partner, state name of partner"', style: TextStyle(

                      ),)),

                ),
                Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      SizedBox(
                        height:200,
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
                                checkNextPage = null;
                              });
                            }
                            if (_controller.value.isRecordingVideo) {
                              XFile videoFile = await _controller.stopVideoRecording();
                              print(videoFile.path);//and there is more in this XFile object
                              //initVideoState(videoFile.path);
                              var tempDir = await getTemporaryDirectory();
                              final path = '${tempDir.path}/result.mp4';
                              final cup = Cup(Content(videoFile.path), tapiocaBalls);
                              cup.suckUp(path).then((_) {
                                ImageGallerySaver.saveFile(path);
                                initVideoState(path);
                              });
                              setState(() {
                                videoIsRecording = false;
                                checkNextPage = "yes";
                              });
                            }
                          }
                      ),
                      videoIsRecording == true ? Text('Stop recording') : Text('Start Recording')
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Video shows below after you stop recording:'),
                ),
                showPlayVideoCard != 0 ? Card(
                  elevation: 10,
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
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('I am aware that STDs are infectious and are passed from one person to another '
                            'during sexual activity. Anybody who has oral sex, anal sex, vaginal sex, genital skin-to-skin '
                            'contact, or who shares sexual fluids with another person can get STDs. \n\n'
                            'Safer sex (often called “safe sex”) means taking steps to protect yourself '
                            'and your partner from STDs when you have sex.\n\n'
                            'There are lots of ways you can make sex safer. One of the best ways is by using a barrier — like'
                            ' condoms, internal condoms, dental dams, and/or latex or nitrile gloves — every single time you '
                            'have oral, anal, or vaginal sex, or do anything that can pass sexual fluids (like sharing sex toys). '
                            'Barriers protect you and your partner from sexual fluids and some skin-to-skin contact, which can both '
                            'spread STDs.\n\n'
                            'I prefer my partner performs practices generally accepted as "safe sex," to limit the sharing of sexual '
                            'fluids. I understand no barrier is perfect.\n\n'
                            'If my partner/s do not adhere to the best of thier ability to perform \'safer sex\' practices, then my '
                            'partner/s risk losing my consent.\n',
                          style: TextStyle(fontWeight: FontWeight.bold),),
                      ),)
                  ],
                ),

                checkNextPage == null ? Container() : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Colors.green,
                    child: Text('Next'),
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: (){
                      if(checkValue == false){
                        Fluttertoast.showToast(
                          msg: "Please check the box above,'I prefer my partner...' ",
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          toastLength: Toast.LENGTH_SHORT,
                          fontSize: 16.0,
                          timeInSecForIosWeb: 2,
                        );
                      }else{
                        Navigator.pushNamed(context, '/signing', arguments: CameraData(
                            selfieCamera: widget.selfieCamera, camera: widget.camera,
                            participants: widget.participants, participantsNo: widget.participantNo));
                      }

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
