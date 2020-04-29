import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Pages/Home/DefiDetailPage.dart';
import 'package:appli_wei/Pages/Profil/EditDefi.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:flutter/material.dart';

class DefiCard extends StatelessWidget {
  const DefiCard({Key key, @required this.defi, this.userForDefis, this.isManaged = false}) : super(key: key);

  final Activity defi;

  final User userForDefis;

  final bool isManaged;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      padding: EdgeInsets.all(0),
      constraints: BoxConstraints(maxWidth: 174),
      child: Stack(
        children: <Widget>[
          WeiCard(
            margin: EdgeInsets.only(top: 64),
            padding: EdgeInsets.only(top: 84, left: 8, right: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(defi.name, style: Theme.of(context).textTheme.subhead,),
                Expanded(
                  child: Text(defi.description,),
                ),
                Visibility(
                  visible: !isManaged,
                  child: FlatButton(
                    child: Text("Détails", style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: () async {
                      print("Défis détails required");
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DefiDetailPage(defi: defi, userForDefi: userForDefis,)),
                      );
                    },
                  )
                ),
                Visibility(
                  visible: isManaged,
                  child: FlatButton(
                    child: Text("Modifier", style: TextStyle(color: Theme.of(context).accentColor),),
                    onPressed: () async {
                      print("Défis détails required");
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditDefi(defi: defi,)),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
          Positioned(
            left: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4.0, // has the effect of softening the shadow
                    spreadRadius: 1, // has the effect of extending the shadow
                    offset: Offset(
                      0.0, // horizontal
                      4.0, // vertical
                    ),
                  )
                ],
              ),
              child: Stack(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.network(
                      defi.imageUrl,
                      height: 128,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  Visibility(
                    visible: defi.validatedByUser, 
                    child: Center(
                      child: Image(
                        image: AssetImage("assets/images/check.png"),
                        height: 128,
                        fit: BoxFit.fitHeight,
                      )
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}