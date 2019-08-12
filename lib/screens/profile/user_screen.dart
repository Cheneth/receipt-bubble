import 'package:flutter/material.dart';
import 'package:receipt_bubble/services/authentication.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key key, this.auth, this.onSignedOut}) : super(key: key);

  final BaseAuth auth;
  final VoidCallback onSignedOut;

  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: RaisedButton(
         onPressed: _signOUt,
         child: Text("LOGGOUT"),
       ),
    );
  }

  _signOUt() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}