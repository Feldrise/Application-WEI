import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  Activity();
  
  String id;

  String name = "";
  String description = "";
  String imageUrl = "";
  int value = 0;

  bool isRepetable = false;
  bool isForTeam = false;

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

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'name': name,
      'description': description,
      'value': value,
      'repetable': isRepetable,
      'is_for_team': isForTeam
    };
  }

  /// This is use to build the object from Firebase
  Activity.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);
}