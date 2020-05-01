import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  const Avatar({
    Key key, 
    this.size = 92,
    this.backgroundColor = Colors.black,
    @required this.path,
  }) : super(key: key);

  final double size;
  final String path;

  final Color backgroundColor;

  @override
  AvatarState createState() => AvatarState();
}

class AvatarState extends State<Avatar> {
  String _avatarUrl = '';

  @override
  Widget build(BuildContext context) {
    // FirebaseStorage.instance.ref().child(widget.path).getDownloadURL().then((foundUrl) {
    //   setState(() {
    //     _avatarUrl = foundUrl;
    //   });
    // });
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      height: widget.size,
      width: widget.size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(widget.size / 2),
        color: widget.backgroundColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: _avatarUrl.isEmpty 
        ? Image(
          image: AssetImage('assets/images/logo_white.png'),
          fit: BoxFit.cover,
        ) 
        : Image.network(
          _avatarUrl,
          fit: BoxFit.cover,
        ) 
      ),
    );
  }
}