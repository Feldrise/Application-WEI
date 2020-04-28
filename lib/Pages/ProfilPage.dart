import 'package:flutter/material.dart';

/** 
 * Cette page affiche les infos de l'utilisateurs 
 * et quelques jolies stats.
 */
class ProfilPage extends StatefulWidget {
  const ProfilPage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;

  ProfilPageState createState() => ProfilPageState();
}

class ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
      ),
      body: Container(
        child: Center(
          child: Text("Hello Profil"),
        ),
      ),
    );
  }
}