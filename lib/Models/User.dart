import 'package:cloud_firestore/cloud_firestore.dart';

/// This class represent a user. We get them from Firebase 
/// in the "users" collection
class User {
  User({
    this.firstName,
    this.secondName,
    this.email,
    this.role,
    this.teamId,
    this.challengesToValidate,
    this.challengesValidated,
    this.id,
  });

  final String firstName;
  final String secondName;
  final String email;
  final String role;

  final String teamId;
  int points = 0;

  final List<dynamic> challengesToValidate;
  final Map<dynamic, dynamic> challengesValidated;

  String id;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  User.fromMap(Map<String, dynamic> map, {this.id}) :
    firstName = map['first_name'],
    secondName = map['second_name'],
    email = map['email'],
    role = map['role'],
    teamId = map['team_id'],
    points = map['points'],
    challengesToValidate = map['defis_to_validate'],
    challengesValidated = map['defis_validated'];

  /// This is use to return a Json object with the 
  /// current data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'second_name': secondName,
      'email': email,
      'role': role,
      'team_id': teamId,
      'points': points,
      'defis_to_validate': challengesToValidate,
      'defis_validated': challengesValidated
    };
  }

  /// This is use to build the object from Firebase
  User.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);

  ///This function update the user on Firebase
  Future update() async {
    await Firestore.instance.collection("users").document(id).setData(toJson());
  }

  /// This function update only some date for the user on Firebase
  Future updateData(Map<String, dynamic> data) async {
    assert(id != null && id.isNotEmpty);
    
    await Firestore.instance.collection("users").document(id).updateData(data);
  }

}