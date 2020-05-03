import 'package:appli_wei/Pages/Rank/RankPlayersColumn.dart';
import 'package:appli_wei/Pages/Rank/RankTeamsColunm.dart';
import 'package:flutter/material.dart';

// We define some convenience things for the tabs
enum RankTabItem { players, teams }

Map<RankTabItem, String> rankTabName = {
  RankTabItem.players: "Joueurs",
  RankTabItem.teams: "Equipes"
};

Map<RankTabItem, int> rankTabIndex = {
  RankTabItem.players: 0,
  RankTabItem.teams: 1
};

/// This is the rank page of the application. It conciste in
/// two tabs, one for players rank and one for teams rank
class RanksPage extends StatefulWidget {
  const RanksPage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;

  @override
  _RanksPageState createState() => _RanksPageState();
}

class _RanksPageState extends State<RanksPage> with SingleTickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Classement"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide( //                    <--- top side
                  color: Colors.black26,
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              labelColor: Theme.of(context).accentColor,
              indicatorColor: Theme.of(context).accentColor,
              controller: _tabController,
              tabs: <Widget>[
                _buildItem(RankTabItem.players),
                _buildItem(RankTabItem.teams)
              ],
            ),
          ),

          Expanded(
            child: Container(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  RankPlayersColumn(),
                  RankTeamsColumn(),
                ],
              )
            ),
          )
        ],
      )
    );
  }

  _buildItem(RankTabItem item) {
    return Tab(text: rankTabName[item],);
  }
}