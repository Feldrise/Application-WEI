import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Widgets/DefiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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

        return _buildList(context, defisSnapshot);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        childAspectRatio: 6 / 11,
      ),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final activity = Activity.fromSnapshot(data);

    if (Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisToValidate.contains(activity.id)) 
      activity.pendingValidation = true;

    if (Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisValidated.contains(activity.id)) 
      activity.validatedByUser = true;

    return DefiCard(defi: activity, userForDefis: Provider.of<ApplicationSettings>(context, listen: false).loggedUser,);
  }
}