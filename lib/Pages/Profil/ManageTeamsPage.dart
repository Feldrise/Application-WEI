import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Pages/Profil/ChangeTeamPointsDialog.dart';
import 'package:appli_wei/Pages/Profil/EditTeam.Dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTeamsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des équipes"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('teams').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            List<DocumentSnapshot> teamsWithoutCaptain = [];
            List<DocumentSnapshot> teamsWithCaptain = [];

            for (DocumentSnapshot userSnasphot in snapshot.data.documents) { 
              if (userSnasphot.data['captain_id'] == null) 
                teamsWithoutCaptain.add(userSnasphot);
              else 
                teamsWithCaptain.add(userSnasphot);
            }


            return _buildList(context, teamsWithoutCaptain + teamsWithCaptain);
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Ajouter",
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          print("Add new defi");

          Team teamToAdd = new Team();

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditTeam(team: teamToAdd,)),
          );
        },
      ),
    );
  }

  
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final team = Team.fromSnapshot(data);

    return WeiCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Avatar(path: 'avatars/teams/${team.id}', backgroundColor: Theme.of(context).accentColor,),
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
  Future _changeTeamPoints(BuildContext context, Team team) async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return ChangeTeamPointsDialog(team: team,);
      }
    );
  }
}