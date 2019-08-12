import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:receipt_bubble/screens/scanning/confirmHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';

import 'package:receipt_bubble/models/RtReceiptModel.dart';
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

final formatCurrency = new NumberFormat.simpleCurrency();
final FirebaseDatabase _database = FirebaseDatabase.instance;

class Item {
  String name;
  num totalCost;
  num unitCost;
  int quantity;

  Item(String name, num totalCost, num unitCost, int quantity){
    this.name = name;
    this.totalCost = totalCost;
    this.unitCost = unitCost;
    this.quantity = quantity;
  }
}

class ReceiptInfo {
  List items;
  num finalTotal;
  num finalTax;

  ReceiptInfo(List items, num finalTotal, num finalTax){
    this.items = items;
    this.finalTotal = finalTotal;
    this.finalTax = finalTax;
  }
}

class ScanConfirm extends StatefulWidget {

  final String imagePath;

  ScanConfirm({Key key, this.imagePath, this.userEmail}) : super(key: key);

  final String userEmail;

  _ScanConfirmState createState() => _ScanConfirmState();
}

class _ScanConfirmState extends State<ScanConfirm> {

  var receiptInfo;
  
  VisionText visionText;
  bool receiptReady = false;
  final db = Firestore.instance;

  void initState() {
    super.initState();
    _initializeVision();
    // print('done');
  }

  Future getReceiptInfo(visionText) async {
    var text = ConfirmHelper.getText(visionText);

    var info = ConfirmHelper.getItems(text);

    setState(() {
      receiptInfo = info;
      receiptReady = true;
    });
    // return;

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
    VisionText localVisionText = await textRecognizer.processImage(visionImage);
    
    setState(() {//can't put await inside because it can only be in async
      visionText = localVisionText;
    });

    // var info = await _getReceiptInfo(visionText);
    // setState(() {
    //   receiptInfo = info;
    //   receiptReady = true;
    // });
    
    // print(receiptInfo.items);
    // for(int i = 0; i < receiptInfo.items.length; i++){
    //   print(receiptInfo.items[i].name);
    //   print(receiptInfo.items[i].totalCost);
    // }
    // print(receiptInfo.finalTax);
    // print(receiptInfo.finalTotal);

    // print('done');
  }

  String getPrettyJSONString(jsonObject){
    var encoder = new JsonEncoder.withIndent("     ");
    return encoder.convert(jsonObject);
  }

  void uploadReceipt () async {
    String groupID = randomAlpha(5).toUpperCase();
    var newReceipt = new RtReceipt(receiptInfo.items, receiptInfo.finalTotal, receiptInfo.finalTax, widget.userEmail, groupID);
    // newReceipt.toJson();
    // print(newReceipt.items);
    // print(getPrettyJSONString(newReceipt.toJson()));
    try{
      db.collection("receipts").add(newReceipt.toJson());
    }catch(err){
      print(err);
      print('Database error');
    }


    // var query = db.collection("receipts").where('groupID', isEqualTo: 'abcd');
    // QuerySnapshot snapshot = await query.getDocuments();
    // try{
    //   print(snapshot.documents[0].data);

    // }catch(err){
    //   print(err);
    //   print('Database error');
    // }
      


    print('Uploading Receipt...');
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        // child: Image.file(File(widget.imagePath))
        body: FutureBuilder(
          future: getReceiptInfo(visionText),
          builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && receiptInfo != null) {
            // If the Future is complete, display the preview.
            print('receipt');
            return Column(children: [
              Expanded(child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: receiptInfo.items.length,
                itemBuilder: (BuildContext context, int i) {
                  return ListTile(
                    title: Text('${receiptInfo.items[i].name != '' ? receiptInfo.items[i].name : 'Unknown Item'}'),
                    trailing: Text('${formatCurrency.format(receiptInfo.items[i].totalCost)}'),
                  );
                } 
              ),
            ),
            Divider(color: Colors.grey,),
            ListTile(
              title: Text('Tax'),
              trailing: Text('${formatCurrency.format(receiptInfo.finalTax)}'),
            ),
            ListTile(
              
              title: Text('Total'),
              trailing: Text('${formatCurrency.format(receiptInfo.finalTotal)}'),
            ),
            Center(
              child: RaisedButton(
                color: Colors.green,
                onPressed: () {this.uploadReceipt();},
                child: Text(
                  'Confirm'
                ),
              ),
            ),
            Container(
              height: 20.0,
            ),
              

            ],);
            
            
          } else {
            // Otherwise, display a loading indicator.
            print('loading');

            return Center(child: CircularProgressIndicator());
          }
        },
        )
    );
  }
}
