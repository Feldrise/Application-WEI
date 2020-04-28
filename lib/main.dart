import 'package:appli_wei/Pages/MainPage.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Appli du WEI',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        accentColor: Color(0xfff70c36),

        appBarTheme: AppBarTheme(
          color: Colors.white,
          textTheme: Theme.of(context).textTheme,
          elevation: 0,
        ),

        textTheme: TextTheme(
          title: TextStyle(fontSize: 38.0, fontWeight: FontWeight.w500, color: Colors.black87),
          subtitle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200, color: Colors.black87),
          headline: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.black87),
          subhead: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300, color: Colors.black87),
          body1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black87),
          body2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black87),
          caption: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.black87)
        ),
      ),
      home: MainPage(),
    );
  }
}