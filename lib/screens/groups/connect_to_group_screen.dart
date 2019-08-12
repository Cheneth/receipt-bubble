import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receipt_bubble/screens/splitting/receipt_split_screen.dart';

class ConnectToGroup extends StatefulWidget {
  ConnectToGroup({Key key, this.userEmail,}) : super(key: key);

  String userEmail;
  _ConnectToGroupState createState() => _ConnectToGroupState();
}

class _ConnectToGroupState extends State<ConnectToGroup> {

  final myController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  submitID(){
    
  }

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Padding(
                padding: EdgeInsets.all(90.0),
                child: Center(
                        child: Column(children: <Widget>[
                          TextField(
                              controller: myController,
                              decoration: InputDecoration(
                                
                                hintText: 'Enter your group ID'
                              ),
                              onEditingComplete: submitID(),
                            ),
                            RaisedButton(
                              onPressed: (){Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ReceiptSplit(userEmail: widget.userEmail, groupID: myController.text,),
                                            ),
                                            );
                                          } ,
                              child: Text('Enter'),
                            )
                        ],)
                            
                            
                      ,),
              )
       
       
    );
  }
}