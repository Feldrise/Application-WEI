import 'package:appli_wei/BottomNavigation.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This class is only visible on big screens and represent the 
/// side bar menu

class SidebarMenu extends StatelessWidget {
  SidebarMenu({this.currentTab, this.onSelectTab});

  final TabItem currentTab;
  final ValueChanged<TabItem> onSelectTab;

  @override
  Widget build(BuildContext context) {
    User loggedUser = Provider.of<ApplicationSettings>(context).loggedUser;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      width: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          right: BorderSide( //                    <--- top side
            color: Colors.black26,
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // The user avatar
          Avatar(path: "avatars/${loggedUser.id}",),
          SizedBox(height: 4,),
          // The user name
          Text(
            "${loggedUser.firstName} ${loggedUser.secondName}", 
            textAlign: TextAlign.center, 
            style: Theme.of(context).textTheme.subtitle2,
          ),
          SizedBox(height: 4,),
          // The team
          loggedUser.teamId != null
          ? StreamBuilder<DocumentSnapshot>(
            stream: Firestore.instance.collection("teams").document(loggedUser.teamId).snapshots(),
            builder: (context, teamSnapshot) {
              if (!teamSnapshot.hasData) return LinearProgressIndicator();
              
              return Text("Equipe " + teamSnapshot.data["name"],);
            },
          )
          : Text("Vous n'avez pas encore d'équipe",),
          SizedBox(height: 32,),

          // The menu
          _buildMenuItem(context, tabItem: TabItem.home),
          _buildMenuItem(context, tabItem: TabItem.ranks),
          _buildMenuItem(context, tabItem: TabItem.profil),
        ],
      ),
    );
  }

  /// This function take a [context] and a [tabItem] to return the 
  /// corresponding widget
  Widget _buildMenuItem(BuildContext context, {TabItem tabItem}) {
    String text = tabName[tabItem];
    IconData icon = tabIcon[tabItem];

    Color backgroundColor = tabIndex[currentTab] == tabIndex[tabItem] ? Theme.of(context).accentColor : Theme.of(context).scaffoldBackgroundColor;
    Color textColor = tabIndex[currentTab] == tabIndex[tabItem] ? Colors.white : Colors.black87;

    return GestureDetector(
      onTap: () => onSelectTab(tabItem),

      child: Container( 
        padding: EdgeInsets.symmetric(vertical: 8),
        color: backgroundColor,
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Icon(icon, color: textColor,),
            ),
            Expanded(
              flex: 7,
              child: Text(text, style: TextStyle(color: textColor),),
            )
          ],
        ),
      )
    );
  }
}