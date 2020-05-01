import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Pages/Profil/ChangeTeamPointsDialog.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:appli_wei/Pages/Profil/EditTeam.Dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This widget show a card with some team
/// details
class TeamCard extends StatelessWidget {
  const TeamCard({Key key, @required this.team}) : super(key: key);

  final Team team;

  @override
  Widget build(BuildContext context) {
     return WeiCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // The team profil picture
          Avatar(path: 'avatars/teams/${team.id}', backgroundColor: Theme.of(context).accentColor,),

          // The team name and its captain name if any
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text(team.name, style: Theme.of(context).textTheme.subhead,),
                ),
                
                team.captainId == null || team.captainId.isEmpty
                ? Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("L'équipe n'a pas encore de capitaine",)
                )
                : StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection("users").document(team.captainId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();

                    // We need to know if the captain is admin to not downgrade his role
                    if (snapshot.data["role"] == "admin")
                      team.captainIsAdmin = true;

                    return Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text("Capitaine : " + snapshot.data["first_name"] + " " + snapshot.data["second_name"],)
                    );
                  },
                ),

                FlatButton(
                  child: Text("Modifier l'équipe", style: TextStyle(color: Theme.of(context).accentColor),),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditTeam(team: team,)),
                    );
                  },
                ),

                FlatButton(
                  child: Text("Ajouter/enlever des points à cet équipe", style: TextStyle(color: Theme.of(context).accentColor),),
                  onPressed: () async {
                    await _changeTeamPoints(context, team);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  
  /// The function shows a dialog to add or remove points for the team
  Future _changeTeamPoints(BuildContext context, Team team) async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return ChangeTeamPointsDialog(team: team,);
      }
    );
  }
}