import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represent a team. We get them from Firebase 
/// in the "teams" collection
class Team {
  Team({
    this.name = '',
    this.captainId = '',
    this.points = 0,
    this.challengesValidated,
    this.id,
  });

  String name;
  String captainId;

  bool captainIsAdmin = false; // This is only for display purpose

  final int points;
  final Map<dynamic, dynamic> challengesValidated;

  String id;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  Team.fromMap(Map<String, dynamic> map, {this.id}) :
    name = map['name'],
    captainId = map['captain_id'],
    points = map['points'],
    challengesValidated = map['defis_validated'];

  /// This is use to return a Json object with the 
  /// current data
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'captain_id': captainId,
      'points': points,
      'defis_validated': challengesValidated
    };
  }

  /// This is use to build the object from Firebase
  Team.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);

  ///This function update the team on Firebase
  Future update() async {
    await Firestore.instance.collection("teams").document(id).setData(toJson());
  }

  /// This function update only some date for the team on Firebase
  Future updateData(Map<String, dynamic> data) async {
    assert(id != null && id.isNotEmpty);

    await Firestore.instance.collection("teams").document(id).updateData(data);
  }
}