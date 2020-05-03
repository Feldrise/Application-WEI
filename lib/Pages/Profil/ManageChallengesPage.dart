import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Pages/Profil/EditChallenge.dart';
import 'package:appli_wei/Widgets/Cards/ChallengeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// This page give a list of the challenges
/// It gives the ability to add/modify/remove a challenge
class ManageChallengesPage extends StatefulWidget {

  @override
  _ManageChallengesPageState createState() => _ManageChallengesPageState();
}

class _ManageChallengesPageState extends State<ManageChallengesPage> {
  Widget _detailWidget;

  @override
  void initState() {
    super.initState();

    _detailWidget = Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Image(
          image: AssetImage("assets/images/logo.png"),
          height: 128,
        ),
        SizedBox(height: 16,),
        Text("Veuillez séléctionner un défi.", textAlign: TextAlign.center,)
      ],
    );  
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraint) {
        return Row(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(maxWidth: (constraint.maxWidth > 680) ? 440 : constraint.maxWidth),
              child: Scaffold(
                appBar: AppBar(
                  title: Text("Gestion des défis"),
                ),
                body: Container(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: Firestore.instance.collection('activities').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                      // We want to split the team challenges from the other challenges
                      List<DocumentSnapshot> teamChallengesSnapshot = [];
                      List<DocumentSnapshot> challengesSnapshot = [];

                      for (DocumentSnapshot challengeSnapshot in snapshot.data.documents) {
                        if (challengeSnapshot.data['is_for_team']) 
                          teamChallengesSnapshot.add(challengeSnapshot);
                        else 
                          challengesSnapshot.add(challengeSnapshot);
                      }


                      return _buildGrid(context, teamChallengesSnapshot + challengesSnapshot, screenMaxWidth: constraint.maxWidth);
                    },
                  )
                ),
                floatingActionButton: FloatingActionButton(
                  tooltip: "Ajouter",
                  child: Icon(Icons.add, color: Colors.white,),
                  onPressed: () async {
                    Challenge challengeToAdd = new Challenge();

                    if (constraint.maxWidth > 680) {
                      setState(() {
                        _detailWidget = EditChallenge(challenge: challengeToAdd,);
                      });
                    }
                    else {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditChallenge(challenge: challengeToAdd,)),
                      );
                    }
                  },
                ),
              )
            ),
            
            // We show the details widget in the same screen only on
            // bigger screens
            if (constraint.maxWidth > 680)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    border: Border(
                      left: BorderSide(
                        color: Colors.blueGrey,
                        width: 1,
                      ),
                    ),
                  ),
                  child: _detailWidget,
                )
              )
          ],
        );
      },
    );
  }

  /// We return the grid view with all data from the [snapshot]
  Widget _buildGrid(BuildContext context, List<DocumentSnapshot> snapshot, {double screenMaxWidth}) {
    List<StaggeredTile> _staggeredTiles = [];

    for (int i = 0; i < snapshot.length; ++i) {
      _staggeredTiles.add(StaggeredTile.extent(2, i.isEven ? 300 : 348));
    }

    return StaggeredGridView.count(
      crossAxisCount: 4,
      staggeredTiles: _staggeredTiles,
      children: snapshot.map((data) => _buildGridItem(context, data, screenMaxWidth: screenMaxWidth)).toList(),
    );
  }

  /// We return a grid item with the [data] provided
  Widget _buildGridItem(BuildContext context, DocumentSnapshot data, {double screenMaxWidth}) {
    final challenge = Challenge.fromSnapshot(data);

    return ChallengeCard(
      challenge: challenge, 
      isManaged: true,
      onButtonPressed: () async {
        if (screenMaxWidth > 680) {
          setState(() {
            _detailWidget = EditChallenge(challenge: challenge,);
          });
        }
        else {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditChallenge(challenge: challenge,)),
          );
        }
      },
    );
  }
}