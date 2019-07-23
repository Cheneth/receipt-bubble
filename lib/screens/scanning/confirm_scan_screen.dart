import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:receipt_bubble/screens/scanning/confirmHelper.dart';
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;
//   const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Display the Picture')),
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: Image.file(File(imagePath)),
//     );
//   }
// }

class ScanConfirm extends StatefulWidget {

  final String imagePath;

  ScanConfirm({Key key, this.imagePath}) : super(key: key);

  _ScanConfirmState createState() => _ScanConfirmState();
}

class _ScanConfirmState extends State<ScanConfirm> {

  String recognizedText = "Loading ...";

  void initState() {
    super.initState();
    _initializeVision();
  }

  void _initializeVision() async {
    // get image file
    final File imageFile = File(widget.imagePath);

    // create vision image from that file
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    // create detector index
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

    // find text in image
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);
    
    ConfirmHelper.printText(visionText);
    // got the pattern from that SO answer: https://stackoverflow.com/questions/16800540/validate-email-address-in-dart
    String mailPattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$";
    RegExp regEx = RegExp(mailPattern);

    String mailAddress =
        "Couldn't find any mail in the foto! Please try again!";
    for (TextBlock block in visionText.blocks) {
      for (TextLine line in block.lines) {
        if (regEx.hasMatch(line.text)) {
          mailAddress = line.text;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Image.file(File(widget.imagePath))
    );
  }
}
