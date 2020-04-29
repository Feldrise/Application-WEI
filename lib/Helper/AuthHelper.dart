import 'package:appli_wei/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class AuthHelper {
  AuthHelper._privateConstructor();
  static final AuthHelper instance = AuthHelper._privateConstructor();

  Future<String> registerUser(User user, String password) async {
    CollectionReference usersCollectionReference = Firestore.instance.collection("users");
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final FirebaseUser firebaseUser = (await auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      )).user;

      if(firebaseUser != null) {
        user.id = firebaseUser.uid;
        
        await firebaseUser.sendEmailVerification();
        await usersCollectionReference.document(user.id).setData(user.toJson());
      }
    } on PlatformException catch(e) {
      return e.message;
    }

    return "Vous avez été correctement enregistré. Veuillez confirmer votre mail puis vous connecter.";
  }

  Future<String> loginUser(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      final FirebaseUser firebaseUser = (await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user;

      // TODO: check email
      // if (firebaseUser != null && firebaseUser.isEmailVerified) {
      if (firebaseUser != null) {
        return firebaseUser.uid;
      }
    } catch (e) {}
    
    return null;
  }
}