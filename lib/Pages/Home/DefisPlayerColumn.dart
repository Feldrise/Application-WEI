import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Widgets/DefiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class DefisPlayerColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('activities').snapshots(),
      builder: (context, snapshot) {
        List<DocumentSnapshot> defisSnapshot = [];
        if (!snapshot.hasData) return LinearProgressIndicator();

        for (DocumentSnapshot activitySnapshot in snapshot.data.documents) {
          if (activitySnapshot.data['is_for_team'] || !activitySnapshot.data['visible']) 
            continue;

          defisSnapshot.add(activitySnapshot);
        }

        return _buildList(context, defisSnapshot);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    List<StaggeredTile> _staggeredTiles = [];

    for (int i = 0; i < snapshot.length; ++i) {
      _staggeredTiles.add(StaggeredTile.extent(2, i.isEven ? 264 : 300));
    }

    return StaggeredGridView.count(
      crossAxisCount: 4,
      staggeredTiles: _staggeredTiles,
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final activity = Activity.fromSnapshot(data);

    if (Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisToValidate.contains(activity.id)) 
      activity.pendingValidation = true;

    if (Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisValidated.contains(activity.id)) 
      activity.validatedByUser = true;

    return DefiCard(defi: activity,);
  }
}