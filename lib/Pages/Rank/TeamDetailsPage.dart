import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/Cards/ChallengeCard.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This page show the details of a team. The details are
///  - The name 
///  - The profil picture 
///  - The captain
///  - The validated challenges
class TeamDetailPage extends StatelessWidget {
  const TeamDetailPage({Key key, @required this.team}) : super(key: key);

  final Team team;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // The header, with team's profil picture and name
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              color: Theme.of(context).accentColor,
              child: Row(
                children: <Widget>[
                  Avatar(path: 'avatars/teams/${team.id}',),
                  Text("Equipe ${team.name}", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: Colors.white)),)
                ],
              ),
            ),

            // The body of the page
            Flexible(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // If there is captain, we show him
                    (team.captainId != null && team.captainId.isNotEmpty) 
                    ? StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance.collection('users').document(team.captainId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();

                        return WeiCard(
                          child: Row(
                            children: <Widget>[
                              Avatar(path: 'avatars/${snapshot.data.documentID}',),
                              Text("Capitaine : " + snapshot.data['first_name'] + ' ' + snapshot.data['second_name'], style: Theme.of(context).textTheme.subtitle2,)
                            ],
                          ),
                        );
                      },
                    )
                    : WeiCard(
                      child: Text("Cette équipe n'a pas encore de capitaine..."),
                    ),
                    
                    // The number of team's points
                    WeiCard(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.whatshot),
                          Text("Nombre de point de l'équipe : ${team.points}")
                        ],
                      ),
                    ),

                    // All challenges validated by the team
                    Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('activities').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return CircularProgressIndicator();

                          List<DocumentSnapshot> defisSnapshot = [];

                          // We only show challenges that were validated
                          for (DocumentSnapshot activitySnapshot in snapshot.data.documents) {
                            if (!activitySnapshot.data['is_for_team'] || 
                                team.challengesValidated[activitySnapshot.documentID] == null ||
                                team.challengesValidated[activitySnapshot.documentID] < activitySnapshot.data['number_of_repetition']) 
                              continue;

                            defisSnapshot.add(activitySnapshot);
                          }

                          return _buildList(context, defisSnapshot);
                        },
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
  }

  /// We return the list view with all data from the [snapshot]
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  /// We return a list item with the [data] provided 
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final challenge = Challenge.fromSnapshot(data);

    challenge.validatedByUser = true; // All challenges from here are validated

    return ChallengeCard(challenge: challenge,);
  }
}