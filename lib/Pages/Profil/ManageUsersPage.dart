import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Cards/UserCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This page give a list of the users
/// It gives the ability to change users team
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
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

             // We want to split the users whithout team yet from the other users
            List<DocumentSnapshot> usersWithoutTeam = [];
            List<DocumentSnapshot> userWithTeam = [];

            // We dont show captains and admin here
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

  /// We return the list view with all data from the [snapshot]
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      shrinkWrap: true,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  /// We return a list item with the [data] provided
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final user = User.fromSnapshot(data);

    return UserCard(user: user,);
  }
}