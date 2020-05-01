import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Pages/Profil/EditTeam.Dart';
import 'package:appli_wei/Widgets/Cards/TeamCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This page give a list of the teams
/// It gives the ability to add/modify/remove a team
class ManageTeamsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des équipes"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('teams').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

            // We want to split the teams whithout captain yet from the other teams
            List<DocumentSnapshot> teamsWithoutCaptain = [];
            List<DocumentSnapshot> teamsWithCaptain = [];

            for (DocumentSnapshot teamSnapshot in snapshot.data.documents) { 
              if (teamSnapshot.data['captain_id'] == null) 
                teamsWithoutCaptain.add(teamSnapshot);
              else 
                teamsWithCaptain.add(teamSnapshot);
            }


            return _buildList(context, teamsWithoutCaptain + teamsWithCaptain);
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Ajouter",
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          Team teamToAdd = new Team();

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditTeam(team: teamToAdd,)),
          );
        },
      ),
    );
  }

  /// We return the list view with all data from the [snapshot]
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  /// We return a list item with the [data] provided
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final team = Team.fromSnapshot(data);

    return TeamCard(team: team,);
  }

}