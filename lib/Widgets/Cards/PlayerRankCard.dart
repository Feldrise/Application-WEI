import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This is a widget to show the player rank. If it's
/// the current user, we show it bigger with accent
/// color
class PlayerRankCard extends StatelessWidget {
  const PlayerRankCard({
    Key key, 
    @required this.user,
    @required this.rankPosition,  
  }) : super(key: key);

  final User user;
  final int rankPosition;

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUser = Provider.of<ApplicationSettings>(context).loggedUser.id == user.id;

    final Color cardColor = isCurrentUser ? Theme.of(context).accentColor : Theme.of(context).cardColor;
    final Color textColor = isCurrentUser ? Colors.white : Colors.black87;

    return WeiCard(
      margin: isCurrentUser ? EdgeInsets.symmetric(vertical: 4, horizontal: 4) : EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // The user profil picture
          Avatar(path: 'avatars/${user.id}', size: 64,),
          SizedBox(width: 8,),

          // The user's name, team and number of points
          Expanded(
            flex: 7,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text("${user.firstName} ${user.secondName}", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: textColor)),),
                user.teamId == null // The user may has no team
                ? Text("Equipe : pas d'équipe",)
                : StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection("teams").document(user.teamId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();

                    return Text("Equipe : " + snapshot.data["name"], style: TextStyle(color: textColor),);
                  },
                ),
                Text("Points : ${user.points}", style: TextStyle(color: textColor),),
              ],
            ),
          ),

          // The user rank index
          Expanded(
            flex: 3,
            child: Text("#$rankPosition", textAlign: TextAlign.center, style: Theme.of(context).textTheme.headline6.merge(TextStyle(color: textColor)),),
          )
        ],
      ),
    );
  }
}