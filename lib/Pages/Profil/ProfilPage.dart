import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    return Consumer<ApplicationSettings>(
      builder: (context, appliationSettings, child) {
        User currentUser = appliationSettings.loggedUser;

        return Scaffold(
          appBar: AppBar(
            title: Text("Profil"),
          ),
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  color: Theme.of(context).accentColor,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start, 
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        height: 92,
                        width: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(46),
                          color: Colors.black,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(46),
                          child: Image(
                            image: AssetImage('assets/images/logo_white.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${currentUser.firstName} ${currentUser.secondName}", style: Theme.of(context).textTheme.subhead.merge(TextStyle(color: Colors.white)),),
                            currentUser.teamId != null
                            ? StreamBuilder<DocumentSnapshot>(
                              stream: Firestore.instance.collection("teams").document(currentUser.teamId).snapshots(),
                              builder: (context, teamSnapshot) {
                                if (!teamSnapshot.hasData) return LinearProgressIndicator();
                                
                                return Text("Equipe " + teamSnapshot.data["name"], style: Theme.of(context).textTheme.subhead.merge(TextStyle(color: Colors.white)),);
                              },
                            )
                            : Text("Vous n'avez pas encore d'équipe", style: Theme.of(context).textTheme.subhead.merge(TextStyle(color: Colors.white))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.whatshot, size: 128,),
                              Text("${currentUser.points} points", style: Theme.of(context).textTheme.subhead,)
                            ],
                          ),
                        ),
                        RaisedButton(
                          child: const Text('Déconnexion', style: TextStyle(color: Colors.white),),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            await Provider.of<ApplicationSettings>(context, listen: false).disconnect();
                          },
                        ),
                        Visibility(
                          visible: currentUser.role == "admin",
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Gérer les défis', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    print("Manage defis");
                                    widget.onPush("manageDefis");
                                  },
                                ),
                              ),
                              SizedBox(width: 4,),
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Gérer les joueurs', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    print("Manage teams");
                                    widget.onPush("manageUsers");
                                  },
                                ),
                              ),
                              SizedBox(width: 4,),
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Gérer les équipes', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    print("Manage teams");
                                    widget.onPush("manageTeams");
                                  },
                                ),
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ),
        );
      },
    );
  }
}