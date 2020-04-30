import 'dart:async';

import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'User.dart';

class AuthService with ChangeNotifier {
  var _loggedUser;

  bool _initialized = false;

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
  
  Future disconnect(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", '');
    Provider.of<ApplicationSettings>(context, listen: false).loggedUser = null;

    _loggedUser = null;

    notifyListeners();
  }

  Future getUser() async{
    if (_loggedUser == null && !_initialized)
      await initLogin();

    return Future.value(_loggedUser);
  }

  Future setUser(User newUser) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", newUser.id);

    _loggedUser = newUser;
    notifyListeners();
  }
}