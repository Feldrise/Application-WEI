import 'package:flutter/material.dart';

/** 
 * Cette page affiche le classement
 * Elle doit donc récupérer 
 *  - La liste des utilisateurs triés par points
 *  - La liste des équipes triés par points
 */
class RanksPage extends StatefulWidget {
  const RanksPage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;

  RanksPageState createState() => RanksPageState();
}

class RanksPageState extends State<RanksPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Classement"),
      ),
      body: Container(
        child: Center(
          child: Text("Hello Classement"),
        ),
      ),
    );
  }
}