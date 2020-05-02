import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Pages/Profil/ChangeTeamDialog.dart';
import 'package:appli_wei/Pages/Profil/ChangeUserPointsDialog.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This widget show a card with some user
/// details
class UserCard extends StatelessWidget {
  const UserCard({Key key, @required this.user}) : super(key: key);

  final User user;

  @override
  Widget build(BuildContext context) {
    return WeiCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // The user profil picture
          Avatar(path: 'avatars/${user.id}', backgroundColor: Theme.of(context).accentColor,),

          // The user name and its team if any
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("${user.firstName} ${user.secondName}", style: Theme.of(context).textTheme.subtitle2,),
                ),

                user.teamId == null 
                ? Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("Equipe : pas d'équipe",)
                )
                : StreamBuilder<DocumentSnapshot>(
                  stream: Firestore.instance.collection("teams").document(user.teamId).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return LinearProgressIndicator();

                    return Padding(
                      padding: EdgeInsets.only(left: 16),
                      child: Text("Equipe : " + snapshot.data["name"],)
                    );
                  },
                ),

                FlatButton(
                  child: Text("Changer d'équipe", style: TextStyle(color: Theme.of(context).accentColor),),
                  onPressed: () async {
                    await _changeUserTeam(context, user);
                  },
                ),

                FlatButton(
                  child: Text("Ajouter/enlever des points à cet utilisateur", style: TextStyle(color: Theme.of(context).accentColor),),
                  onPressed: () async {
                    await _changeUserPoints(context, user);
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// This function show a dialog with a list of teams to change the 
  /// user's team
  Future _changeUserTeam(BuildContext context, User user) async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return ChangeTeamDialog(user: user,);
      }
    );
  }

  /// The function shows a dialog to add or remove points for the user
  Future _changeUserPoints(BuildContext context, User user) async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return ChangeUserPointsDialog(user: user,);
      }
    );
  }
}