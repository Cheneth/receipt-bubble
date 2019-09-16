import 'package:flutter/material.dart';
import 'package:receipt_bubble/services/authentication.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key key, this.auth, this.userEmail, this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;
  String userEmail;

  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(

       child: ListView(
         children: <Widget>[
            ListTile(title: Text(widget.userEmail),),
            Center(
                  child: RaisedButton(

                          onPressed: _signOut,
                          child: Text("LOGGOUT"),
                    ),
                )
         ],
       )
       
       
       
       
       
    );
  }

  _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}