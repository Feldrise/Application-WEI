import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
          child: RaisedButton(
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white),),
            color: Theme.of(context).accentColor,
            onPressed: () async {
              await Provider.of<ApplicationSettings>(context, listen: false).disconnect();
            },
          ),
        ),
      ),
    );
  }
}