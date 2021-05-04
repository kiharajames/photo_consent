import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

import 'package:photo_consent/public_variables.dart';
import 'package:photo_consent/style.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:fluttertoast/fluttertoast.dart';

class _CameraController extends CameraController{
  _CameraController(CameraDescription description, ResolutionPreset resolutionPreset) : super(description, resolutionPreset);

}


class TakePictureScreen extends StatefulWidget {
  final String participants;
  final int participantNo;
  final CameraDescription camera;
  final CameraDescription selfieCamera;


  TakePictureScreen({Key key, this.participants, this.camera, this.selfieCamera, this.participantNo}): super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String appPath;

  void getAppDirectory() async{
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String appDocPath = appDocDir.path;
    setState(() {
      appPath = appDocPath;
    });
  }

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
    //get the app directory
    getAppDirectory();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: myAppBarColor,
        title: Column(
          children: [
            Text('Take Picture ID and Selfie',),
            Text('Participant ${widget.participantNo}'),
          ],
        ),

      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            SizedBox(
              height: 300,
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
            SizedBox(height: 10,),
            SizedBox(
              height: 50,
              child: Card(

                color: Colors.green[200],
                elevation: 10,
                child: Center(
                  child: Text('Please place photo ID above', style: TextStyle(fontSize: 20, color: Colors.black),),
                ),
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        elevation: 10,
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          print(appPath);
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();
            //save the image to the app folder in the phone

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image?.path,
                  selfieCamera: widget.selfieCamera,
                  camera: widget.camera,
                  participantNo: widget.participantNo,
                  participants: widget.participants,
                ),
              ),
            );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final CameraDescription selfieCamera;
  final String participants;
  final int participantNo;
  final CameraDescription camera;


  const DisplayPictureScreen({Key key, this.imagePath, this.selfieCamera, this.participants, this.participantNo, this.camera}) : super(key: key);

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  XFile selfie;
  CameraController _controller;
  Future<void> _initializeControllerFuture;
  String checkNextPage;
  //screenshot
  Uint8List _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();


  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.selfieCamera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    // Next, initialize the controller. This returns a Future.

    _initializeControllerFuture = _controller.initialize();

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
        backgroundColor: myAppBarColor,
          title: Column(
            children: [
              Text('Combine ID and Selfie',),
              Text('Participant ${widget.participantNo}'),
            ],
          ),
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: SingleChildScrollView(
        child: Column(
          children: [
            Screenshot(
              controller: screenshotController,
              child: Column(
                children: [
                  Row(),
                  SizedBox(
                    height: 250,
                      child: Image.file(File(widget.imagePath)
                      )),
                  selfie != null ? Stack(
                    children: [
                      SizedBox(height:250,child: Image.file(File(selfie.path))),
                      Positioned(
                        bottom: 1,
                          child: Card(child: Text('${DateTime.now().toString()}'))
                      ),
                    ],
                  ) : SizedBox(
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

                ],
              ),
            ),
            selfie == null ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Take Selfie'),
                    Icon(Icons.camera_alt),
                  ],
                ),
                // Provide an onPressed callback.
                onPressed: () async {
                  // Take the Picture in a try / catch block. If anything goes wrong,
                  // catch the error.
                  try {
                    // Ensure that the camera is initialized.
                    await _initializeControllerFuture;
                    // Attempt to take a picture and get the file `image`
                    // where it was saved.
                    final image = await _controller.takePicture();
                    setState(() {
                      selfie = image;

                    });
                    //save the image to the app folder in the phone
                    // If the picture was taken, display it on a new screen.
                  } catch (e) {
                    // If an error occurs, log the error to the console.
                    print(e);
                  }
                },
              ),
            ) : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Save Screenshot'),
                    Icon(Icons.camera_alt),
                  ],
                ),
                // Provide an onPressed callback.
                onPressed: () async {
                  screenshotController
                      .capture()
                      .then((Uint8List image) async {
                    //print("Capture Done");
                    setState(() {
                      _imageFile = image;
                      checkNextPage = "yes";
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
            checkNextPage == null ? Container() : Padding(
              padding: const EdgeInsets.all(8.0),
              child: MaterialButton(
                color: Colors.green,
                child: Text('Next'),
                minWidth: double.maxFinite,
                height: 50,
                onPressed: (){
                  Navigator.pushNamed(context, '/take_video', arguments: CameraData(
                      selfieCamera: widget.selfieCamera, camera: widget.camera,
                      participants: widget.participants, participantsNo: widget.participantNo));
                },

              ),
            ),
          ],
        ),
      ),

    );
  }
}
