import 'package:cloud_firestore/cloud_firestore.dart';

class Team {
  Team({
    this.name = '',
    this.captainId = '',
    this.points = 0,
    this.defisValidated,
    this.id,
  });

  String name;
  String captainId;

  bool captainIsAdmin = false;

  final int points;
  final Map<dynamic, dynamic> defisValidated;

  String id;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  Team.fromMap(Map<String, dynamic> map, {this.id}) :
    name = map['name'],
    captainId = map['captain_id'],
    points = map['points'],
    defisValidated = map['defis_validated'];

  /// This allow us to transform the user in Json
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'captain_id': captainId,
      'points': points,
      'defis_validated': defisValidated
    };
  }

  /// This is use to build the object from Firebase
  Team.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);

}