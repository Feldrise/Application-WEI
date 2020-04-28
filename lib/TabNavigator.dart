import 'package:appli_wei/BottomNavigation.dart';
import 'package:appli_wei/Pages/HomePage.dart';
import 'package:appli_wei/Pages/ProfilPage.dart';
import 'package:appli_wei/Pages/RanksPage.dart';
import 'package:flutter/material.dart';

class TabNavigatorRoutes {
  static const String root = '/';
}

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
