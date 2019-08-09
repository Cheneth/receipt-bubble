import 'dart:io';

import 'package:flutter/material.dart';

class ConnectToGroup extends StatefulWidget {
  ConnectToGroup({Key key}) : super(key: key);

  _ConnectToGroupState createState() => _ConnectToGroupState();
}

class _ConnectToGroupState extends State<ConnectToGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Padding(
                padding: EdgeInsets.all(90.0),
                child: Center(
                        child: 
                            TextField(
                              decoration: InputDecoration(
                                
                                hintText: 'Enter your group ID'
                              ),
                            )
                      ,),
              )
       
       
    );
  }
}