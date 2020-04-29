import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Pages/Home/DefiDetailPage.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:flutter/material.dart';

class DefiCard extends StatelessWidget {
  const DefiCard({Key key, @required this.defi, this.userForDefis}) : super(key: key);

  final Activity defi;

  final User userForDefis;
  
  @override
  Widget build(BuildContext context) {
    return WeiCard(
      margin: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      padding: EdgeInsets.all(0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: <Widget>[
              Image.network(
                defi.imageUrl,
                height: 128,
                fit: BoxFit.fitWidth,
              ),
              Visibility(
                visible: defi.validatedByUser, 
                child: Center(
                  child: Image(
                    image: AssetImage("assets/images/check.png"),
                    height: 128,
                    fit: BoxFit.fitWidth,
                  )
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(defi.name, style: Theme.of(context).textTheme.subhead,),
                Container(
                  height: 64,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Text(defi.description,),
                ),
                FlatButton(
                  child: Text("Détails", style: TextStyle(color: Theme.of(context).accentColor),),
                  onPressed: () async {
                    print("Défis détails required");
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DefiDetailPage(defi: defi, userForDefi: userForDefis,)),
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}