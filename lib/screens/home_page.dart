import 'package:flutter/material.dart';
import 'package:my_app/services/authentication.dart';
//import 'package:firebase_database/firebase_database.dart';
//import 'package:my_app/models/todo.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Text(
         'HOME $widget.userId'
       ),
    );
  }
}