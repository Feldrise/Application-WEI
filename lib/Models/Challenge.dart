import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represent a challenge. We get them from Firebase 
/// in the "activities" collection
class Challenge {
  Challenge();

  String id;

  String name = "";
  String description = "";
  String imageUrl = "";
  
  int value = 0;
  int numberOfRepetition = 1;

  bool isForTeam = false;
  bool isVisible = false;

  // This variables don't come from Firebase. They are 
  // here only for display purpose
  bool validatedByUser = false;
  bool pendingValidation = false;
  int userRepetition = 0;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  Challenge.fromMap(Map<String, dynamic> map, {this.id}) :
    name = map['name'],
    description = map['description'],
    imageUrl = map['image_url'],
    value = map['value'],
    numberOfRepetition = map['number_of_repetition'],
    isForTeam = map['is_for_team'],
    isVisible = map['visible'];

  /// This is use to return a Json object with the 
  /// current data
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
  Challenge.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);

  ///This function update the challenge on Firebase
  Future update() async {
    await Firestore.instance.collection("activities").document(id).setData(toJson());
  }
}