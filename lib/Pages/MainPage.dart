
import 'package:appli_wei/BottomNavigation.dart';
import 'package:appli_wei/SidebarMenu.dart';
import 'package:appli_wei/TabNavigator.dart';
import 'package:flutter/material.dart';

/// This is simply the main page of our application. This page
/// is in charge to switch pages from the bottom navigation bar.
class MainPage extends StatefulWidget {
  
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  
  Map<TabItem, GlobalKey<NavigatorState>> _navigatorKeys = {
    TabItem.home: GlobalKey<NavigatorState>(),
    TabItem.ranks: GlobalKey<NavigatorState>(),
    TabItem.profil: GlobalKey<NavigatorState>(),
  };

  TabItem _currentTab = TabItem.home;

  void _selectTab(TabItem tabItem) {
    if (tabItem == _currentTab) {
      // pop to first route
      _navigatorKeys[tabItem].currentState.popUntil((route) => route.isFirst);
    } else {
      setState(() => _currentTab = tabItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab =
            !await _navigatorKeys[_currentTab].currentState.maybePop();
        if (isFirstRouteInCurrentTab) {
          // if not on the 'main' tab
          if (_currentTab != TabItem.home) {
            // select 'main' tab
            _selectTab(TabItem.home);

            // back button handled by app
            return false;
          }
        }
        // let system handle back button if we're on the first route
        return isFirstRouteInCurrentTab;
      },
      child: LayoutBuilder(
        builder: (context, constraint) {
          return Scaffold(
            body: Row(
              children: <Widget>[
                if (constraint.maxWidth > 600)
                  SidebarMenu(
                    currentTab: _currentTab,
                    onSelectTab: _selectTab,
                  ),

                Expanded(
                  child: Stack(
                    children: <Widget>[
                      _buildOffstageNavigator(TabItem.home),
                      _buildOffstageNavigator(TabItem.ranks),
                      _buildOffstageNavigator(TabItem.profil),
                    ]
                  ),
                ),
              ]
            ),
            bottomNavigationBar: constraint.maxWidth > 600 ? null : BottomNavigation(
              currentTab: _currentTab,
              onSelectTab: _selectTab,
            ),
          );
        },
      )
    );
  }

  /// We return the page corresponding to the [tabItem]
  Widget _buildOffstageNavigator(TabItem tabItem) {
    return Offstage(
      offstage: _currentTab != tabItem,
      child: TabNavigator(
        navigatorKey: _navigatorKeys[tabItem],
        tabItem: tabItem,
      ),
    );
  }
}