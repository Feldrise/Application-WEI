import 'package:flutter/material.dart';

class WeiTitle extends StatelessWidget {
  const WeiTitle({Key key, @required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).accentColor,
      padding: EdgeInsets.symmetric(vertical: 24),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Image(
            image: AssetImage('assets/logo_white.png'),
            height: 64,
          ),
          SizedBox(height: 16,),
          Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.title.merge(TextStyle(color: Colors.white)),)
        ],
      )
    );
  }
}