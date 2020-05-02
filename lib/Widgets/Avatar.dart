import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:firebase/firebase.dart' as fb;

/// This widget is a widget who try to get
/// the profil picture from Firebase and
/// show the application logo by default
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
  _AvatarState createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  String _avatarUrl = '';

  @override
  Widget build(BuildContext context) {
    // On web app, we need to use the Firebase plugin
    if (kIsWeb) {
      // FIREBASE_WEB Comment this out when running web version
      // fb.storage().ref(widget.path).getDownloadURL().then((foundUrl) {
      //   setState(() {
      //     _avatarUrl = foundUrl.toString();
      //   });
      // });
    }
    else {
      FirebaseStorage.instance.ref().child(widget.path).getDownloadURL().then((foundUrl) {
        setState(() {
          _avatarUrl = foundUrl;
        });
      });
    }
    
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