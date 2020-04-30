import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    this.firstName,
    this.secondName,
    this.email,
    this.role,
    this.teamId,
    this.defisToValidate,
    this.defisValidated,
    this.id,
  });

  final String firstName;
  final String secondName;
  final String email;
  final String role;

  final String teamId;
  int points = 0;

  final List<dynamic> defisToValidate;
  final Map<dynamic, dynamic> defisValidated;

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
    defisToValidate = map['defis_to_validate'],
    defisValidated = map['defis_validated'];

  /// This allow us to transform the user in Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'second_name': secondName,
      'email': email,
      'role': role,
      'team_id': teamId,
      'points': points,
      'defis_to_validate': defisToValidate,
      'defis_validated': defisValidated
    };
  }

  /// This is use to build the object from Firebase
  User.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);

  ///This function update the user on Firebase
  Future update() async {
    Firestore.instance.collection("users").document(id).setData(toJson());
  }

}