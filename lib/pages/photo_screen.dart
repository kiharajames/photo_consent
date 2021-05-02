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
  CameraController _controller,_controllerselfie;
  Future<void> _initializeControllerFuture, _initializeControllerFutureselfie;
  

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
    _controllerselfie = _CameraController(
      // Get a specific camera from the list of available cameras.
      widget.selfieCamera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.

    _initializeControllerFutureselfie = _controllerselfie.initialize();

  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controllerselfie.dispose();

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
                shape: Border.all(color: Colors.black, width: 3, style: BorderStyle.solid),
                color: Colors.green[200],
                elevation: 10,
                child: Center(
                  child: Text('Please place photo ID', style: TextStyle(fontSize: 20, color: Colors.black),),
                ),
              ),
            ),
            SizedBox(
              height: 230,
              child: Card(
                elevation: 10,
                child: FutureBuilder<void>(
                  future: _initializeControllerFutureselfie,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      // If the Future is complete, display the preview.
                      return CameraPreview(_controllerselfie);
                    } else {
                      // Otherwise, display a loading indicator.
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 10,),
            Padding(
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        elevation: 10,
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {

          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFutureselfie;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controllerselfie.takePicture();
            //save the image to the app folder in the phone

            // If the picture was taken, display it on a new screen.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  // Pass the automatically generated path to
                  // the DisplayPictureScreen widget.
                  imagePath: image?.path,
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
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myAppBarColor,
          title: Text('Display the Picture')
      ),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
