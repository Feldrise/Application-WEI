import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Pages/Home/ChallengeDetailPage.dart';
import 'package:appli_wei/Widgets/Cards/ChallengeCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This return the widget to show in the "Challenges" tab on the home 
/// page for the captain AND admin. This is basically the list of users challenges
/// which need to be validated
class ChallengesCaptainColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationSettings>(
      builder: (context, applicationSetting, child) {
        bool isAdmin = applicationSetting.loggedUser.role == "admin";
        
        return StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            List<Widget> usersPendingDefisWidget = [];

            for (DocumentSnapshot userSnapshot in snapshot.data.documents) {
              // If the logged user is not admin and the watched user is not from his team, 
              // we dont want to include it
              if (!isAdmin && userSnapshot.data['team_id'] != applicationSetting.loggedUser.teamId)
                continue;

              User userForChallenge = User.fromSnapshot(userSnapshot);

              if (userForChallenge.challengesToValidate.isEmpty)
                continue;

              // We construct the list with the pending challenged for user.
              // It's a column with the user name and the challenges list
              usersPendingDefisWidget.add(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // The user name
                    Container(
                      padding: EdgeInsets.only(left: 8, top: 8),
                      child: Text("${userForChallenge.firstName} ${userForChallenge.secondName}", style: Theme.of(context).textTheme.subtitle2,),
                    ),
                    // The list of challenges
                    StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('activities').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return LinearProgressIndicator();
                        
                        List<DocumentSnapshot> challengesSnapshot = [];

                        // We only want's challenges to validate for user
                        for (DocumentSnapshot challengeSnapshot in snapshot.data.documents) {
                          if (!userForChallenge.challengesToValidate.contains(challengeSnapshot.documentID)) 
                            continue;

                          challengesSnapshot.add(challengeSnapshot);
                        }

                        return _buildListForUser(context, challengesSnapshot, userForChallenge);
                      },
                    )   
                  ],
                )
              ) ;
            }

            // If there is no challenge who needs validation, we show
            // an alternat message
            if (usersPendingDefisWidget.isEmpty) {
              return Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image(
                    image: AssetImage("assets/images/logo.png"),
                    height: 128,
                  ),
                  SizedBox(height: 16,),
                  Text("Il n'y a rien à valider pour le moment.")
                ],
              );  
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: usersPendingDefisWidget,
              )
            );
          },
        );
      },
    );
  }

   /// We return the list view with all data from the [snapshot] for the [userForChallenge]
  Widget _buildListForUser(BuildContext context, List<DocumentSnapshot> snapshot, User userForChallenge) {
    return Container(
      height: 300,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: snapshot.map((data) => _buildListItem(context, data, userForChallenge)).toList(),
      )
    );
  }
  
  /// We return a list item with the [data] provided for the [userForChallenge]
  Widget _buildListItem(BuildContext context, DocumentSnapshot data, User userForChallenge) {
    final challenge = Challenge.fromSnapshot(data);

    if (userForChallenge.challengesToValidate.contains(challenge.id)) 
      challenge.pendingValidation = true;

    if (userForChallenge.challengesValidated[challenge.id] != null) { 
      if (userForChallenge.challengesValidated[challenge.id] >= challenge.numberOfRepetition)
        challenge.validatedByUser = true;
      
      challenge.userRepetition = userForChallenge.challengesValidated[challenge.id];
    }

    return ChallengeCard(
      challenge: challenge,
      onButtonPressed: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChallengeDetailPage(
            challenge: challenge,
            userForChallenge: userForChallenge,
          )),
        );
      }
    );
  }
}