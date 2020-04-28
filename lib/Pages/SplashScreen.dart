import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(),
      ),
      body: Container(
        color: Theme.of(context).accentColor,
        child: Center(
          child:Image (
            image: AssetImage('assets/logo_white.png'),
            height: 128,
          ),
        ),
      ),
    );
  }
}