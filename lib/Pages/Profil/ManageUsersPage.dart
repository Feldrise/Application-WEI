import 'dart:async';

import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Pages/Profil/ChangeTeamDialog.dart';
import 'package:appli_wei/Pages/Profil/ChangeUserPointsDialog.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des utilisateurs"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            List<DocumentSnapshot> usersWithoutTeam = [];
            List<DocumentSnapshot> userWithTeam = [];

            for (DocumentSnapshot userSnasphot in snapshot.data.documents) {
              if (userSnasphot.data['role'] == "captain" || userSnasphot.data['role'] == "admin") 
                continue;
              
              if (userSnasphot.data['team_id'] == null) 
                usersWithoutTeam.add(userSnasphot);
              else 
                userWithTeam.add(userSnasphot);
            }


            return _buildList(context, usersWithoutTeam + userWithTeam);
          },
        )
      ),
    );
  }

  
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);

    return WeiCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Avatar(path: 'avatars/${user.id}', backgroundColor: Theme.of(context).accentColor,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Text("${user.firstName} ${user.secondName}", style: Theme.of(context).textTheme.subhead,),
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

  Future _changeUserTeam(BuildContext context, User user) async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return ChangeTeamDialog(user: user,);
      }
    );
  }

  Future _changeUserPoints(BuildContext context, User user) async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return ChangeUserPointsDialog(user: user,);
      }
    );
  }
}