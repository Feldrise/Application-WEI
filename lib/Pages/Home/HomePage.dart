import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Pages/Home/ChallengesCaptainColumn.dart';
import 'package:appli_wei/Pages/Home/ChallengesPlayerColumn.dart';
import 'package:appli_wei/Pages/Home/TeamChallengesAdminColumn.dart';
import 'package:appli_wei/Pages/Home/TeamChallengesPlayerColumn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

enum HomeTabItem { defis, teamDefis }

Map<HomeTabItem, String> homeTabName = {
  HomeTabItem.defis: "Défis",
  HomeTabItem.teamDefis: "Défis d'équipe"
};

Map<HomeTabItem, int> homeTabIndex = {
  HomeTabItem.defis: 0,
  HomeTabItem.teamDefis: 1
};

/// This is the home page of the application. It conciste in
/// two tabs, one for challenges and one for team challenges
class HomePage extends StatefulWidget {
  const HomePage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;
  
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  void _tabChanged() {
    setState(() {
      // Empty, we simply notify that we need to change the UI 
    });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(_tabChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationSettings>(
      builder: (context, applicationSettings, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("Accueil"),
            bottom: TabBar(
              controller: _tabController,
              tabs: <Widget>[
                _buildItem(HomeTabItem.defis),
                _buildItem(HomeTabItem.teamDefis)
              ],
            ),
          ),
          body: Container(
            child: TabBarView(
              controller: _tabController,
              children: <Widget>[
                (applicationSettings.loggedUser.role == "captain" || applicationSettings.loggedUser.role == "admin") 
                ? ChallengesCaptainColumn()
                : ChallengesPlayerColumn(),

                (applicationSettings.loggedUser.role == "admin")
                ? TeamChallengesAdminColumn()
                : TeamChallengesPlayerColumn(),
              ],
            )
          ),
        );
      },
    );
  }

  _buildItem(HomeTabItem item) {
    return Tab(text: homeTabName[item],);
  }
}