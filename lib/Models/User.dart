import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  User({
    this.firstName,
    this.secondName,
    this.email,
    this.role,
    this.id,
  });

  final String firstName;
  final String secondName;
  final String email;
  final String role;

  String id;

  /// This is use to build the object from 
  /// a [map] (generally comming from databases)
  User.fromMap(Map<String, dynamic> map, {this.id}) :
    firstName = map['first_name'],
    secondName = map['second_name'],
    email = map['email'],
    role = map['role'];

  /// This allow us to transform the user in Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'second_name': secondName,
      'email': email,
      'role': role
    };
  }

  /// This is use to build the object from Firebase
  User.fromSnapshot(DocumentSnapshot snapshot) : this.fromMap(snapshot.data, id: snapshot.reference.documentID);

}