import 'package:appli_wei/Models/User.dart';
import 'package:flutter/material.dart';

/// These are the application settings. It's with
/// ChangeNotifier to put it in a provider.
/// Currently, the only setting is the logged user
class ApplicationSettings with ChangeNotifier {
  User loggedUser;
}