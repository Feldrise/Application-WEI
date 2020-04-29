import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Pages/Profil/EditDefi.dart';
import 'package:appli_wei/Widgets/DefiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ManageDefisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Gestion des défis"),
      ),
      body: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance.collection('activities').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            List<DocumentSnapshot> teamDefisSnapshot = [];
            List<DocumentSnapshot> defisSnapshot = [];

            for (DocumentSnapshot activitySnapshot in snapshot.data.documents) {
              if (activitySnapshot.data['is_for_team']) 
                teamDefisSnapshot.add(activitySnapshot);
              else 
                defisSnapshot.add(activitySnapshot);
            }


            return _buildList(context, teamDefisSnapshot + defisSnapshot);
          },
        )
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Ajouter",
        child: Icon(Icons.add, color: Colors.white,),
        onPressed: () async {
          print("Add new defi");

          Activity defiToAdd = new Activity();

          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditDefi(defi: defiToAdd,)),
          );
        },
      ),
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

    return DefiCard(defi: activity, isManaged: true,);
  }
}