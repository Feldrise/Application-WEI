import 'package:cloud_firestore/cloud_firestore.dart';

class Activity {
  Activity();

  String id;

  String name = "";
  String description = "";
  String imageUrl = "";
  
  int value = 0;
  int numberOfRepetition = 1;

  bool isForTeam = false;
  bool isVisible = false;

  bool validatedByUser = false;
  bool pendingValidation = false;
  int userRepetition = 0;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  Activity.fromMap(Map<String, dynamic> map, {this.id}) :
    name = map['name'],
    description = map['description'],
    imageUrl = map['image_url'],
    value = map['value'],
    numberOfRepetition = map['number_of_repetition'],
    isForTeam = map['is_for_team'],
    isVisible = map['visible'];

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'name': name,
      'description': description,
      'value': value,
      'number_of_repetition': numberOfRepetition,
      'is_for_team': isForTeam,
      'visible': isVisible
    };
  }

  /// This is use to build the object from Firebase
  Activity.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);
}