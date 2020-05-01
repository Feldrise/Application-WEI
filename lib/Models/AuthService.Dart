import 'dart:async';

import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:flutter/services.dart';

import 'User.dart';

/// This class allow the appliation to manage user authentification
/// and notify the app when the main screen should be changed
class AuthService with ChangeNotifier {
  var _loggedUser;

  bool _initialized = false;

  /// This functions try to register a user to Firebase.
  /// Since we don't want to store passwords in user objects,
  /// it take it separatrly
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

  /// At the beging of the application, we need to try
  /// to get users data from registered user in settings.
  /// 
  /// That allows to not have to reconnect every time we 
  /// start the application
  Future initLogin() async {
    if (_loggedUser != null || _initialized)
      return;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userId = prefs.getString("userId") ?? '';

    if (userId.isNotEmpty) {
      Completer completer = new Completer<User>();
      
      Firestore.instance.collection('users').document(userId).snapshots().listen((snapshot) {
        completer.complete(User.fromSnapshot(snapshot));
      });

      _loggedUser = await completer.future;
    }

    _initialized = true;
  }

  /// This function get the firebase user and if successful
  /// put the user in the logged user (notifing the change to 
  /// the application)
  Future<String> loginUser(String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    String errorMessage = ''; // We might have exception from Firebase

    try {
      final FirebaseUser firebaseUser = (await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )).user;

      // TODO: check email
      // When we can have the Firebase user, we still need to get our own internal user
      // if (firebaseUser != null && firebaseUser.isEmailVerified) {
      if (firebaseUser != null) {
        Completer completer = new Completer<User>();
      
        Firestore.instance.collection('users').document(firebaseUser.uid).snapshots().listen((snapshot) {
          completer.complete(User.fromSnapshot(snapshot));
        });

        _loggedUser = await completer.future;

        // If the user doesn't have team, we can't connect (except for admins)
        if (_loggedUser.teamId == null && _loggedUser.role != "admin") {
          _loggedUser = null;
          return "Désolé, vous n'avez pas encore d'équipe. Merci de réessayer plus tard.";
        }

        notifyListeners(); // We only notify listener for successful connections
        return "Success";
      }
    } on PlatformException catch(e) {
      errorMessage = e.message;
    }
    
    return "Erreur lors de la connexion. Vérifiez que vous avez entré le bon mot de passe, la bonne adresse mail et que vous l'avez vérifié.\n$errorMessage";
  }

  
  /// This function allows to disconnect the user. It take a
  /// [context] to ensure we remove the user from application 
  /// logged user setting
  Future disconnect(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", '');
    Provider.of<ApplicationSettings>(context, listen: false).loggedUser = null;

    _loggedUser = null;

    notifyListeners();
  }

  /// We return the possible connected user.
  /// If it return null, then we are not connected
  Future getUser() async{
    if (_loggedUser == null && !_initialized)
      await initLogin();

    return Future.value(_loggedUser);
  }
}