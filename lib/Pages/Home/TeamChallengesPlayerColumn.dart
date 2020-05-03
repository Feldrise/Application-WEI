import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Pages/Home/ChallengeDetailPage.dart';
import 'package:appli_wei/Widgets/Cards/ChallengeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

/// This return the widget to show in the "Team Challenges" tab on the home 
/// page for the players AND captains
class TeamChallengesPlayerColumn extends StatefulWidget {

  @override
  _TeamChallengesPlayerColumnState createState() => _TeamChallengesPlayerColumnState();
}

class _TeamChallengesPlayerColumnState extends State<TeamChallengesPlayerColumn> {
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
              child: StreamBuilder<QuerySnapshot>(
                stream: Firestore.instance.collection('activities').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                  List<DocumentSnapshot> challengesSnapshot = [];


                  // We only want challenges for team and which are visible
                  for (DocumentSnapshot challengeSnapshot in snapshot.data.documents) {
                    if (!challengeSnapshot.data['is_for_team'] || !challengeSnapshot.data['visible'])
                      continue;

                    challengesSnapshot.add(challengeSnapshot);
                  }

                  return _buildGrid(context, challengesSnapshot, screenMaxWidth: constraint.maxWidth);
                },
              )
              ),
            
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
    
    String teamId = Provider.of<ApplicationSettings>(context).loggedUser.teamId;

    // We need to get the team to be able to passe it to the challenge
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance.collection('teams').document(teamId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator()); 

        Team teamForChallenge = Team.fromSnapshot(snapshot.data);
        
        if (teamForChallenge.challengesValidated[challenge.id] != null) { 
          if (teamForChallenge.challengesValidated[challenge.id] >= challenge.numberOfRepetition)
            challenge.validatedByUser = true;
          
          challenge.userRepetition = teamForChallenge.challengesValidated[challenge.id];
        }
        
        return ChallengeCard(
          challenge: challenge, 
          onButtonPressed: () async {
            if (screenMaxWidth > 680) {
              setState(() {
                _detailWidget = ChallengeDetailPage(
                  challenge: challenge,
                  userForChallenge: Provider.of<ApplicationSettings>(context, listen: false).loggedUser,
                  teamForChallenge: teamForChallenge,
                );
              });
            }
            else {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChallengeDetailPage(
                  challenge: challenge,
                  userForChallenge: Provider.of<ApplicationSettings>(context, listen: false).loggedUser,
                  teamForChallenge: teamForChallenge,
                )),
              );
            }
          },
        );
      },
    );
  }
}