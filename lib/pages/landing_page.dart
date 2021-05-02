import 'package:flutter/material.dart';
import 'package:photo_consent/public_variables.dart';
import 'package:photo_consent/style.dart';
import 'package:camera/camera.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  TextEditingController participants = TextEditingController();
  CameraDescription firstCamera;
  CameraDescription selfieCamera;

  Future<void> getMyCameras() async{
    // Ensure that plugin services are initialized
    WidgetsFlutterBinding.ensureInitialized();
    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final myfirstCamera = cameras.first;
    final myselfieCamera = cameras.last;

    setState(() {
      firstCamera = myfirstCamera;
      selfieCamera = myselfieCamera;
    });
  }

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset('assets/images/launch_image.png'),
            SizedBox(height: 20,),
            Text(
              'Welcome to SentualApp',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.0,),
            Text(
              'How many participants are you?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.green,
                fontSize: 20.0,
              ),

            ),
            SizedBox(height: 20.0,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(

              ),
              child: TextField(
                keyboardType: TextInputType.number,
                controller: participants,
                style: TextStyle(color: Colors.black87 ),
                decoration: InputDecoration(
                  hintText: '3',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                  labelText: 'participants',
                  labelStyle: TextStyle(
                      color: Colors.green
                  ),

                  prefixIcon: Icon(
                    Icons.account_circle_sharp,
                    color: Colors.green,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),

                ),
              ),
            ),
            SizedBox(height: 10.0,),
            SizedBox(height: 10.0,),
            MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              minWidth: double.maxFinite,
              height: 55.0,
              color: Colors.green,
              onPressed: (){
                getMyCameras().then((value) => Navigator.pushNamed(context, '/photo_screen', arguments: CameraData(camera: firstCamera, participants: participants.text, selfieCamera: selfieCamera, participantsNo: 1)));
              },
              child: Text(
                'Move on',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
              ),
            ),
            SizedBox(height: 10.0,),
          ],
        ),
      ),
    );
  }
}

