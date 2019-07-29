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
    
    var text = ConfirmHelper.getText(visionText);
    var receiptInfo = ConfirmHelper.getItems(text);
    print(receiptInfo.items);
    print(receiptInfo.finalTotal);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Image.file(File(widget.imagePath))
    );
  }
}
