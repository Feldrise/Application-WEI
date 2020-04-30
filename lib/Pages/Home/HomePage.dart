import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Pages/Home/DefisCaptainColunm.dart';
import 'package:appli_wei/Pages/Home/DefisPlayerColumn.dart';
import 'package:appli_wei/Pages/Home/TeamDefisAdminColumn.dart';
import 'package:appli_wei/Pages/Home/TeamDefisPlayerColumn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// We define some convenience things for the tabs
enum HomeTabItem { defis, teamDefis }

Map<HomeTabItem, String> homeTabName = {
  HomeTabItem.defis: "Défis",
  HomeTabItem.teamDefis: "Défis d'équipe"
};

Map<HomeTabItem, int> homeTabIndex = {
  HomeTabItem.defis: 0,
  HomeTabItem.teamDefis: 1
};

/** 
 * Cette page correspond à la page d'accueil.
 * Seul les capitaines pourront valider les défis 
 *
 * Cette page affiche et dois récupérer : 
 * [Pour les utilisateurs]
 *  - Les défis de l'utilisateurs
 *  - Les défis d'équipes
 * [Pour les capitaines]
 * - Les défis des utilisateurs de l'équipe **qui sont à valider**
 * - Les défis d'équipes
 * [Pour les administrateurs]
 *  - Les défis des utilisateurs de toutes les équipes AVEC LE TITRE DE L'EQUIPE qui sont à valider
 *  - Les défis d'équipes
 */
class HomePage extends StatefulWidget {
  const HomePage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;
  
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
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
                ? DefisCaptainColumn()
                : DefisPlayerColumn(),

                (applicationSettings.loggedUser.role == "admin")
                ? TeamDefisAdminColumn()
                : TeamDefisPlayerColumn(),
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