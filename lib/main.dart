import 'package:flutter/material.dart';
import 'package:my_app/widgets/random_words.dart';
import 'package:my_app/screens/login_signup_page.dart';
import 'package:my_app/screens/root_page.dart';

import 'services/authentication.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Startup name generator',
      theme: ThemeData(
        primaryColor: Colors.white,
        accentColor: Colors.red,
      ),
      home: new RootPage(auth: new Auth())
    );
  }
}
  
  