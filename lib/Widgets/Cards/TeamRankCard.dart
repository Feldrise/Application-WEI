import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Pages/Rank/TeamDetailsPage.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This is a widget to show the team rank. If it's
/// the current user's team, we show it bigger with
/// accent color
class TeamRankCard extends StatelessWidget {
  const TeamRankCard({
    Key key, 
    @required this.team,
    @required this.rankPosition,  
  }) : super(key: key);

  final Team team;
  final int rankPosition;

  @override
  Widget build(BuildContext context) {
    final bool isUserTeam = Provider.of<ApplicationSettings>(context, listen: false).loggedUser.teamId == team.id;

    final Color cardColor = isUserTeam ? Theme.of(context).accentColor : Theme.of(context).cardColor;
    final Color textColor = isUserTeam ? Colors.white : Colors.black87;
    final Color buttonColor = isUserTeam ? Colors.white : Theme.of(context).accentColor;

    return WeiCard(
      margin: isUserTeam ? EdgeInsets.symmetric(vertical: 4, horizontal: 4) : EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // The profil picture of the team
          Avatar(path: 'avatars/teams/${team.id}', size: 64,),
          SizedBox(width: 8,),
          
          // The team's name, captain, number of point
          // and a button to show more details
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // The team name
                Text("${team.name}", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: textColor)),),
                
                // The team captain
                team.captainId == null || team.captainId.isEmpty
                ? Text("Capitaine : pas de capitaine",)
                : StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection("users").document(team.captainId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();

                    return Text("Capitaine : " + snapshot.data["first_name"] + ' ' + snapshot.data["second_name"], style: TextStyle(color: textColor),);
                  },
                ),

                // The number of points
                Text("Points : ${team.points}", style: TextStyle(color: textColor),),

                // The details button
                RaisedButton(
                  child: Text("Voir l'équipe", style: TextStyle(color: cardColor),),
                  color: buttonColor,
                  onPressed: () async => _showDetails(context)
                )
              ],
            ),
          ),
          SizedBox(width: 8,),
          
          // The team rank
          Expanded(
            flex: 3,
            child: Text("#$rankPosition", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: textColor)),),
          )
        ],
      ),
    );
  }

  Future _showDetails(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TeamDetailPage(team: team,)),
    );
  }
}