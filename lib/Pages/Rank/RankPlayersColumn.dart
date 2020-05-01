import 'dart:async';

import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Cards/PlayerRankCard.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This is the column for the "players rank" tab in
/// the rank page
class RankPlayersColumn extends StatelessWidget {
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
              onPressed: _toggleRankVisiblity
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
              if (!settings.data['show_players_rank'] && !isAdmin) {
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
                      child: Text(settings.data['show_players_rank'] ? "Le classement est visible de tous" : "Le classement n'est visible que par les administrateurs"),
                    ),
                  ),
                  
                  // The rank itself
                  Flexible(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return Center(child: CircularProgressIndicator(),);

                        List<DocumentSnapshot> playersSnaphot = [];

                        // We dont want to show admin and captain on the rank page
                        for (DocumentSnapshot playerSnapshot in snapshot.data.documents) {
                          if (playerSnapshot.data['role'] == 'captain' || playerSnapshot.data['role'] == 'admin') 
                            continue;

                          playersSnaphot.add(playerSnapshot);
                        }

                        // We need to sort the players in the rank
                        // (it wouldn't be a rank otherwise xP)
                        playersSnaphot.sort((player1, player2) {
                          if (player1.data['points'] > player2.data['points'])
                            return -1;
                          
                          if (player1.data['points'] < player2.data['points'])
                            return 1;

                          return 0;
                        });

                        // If there is no player in the rank, we must
                        // show an alternative message
                        if (playersSnaphot.isEmpty) {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image(
                                image: AssetImage("assets/images/logo.png"),
                                height: 128,
                              ),
                              SizedBox(height: 16,),
                              Text("Il n'y a pas de joueurs à classer pour le moment.", textAlign: TextAlign.center,)
                            ],
                          );  
                        }

                        return _buildList(context, playersSnaphot);
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
    User user = User.fromSnapshot(snapshot);

    return PlayerRankCard(user: user, rankPosition: index,);
  }

  /// This funtion change rank visibility and update Firebase accordingly
  Future _toggleRankVisiblity() async {
    // We check the current state of the visibility
    Completer completer = new Completer<bool>();
    Firestore.instance.collection('settings').document('application').snapshots().listen((data) {
      completer.complete(data.data['show_players_rank']);
    });

    bool show = await completer.future;

    await Firestore.instance.collection('settings').document('application').updateData({
      'show_players_rank': !show
    });
  }
}