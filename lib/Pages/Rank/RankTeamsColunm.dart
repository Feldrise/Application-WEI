import 'dart:async';

import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Widgets/Cards/TeamRankCard.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


/// This is the column for the "teams rank" tab in
/// the rank page
class RankTeamsColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isAdmin = Provider.of<ApplicationSettings>(context).loggedUser.role == "admin";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[ 
        // A button to switch rank visibility
        // Only visible for admins
        Visibility(
          visible: isAdmin,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: RaisedButton(
              child: const Text('Changer la visibilité du classement', style: TextStyle(color: Colors.white),),
              color: Theme.of(context).accentColor,
              onPressed: () async {
                await _toggleRankVisiblity();
              },
            ),
          ),
        ),

        // This is the rank. First, we check the visibility, then we show it
        Flexible(
          child: StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection('settings').document('application').snapshots(),
            builder: (context, settings) {
              if (!settings.hasData) return Center(child: CircularProgressIndicator(),);

              // If we can't show the rank (and we are not admin)
              // we show an alternat message
              if (!settings.data['show_teams_rank'] && !isAdmin) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image(
                      image: AssetImage("assets/images/logo.png"),
                      height: 128,
                    ),
                    SizedBox(height: 16,),
                    Text("Le classement des joueurs est caché aux yeux de tous pour l'instant... Reviens plus tard. =P", textAlign: TextAlign.center,)
                  ],
                );  
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // A card to say if the rank is visible
                  // Only visible for admins
                  Visibility(
                    visible: isAdmin,
                    child: WeiCard(
                      child: Text(settings.data['show_teams_rank'] ? "Le classement est visible de tous" : "Le classement n'est visible que par les administrateurs"),
                    ),
                  ),

                  // The rank itself
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('teams').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

                        // We create a new list beceause Firebase one
                        // may not have enough place to sort
                        List<DocumentSnapshot> teamsSnaphot = [];

                        for (DocumentSnapshot teamSnapshot in snapshot.data.documents) {
                          teamsSnaphot.add(teamSnapshot);
                        }

                        // We need to sort the teams in the rank
                        // (it wouldn't be a rank otherwise xP)
                        teamsSnaphot.sort((team1, team2) {
                          if (team1.data['points'] > team2.data['points'])
                            return -1;
                          
                          if (team1.data['points'] < team2.data['points'])
                            return 1;

                          return 0;
                        });

                        // If there is no team in the rank, we must
                        // show an alternative message
                        if (teamsSnaphot.isEmpty) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image: AssetImage("assets/images/logo.png"),
                                height: 128,
                              ),
                              SizedBox(height: 16,),
                              Text("Il n'y a pas d'équipe à classer pour le moment.", textAlign: TextAlign.center,)
                            ],
                          );  
                        }

                        return _buildList(context, teamsSnaphot);
                      }
                    )
                  )
                ]
              );
            },
          )
        ),
      ]
    );
  }

  /// We return the list view with all data from the [snapshot]
  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshots) {
    return ListView(
      shrinkWrap: true,
      children: snapshots.map((data) => _buildListItem(context, data, snapshots.indexOf(data) + 1)).toList(),
    );
  }

  /// We return a list item with the [data] provided with the given [index]
  Widget _buildListItem(BuildContext context, DocumentSnapshot snapshot, int index) {
    Team team = Team.fromSnapshot(snapshot);

    return TeamRankCard(team: team, rankPosition: index,);
  }

  /// This funtion change rank visibility and update Firebase accordingly
  Future _toggleRankVisiblity() async {
    // We check the current state of the visibility
    Completer completer = new Completer<bool>();
    Firestore.instance.collection('settings').document('application').snapshots().listen((data) {
      completer.complete(data.data['show_teams_rank']);
    });

    bool show = await completer.future;

    await Firestore.instance.collection('settings').document('application').updateData({
      'show_teams_rank': !show
    });
  }
}