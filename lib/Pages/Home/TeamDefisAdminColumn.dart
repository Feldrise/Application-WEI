
import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/DefiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeamDefisAdminColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Consumer<ApplicationSettings>(
        builder: (context, applicationSetting, child) {
          return StreamBuilder<QuerySnapshot>(
            stream: Firestore.instance.collection('teams').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return LinearProgressIndicator();
 
              // We add all pending defis in a column
              List<Widget> defisWidget = [];

              // We browse users
              for (DocumentSnapshot teamSnapshot in snapshot.data.documents) {
                defisWidget.add(
                  StreamBuilder<DocumentSnapshot>(
                    stream: Firestore.instance.collection('users').document(teamSnapshot.data['captain_id']).snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) return LinearProgressIndicator();

                      // We check user 
                      User userForDefis = User.fromSnapshot(userSnapshot.data);

                      // We construct the list with the pending defis for user
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 8, top: 8),
                            child: Text(teamSnapshot.data['name'], style: Theme.of(context).textTheme.subhead,),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: Firestore.instance.collection('activities').snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return LinearProgressIndicator();

                              List<DocumentSnapshot> defisSnapshot = [];
                              if (!snapshot.hasData) return LinearProgressIndicator();

                              // We only want's defis to validate for user
                              for (DocumentSnapshot activitySnapshot in snapshot.data.documents) {
                                if (!activitySnapshot.data['is_for_team']) 
                                  continue;

                                defisSnapshot.add(activitySnapshot);
                              }

                              return _buildListForUser(context, defisSnapshot, userForDefis);
                            },
                          )   
                        ],
                      );
                    },
                  )
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: defisWidget,
              );
            },
          );
        },
      )
    );
  }

  Widget _buildListForUser(BuildContext context, List<DocumentSnapshot> snapshot, User userForDefis) {
    return Container(
      height: 372,
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        children: snapshot.map((data) => _buildListItem(context, data, userForDefis)).toList(),
      )
    );
  }
  
  Widget _buildListItem(BuildContext context, DocumentSnapshot data, User userForDefis) {
    final activity = Activity.fromSnapshot(data);

    if (Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisToValidate.contains(activity.id)) 
      activity.pendingValidation = true;

    if (Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisValidated.contains(activity.id)) 
      activity.validatedByUser = true;

    return DefiCard(defi: activity, userForDefis: userForDefis,);
  }
}