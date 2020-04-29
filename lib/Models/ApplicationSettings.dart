import 'dart:async';

import 'package:appli_wei/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApplicationSettings with ChangeNotifier {
  User _loggedUser;

  bool _initialized = false;

  
  void initLogin() async {
    if (_initialized)
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
    
    
    initialized = true;
  }

  bool get initialized {
    if (!_initialized) {
      initLogin();
    }

    return _initialized;
  }
  set initialized(bool isInitialized) {
    _initialized = isInitialized;
    notifyListeners();
  }

  User get loggedUser => _loggedUser;
  set loggedUser(User newLogin) {
    _loggedUser = newLogin;
    notifyListeners();
  }

  Future disconnect() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("userId", '');
    _loggedUser = null;

    notifyListeners();
  }
}