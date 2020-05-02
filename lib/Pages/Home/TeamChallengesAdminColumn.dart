
import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Cards/ChallengeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This return the widget to show in the "Team Challenges" tab on the home 
/// page for the admin. This is basically the list of teams challenges
/// which can be validated
class TeamChallengesAdminColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('teams').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        List<Widget> challengesWidget = [];

        // We browse teams
        for (DocumentSnapshot teamSnapshot in snapshot.data.documents) {
          challengesWidget.add(
            Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // This is the name of the team
                Container(
                  padding: EdgeInsets.only(left: 8, top: 8),
                  child: Text(teamSnapshot.data['name'], style: Theme.of(context).textTheme.subtitle2,),
                ),
                // This is the list of challenges
                StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance.collection('activities').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

                    List<DocumentSnapshot> challengesSnapshot = [];

                    // We only want's challenges for teams
                    for (DocumentSnapshot challengeSnapshot in snapshot.data.documents) {
                      if (!challengeSnapshot.data['is_for_team']) 
                        continue;

                      challengesSnapshot.add(challengeSnapshot);
                    }

                    return _buildListForTeam(context, challengesSnapshot, Team.fromSnapshot(teamSnapshot));
                  },
                )   
              ],
            )
          );
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: challengesWidget,
          )
        );
      },
    );
  }

   /// We return the list view with all data from the [snapshot] for the [teamForChallenge]
  Widget _buildListForTeam(BuildContext context, List<DocumentSnapshot> snapshot, Team teamForChallenge) {
    return Container(
      height: 300,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: snapshot.map((data) => _buildListItemForTeam(context, data, teamForChallenge)).toList(),
      )
    );
  }
  
  /// We return a list item with the [data] provided for the [teamForChallenge]
  Widget _buildListItemForTeam(BuildContext context, DocumentSnapshot data, Team teamForChallenge) {
    final challenge = Challenge.fromSnapshot(data);

    if (teamForChallenge.challengesValidated[challenge.id] != null) { 
      if (teamForChallenge.challengesValidated[challenge.id] >= challenge.numberOfRepetition)
        challenge.validatedByUser = true;
      
      challenge.userRepetition = teamForChallenge.challengesValidated[challenge.id];
    }

    // We want to get the captain, cause the user for a team challenge is the team's captain
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('users').document(teamForChallenge.captainId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); 

        User captain = User.fromSnapshot(snapshot.data);

        return ChallengeCard(
          challenge: challenge, 
          userForChallenge: captain,
          teamForChallenge: teamForChallenge,
        );
      },
    );
  }
}