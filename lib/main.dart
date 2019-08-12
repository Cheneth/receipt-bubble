import 'package:flutter/material.dart';
import 'package:receipt_bubble/screens/login_signup_page.dart';
import 'package:receipt_bubble/screens/root_page.dart';
import 'package:flutter/services.dart';

import 'services/authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    return MaterialApp(
      title: 'Startup name generator',
      theme: ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.white,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}
  
  