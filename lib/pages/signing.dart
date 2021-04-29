import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signing extends StatefulWidget {
  @override
  _SigningState createState() => _SigningState();
}

class _SigningState extends State<Signing> {
  final GlobalKey<SfSignaturePadState> signatureGlobalKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Append signature.'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('I practice safe sex and wish that my partner does as well'),
                ),
              ),
              SizedBox(height: 10,),
              Column(
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
            ],
          ),
        ),
      ),
    );
  }
}
