import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/DefiCard.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              color: Theme.of(context).accentColor,
              child: Row(
                children: <Widget>[
                  Avatar(path: 'avatars/teams/${team.id}',),
                  Text("Equipe ${team.name}", style: Theme.of(context).textTheme.subhead.merge(TextStyle(color: Colors.white)),)
                ],
              ),
            ),
            Flexible(
              child: Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    (team.captainId != null && team.captainId.isNotEmpty) 
                    ? StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance.collection('users').document(team.captainId).snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return CircularProgressIndicator();

                        return WeiCard(
                          child: Row(
                            children: <Widget>[
                              Avatar(path: 'avatars/${snapshot.data.documentID}',),
                              Text("Capitaine : " + snapshot.data['first_name'] + ' ' + snapshot.data['second_name'], style: Theme.of(context).textTheme.subhead,)
                            ],
                          ),
                        );
                      },
                    )
                    : WeiCard(
                      child: Text("Cette équipe n'a pas encore de capitaine..."),
                    ),
                    
                    WeiCard(
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.whatshot),
                          Text("Nombre de point de l'équipe : ${team.points}")
                        ],
                      ),
                    ),
                    Flexible(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection('activities').snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return CircularProgressIndicator();

                          List<DocumentSnapshot> defisSnapshot = [];


                          for (DocumentSnapshot activitySnapshot in snapshot.data.documents) {
                            // We only show challenges that were validated
                            if (!activitySnapshot.data['is_for_team'] || 
                                team.defisValidated[activitySnapshot.documentID] == null ||
                                team.defisValidated[activitySnapshot.documentID] < activitySnapshot.data['number_of_repetition']) 
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

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final activity = Activity.fromSnapshot(data);

    activity.validatedByUser = true;

    return DefiCard(defi: activity,);
  }
}