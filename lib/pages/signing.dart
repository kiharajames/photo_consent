import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:photo_consent/public_variables.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_consent/style.dart';

class Signing extends StatefulWidget {
  final CameraDescription camera;
  final CameraDescription selfieCamera;
  final String participants;
  final int participantNo;
  Signing({Key key, this.selfieCamera, this.participants, this.camera, this.participantNo}) : super(key: key);

  @override
  _SigningState createState() => _SigningState();

}

class _SigningState extends State<Signing> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();
  String checkNextPage;


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.participantNo != int.parse(widget.participants)){
      int mypart = (widget.participantNo)+1;

    }else{
    //
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myAppBarColor,
        title: Column(
          children: [
            Text('Append signature.'),
            Text('Participant ${widget.participantNo}'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('I understand what consent means... the voluntary agreement to engage in sexual '
                        'activity without abuse or exploitation of "trust, power or authority", coercion or threats.\n\n'
                        'I understand that due to special circumstances around age, mental age, coercion, exploitation, and threat'
                        ', consent cannot ever be achieved. \n\n'
                        'I understand Consent and Affirmative Consent can be revoked at any moment and is an ongoing process. \n\n'
                        'Sentual App and it\'s affiliates are not responsible for any actions resulting from the usage of this app'
                        '. Sentual App is only attempting to record Affirmative consent as \'a snapshot in time\' and does not '
                        'make any claims of consent or affirmative consent between parties after the usage of this app.'),
                  ),
                ),
                SizedBox(height: 10,),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Sign here:', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
                Column(
                  children: [
                    Card(
                      elevation: 10,
                      child: SfSignaturePad(
                        minimumStrokeWidth: 1,
                        maximumStrokeWidth: 3,
                        strokeColor: Colors.green,
                        backgroundColor: Colors.white,
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
                                setState(() {
                                  checkNextPage = "yes";
                                });
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
                widget.participantNo != int.parse(widget.participants) ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: checkNextPage == null ? Container() : MaterialButton(
                    color: Colors.green,
                    child: Text('Next Participant'),
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: (){
                      Navigator.pushNamed(context, '/photo_screen', arguments: CameraData(selfieCamera: widget.selfieCamera, camera: widget.camera,
                          participants: widget.participants, participantsNo: (widget.participantNo)+1));
                    },
                  ),
                ) : checkNextPage == null ? Container() : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
                    color: Colors.green,
                    child: Text('Next'),
                    minWidth: double.maxFinite,
                    height: 50,
                    onPressed: (){
                      Navigator.pushNamed(context, '/safe_sex', arguments: widget.participants);
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
