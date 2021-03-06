import 'package:flutter/material.dart';

/// This is the default application card
class WeiCard extends StatelessWidget {
  const WeiCard({
    Key key, 
    this.margin = const EdgeInsets.all(8.0),
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
    this.constraints,
    this.color,
    @required this.child
  }) : super(key: key);

  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  final BoxConstraints constraints;

  final Color color;

  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        color: color == null ? Theme.of(context).cardColor : color,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 50.0, // has the effect of softening the shadow
            spreadRadius: 5.0, // has the effect of extending the shadow
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