import 'package:appli_wei/BottomNavigation.dart';
import 'package:appli_wei/Pages/Home/HomePage.dart';
import 'package:appli_wei/Pages/Profil/ManageChallengesPage.dart';
import 'package:appli_wei/Pages/Profil/ManageTeamsPage.dart';
import 'package:appli_wei/Pages/Profil/ManageUsersPage.dart';
import 'package:appli_wei/Pages/Profil/ProfilPage.dart';
import 'package:appli_wei/Pages/Rank/RanksPage.dart';
import 'package:flutter/material.dart';

class TabNavigatorRoutes {
  // The root page. Could either be home, rank or profile
  static const String root = '/';

  // Pages of the profil
  static const String manageDefis = '/manageDefis';
  static const String manageUsers = '/manageUsers';
  static const String manageTeams = '/manageTeams';
}

/// This class is a wrapper to ensure we can "push" a page 
/// in the appliation without being abobe the wiget with
/// this bottom bar
class TabNavigator extends StatelessWidget {
  TabNavigator({this.navigatorKey, this.tabItem});

  final GlobalKey<NavigatorState> navigatorKey;
  final TabItem tabItem;

  /// This function is called when we need to "push" a page from the current page
  /// The [destinationPage] is the page we want to go and must be in the TabNavgatorRoutes
  void _push(BuildContext context, {String destinationPage}) {
    var routeBuilders = _routeBuilders(context);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => routeBuilders['/' + destinationPage](context),
      ),
    );
  }

  /// We create the builder to return to the main page
  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    // If it's the rank page
    if (tabItem == TabItem.ranks) {
      return {
        TabNavigatorRoutes.root: (context) => RanksPage(
          onPush: (destinationPage) => _push(context, destinationPage: destinationPage),
        ),
      };
    }

    // If it's the profil page
    if (tabItem == TabItem.profil) {
      return {
        TabNavigatorRoutes.root: (context) => ProfilPage(
          onPush: (destinationPage) => _push(context, destinationPage: destinationPage),
        ),
        TabNavigatorRoutes.manageDefis: (context) => ManageChallengesPage(),
        TabNavigatorRoutes.manageUsers: (context) => ManageUsersPage(),
        TabNavigatorRoutes.manageTeams: (context) => ManageTeamsPage(),
      };
    }

    // By default it's the home page
    return {
      TabNavigatorRoutes.root: (context) => HomePage(
          onPush: (destinationPage) => _push(context, destinationPage: destinationPage),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name](context),
        );
      },
    );
  }
}
