import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Pages/Home/ChallengeDetailPage.dart';
import 'package:appli_wei/Pages/Profil/EditChallenge.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:flutter/material.dart';

/// This widget show a summary of a challenge
/// and show it in a sort of card
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    Key key, 
    @required this.challenge, 
    this.userForChallenge, 
    this.teamForChallenge, 
    this.isManaged = false
  }) : super(key: key);

  final Challenge challenge;

  final User userForChallenge;
  final Team teamForChallenge;

  final bool isManaged;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: EdgeInsets.all(0),
      constraints: BoxConstraints(maxWidth: 174),
      child: Stack(
        children: <Widget>[
          // Construct the body of the card
          WeiCard(
            margin: EdgeInsets.only(top: 64),
            padding: EdgeInsets.only(top: 84, left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // The name of the challenge
                Text(challenge.name, textAlign: TextAlign.center, style: Theme.of(context).textTheme.subtitle,),

                SizedBox(height: 4,),
                
                // A short description of the challenge
                Expanded(
                  child: Text(challenge.description, textAlign: TextAlign.center,),
                ),
                
                // The details button
                // Only visible if the challenge is not in a managed state
                Visibility(
                  visible: !isManaged,
                  child: FlatButton(
                    child: Text("Détails", style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChallengeDetailPage(challenge: challenge, userForChallenge: userForChallenge, teamForChallenge: teamForChallenge,)),
                      );
                    },
                  )
                ),

                // The modify button
                // Only visible if the challenge is in a managed state
                Visibility(
                  visible: isManaged,
                  child: FlatButton(
                    child: Text("Modifier", style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditChallenge(challenge: challenge,)),
                      );
                    },
                  ),
                )
              ],
            ),
          ),

          // The image of the challenge
          Positioned(
            left: 12,
            right: 12,
            // This is the card shape
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0, // has the effect of softening the shadow
                    spreadRadius: 1, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal
                      4.0, // vertical
                    ),
                  )
                ],
              ),
              // This is the challenge
              // I use a stack to add a mark if the challenge is validated
              child: Stack(
                children: <Widget>[
                  // The actual challenge image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      challenge.imageUrl,
                      height: 128,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  // The validated marck
                  // Only visible if the challenge is validated
                  Visibility(
                    visible: challenge.validatedByUser, 
                    child: Center(
                      child: Image(
                        image: AssetImage("assets/images/check.png"),
                        height: 128,
                        fit: BoxFit.fitHeight,
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}