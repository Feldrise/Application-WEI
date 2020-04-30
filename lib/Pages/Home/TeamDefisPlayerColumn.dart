import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Widgets/DefiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class TeamDefisPlayerColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('activities').snapshots(),
      builder: (context, snapshot) {
        List<DocumentSnapshot> defisSnapshot = [];
        if (!snapshot.hasData) return LinearProgressIndicator();

        for (DocumentSnapshot activitySnapshot in snapshot.data.documents) {
          if (!activitySnapshot.data['is_for_team'] || !activitySnapshot.data['visible'])
            continue;

          defisSnapshot.add(activitySnapshot);
        }

        String teamId = Provider.of<ApplicationSettings>(context).loggedUser.teamId;
        return StreamBuilder<DocumentSnapshot>(
          stream: Firestore.instance.collection('teams').document(teamId).snapshots(),
          builder: (context, teamSnapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator(); 

            Team teamForDefi = Team.fromSnapshot(teamSnapshot.data);

            return _buildList(context, defisSnapshot, teamForDefi);
          },
        );
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot, Team teamForDefi) {
    List<StaggeredTile> _staggeredTiles = [];

    for (int i = 0; i < snapshot.length; ++i) {
      _staggeredTiles.add(StaggeredTile.extent(2, i.isEven ? 264 : 300));
    }

    return StaggeredGridView.count(
      crossAxisCount: 4,
      staggeredTiles: _staggeredTiles,
      children: snapshot.map((data) => _buildListItem(context, data, teamForDefi)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data, Team teamForDefi) {
    final activity = Activity.fromSnapshot(data);

    if (teamForDefi.defisValidated[activity.id] != null) { 
      if (teamForDefi.defisValidated[activity.id] >= activity.numberOfRepetition)
        activity.validatedByUser = true;
      
      activity.userRepetition = teamForDefi.defisValidated[activity.id];
    }


    return DefiCard(
      defi: activity, 
      userForDefi: Provider.of<ApplicationSettings>(context, listen: false).loggedUser,
      teamForDefi: teamForDefi,
    );
  }
}