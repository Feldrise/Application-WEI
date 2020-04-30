import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RankTeamsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

        List<DocumentSnapshot> teamsSnaphot = [];

        for (DocumentSnapshot teamSnapshot in snapshot.data.documents) {
          // We dont want to show every teams
          teamsSnaphot.add(teamSnapshot);
        }

        // We sort the teams
        teamsSnaphot.sort((team1, team2) {
          if (team1.data['points'] > team2.data['points'])
            return -1;
          
          if (team1.data['points'] < team2.data['points'])
            return 1;

          return 0;
        });

        if (teamsSnaphot.isEmpty) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image(
                image: AssetImage("assets/images/logo.png"),
                height: 128,
              ),
              SizedBox(height: 16,),
              Text("Il n'y a pas d'équipe à classer pour le moment.")
            ],
          );  
        }

        return _buildList(context, teamsSnaphot);

      }
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView(
      shrinkWrap: true,
      children: snapshots.map((data) => _buildListItem(context, data, snapshots.indexOf(data) + 1)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot, int index) {
    Team team = Team.fromSnapshot(snapshot);

    bool isUserTeam = Provider.of<ApplicationSettings>(context, listen: false).loggedUser.teamId == team.id;

    Color cardColor = isUserTeam ? Theme.of(context).accentColor : Theme.of(context).cardColor;
    Color textColor = isUserTeam ? Colors.white : Colors.black87;

    return WeiCard(
      margin: isUserTeam ? EdgeInsets.symmetric(vertical: 4, horizontal: 4) : EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Avatar(path: 'avatars/teams/${team.id}', size: 64,),
          SizedBox(width: 8,),
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("${team.name}", style: Theme.of(context).textTheme.subhead.merge(TextStyle(color: textColor)),),
                team.captainId == null 
                ? Text("Capitaine : pas de capitaine",)
                : StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection("users").document(team.captainId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();

                    return Text("Capitaine : " + snapshot.data["first_name"] + ' ' + snapshot.data["second_name"], style: TextStyle(color: textColor),);
                  },
                ),
                Text("Points : ${team.points}", style: TextStyle(color: textColor),),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text("#$index", style: Theme.of(context).textTheme.title.merge(TextStyle(color: textColor)),),
          )
        ],
      ),
    );
  }
}