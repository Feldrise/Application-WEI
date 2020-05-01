import 'package:flutter/material.dart';

enum TabItem { home, ranks, profil }

Map<TabItem, String> tabName = {
  TabItem.home: "Accueil",
  TabItem.ranks: "Classements",
  TabItem.profil: "Profil",
};

Map<TabItem, IconData> tabIcon = {
  TabItem.home: Icons.home,
  TabItem.ranks: Icons.whatshot,
  TabItem.profil: Icons.person
};

Map<TabItem, int> tabIndex = {
  TabItem.home: 0,
  TabItem.ranks: 1,
  TabItem.profil: 2
};

/// This is the bottom navigation bar of the application
class BottomNavigation extends StatelessWidget {
  BottomNavigation({this.currentTab, this.onSelectTab});

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
      ),
      margin: EdgeInsets.all(0),
      height: 64,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: tabIndex[currentTab],
          items: [
            _buildItem(context, tabItem: TabItem.home),
            _buildItem(context, tabItem: TabItem.ranks),
            _buildItem(context, tabItem: TabItem.profil),
          ],
          onTap: (index) => onSelectTab(
            TabItem.values[index],
          ),
          backgroundColor: Theme.of(context).accentColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          iconSize: 24,
          elevation: 0,
        ),
      ),
    );
  }

  /// This function take a [context] and a [tabItem] to return the 
  /// corresponding widget
  BottomNavigationBarItem _buildItem(BuildContext context, {TabItem tabItem}) {
    String text = tabName[tabItem];
    IconData icon = tabIcon[tabItem];
    return BottomNavigationBarItem(
      icon: Icon(
        icon
      ),
      title: Text(
        text
      ),
    );
  }
}