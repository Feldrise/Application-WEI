import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  final String id;

  final String name;
  final String description;
  final String imageUrl;
  final int value;

  final bool isRepetable;
  final bool isForTeam;

  bool validatedByUser = false;
  bool pendingValidation = false;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  Activity.fromMap(Map<String, dynamic> map, {this.id}) :
    name = map['name'],
    description = map['description'],
    imageUrl = map['image_url'],
    value = map['value'],
    isRepetable = map['repetable'],
    isForTeam = map['is_for_team'];


  /// This is use to build the object from Firebase
  Activity.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);
}