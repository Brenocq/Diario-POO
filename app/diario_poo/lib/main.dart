import 'package:flutter/material.dart';
import 'app/landingPage.dart';
import 'services/auth.dart';

void main() => runApp(DiaryApp());

class DiaryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Diario POO',
        theme: ThemeData(
          fontFamily: 'Poppins',
          primarySwatch: Colors.blue,
        ),
        home: LandingPage(
          auth: Auth(),
        ),
        debugShowCheckedModeBanner: false);
  }
}
