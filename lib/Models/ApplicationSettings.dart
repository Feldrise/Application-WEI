import 'package:appli_wei/Models/User.dart';
import 'package:flutter/material.dart';

class ApplicationSettings with ChangeNotifier {
  User _loggedUser;

  User get loggedUser => _loggedUser;
  set loggedUser(User newLogin) {
    _loggedUser = newLogin;
    notifyListeners();
  }
}