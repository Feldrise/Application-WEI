import 'package:flutter/material.dart';

class WeiCard extends StatelessWidget {
  const WeiCard({
    Key key, 
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    @required this.child
  }) : super(key: key);

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 30.0, // has the effect of softening the shadow
            spreadRadius: 10.0, // has the effect of extending the shadow
            offset: Offset(
              0.0, // horizontal
              0.0, // vertical
            ),
          )
        ],
      ),
      margin: margin,
      child: child,
    );
  }
}