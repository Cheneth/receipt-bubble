import 'package:flutter/material.dart';
import 'package:receipt_bubble/screens/groups/connect_to_group_screen.dart';
import 'package:receipt_bubble/screens/profile/user_screen.dart';
import 'package:receipt_bubble/screens/scanning/scan_screen.dart';
import 'package:receipt_bubble/services/authentication.dart';
import 'package:receipt_bubble/widgets/color_test.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:my_app/models/todo.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.auth, this.userId, this.userEmail, this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String userEmail;

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

int _currentIndex = 0;

List<Widget> _children;

void initState() {
    super.initState();
    _children = [
      ConnectToGroup(userEmail: widget.userEmail,),
      ScanScreen(userEmail: widget.userEmail,),
      PlaceholderWidget(Colors.green),
      getUserProfileWidget(),
    ];
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       title: Text('Receipt Bubble'),
     ),
     body: _children[_currentIndex],
     bottomNavigationBar: BottomNavigationBar(
       onTap: onTabTapped, // new
       currentIndex: _currentIndex,
       selectedItemColor: Colors.teal,
       unselectedItemColor: Colors.grey,
       //currentIndex: 2, // this will be set when a new tab is tapped
       items: [
         BottomNavigationBarItem(
           icon: new Icon(Icons.group),
           title: new Text('groups'),
         ),
         BottomNavigationBarItem(
           icon: new Icon(Icons.camera),
           title: new Text('Scan'),
         ),
         BottomNavigationBarItem(
           icon: new Icon(Icons.receipt),
           title: new Text('Receipts'),
         ),
         BottomNavigationBarItem(
           icon: Icon(Icons.person),
           title: Text('You')
         )
       ],
     ),
   );
 }

 void onTabTapped(int index) {
   print(widget.userEmail);
   setState(() {
     _currentIndex = index;
   });
 }

 Widget getUserProfileWidget(){

   return UserProfile(auth: widget.auth, onSignedOut: widget.onSignedOut, userEmail: widget.userEmail,);
 }

 void signOut() async {
   try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
 }

}