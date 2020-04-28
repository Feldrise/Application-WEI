import 'package:flutter/material.dart';

/** 
 * Cette page correspond à la page d'accueil.
 * Seul les capitaines pourront valider les défis 
 *
 * Cette page affiche et dois récupérer : 
 * [Pour les utilisateurs]
 *  - Les défis de l'utilisateurs
 *  - Les défis d'équipes
 * [Pour les capitaines]
 * - Les défis des utilisateurs de l'équipe **qui sont à valider**
 * - Les défis d'équipes
 * [Pour les administrateurs]
 *  - Les défis des utilisateurs de toutes les équipes AVEC LE TITRE DE L'EQUIPE qui sont à valider
 *  - Les défis d'équipes
 */
class HomePage extends StatefulWidget {
  const HomePage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;
  
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Accueil"),
      ),
      body: Container(
        child: Center(
          child: Text("Hello Accueil"),
        ),
      ),
    );
  }
}