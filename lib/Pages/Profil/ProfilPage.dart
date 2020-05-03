import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/AuthService.Dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

// import 'package:universal_html/prefer_universal/html.dart' as html;
// import 'package:firebase/firebase.dart' as fb;


/// This page shows every informations for the current
/// player. It also shows some control button (like 
/// change profil picture, etc.) and the access to 
/// managment pannels for administrateur
class ProfilPage extends StatefulWidget {
  const ProfilPage({Key key, @required this.onPush}) : super(key: key);
  
  final ValueChanged<String> onPush;

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ApplicationSettings>(
      builder: (context, appliationSettings, child) {
        User currentUser = appliationSettings.loggedUser;

        return Scaffold(
          appBar: AppBar(
            title: Text("Profil"),
          ),
          body: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // The main bar of the profil page
                // It show the avatar, the name and 
                // the team
                if (MediaQuery.of(context).size.width <= 600)
                  Container(
                    color: Theme.of(context).accentColor,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start, 
                      children: <Widget>[
                        Avatar(path: 'avatars/${appliationSettings.loggedUser.id}',),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text("${currentUser.firstName} ${currentUser.secondName}", style: Theme.of(context).textTheme.subtitle2.merge(TextStyle(color: Colors.white)),),
                              
                              currentUser.teamId != null
                              ? StreamBuilder<DocumentSnapshot>(
                                stream: Firestore.instance.collection("teams").document(currentUser.teamId).snapshots(),
                                builder: (context, teamSnapshot) {
                                  if (!teamSnapshot.hasData) return LinearProgressIndicator();
                                  
                                  return Text("Equipe " + teamSnapshot.data["name"], style: TextStyle(color: Colors.white),);
                                },
                              )
                              : Text("Vous n'avez pas encore d'équipe", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                
                // The main section of the page
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        // The user's number of points
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.whatshot, size: 128,),
                              Text("${currentUser.points} points", style: Theme.of(context).textTheme.subtitle2,)
                            ],
                          ),
                        ),

                        // A deconnection button
                        RaisedButton(
                          child: const Text('Déconnexion', style: TextStyle(color: Colors.white),),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            await Provider.of<AuthService>(context, listen: false).disconnect(context);
                          },
                        ),

                        // A "change team profil picture" 
                        // Only visible for captains and admin
                        Visibility(
                          visible: (appliationSettings.loggedUser.role == 'captain' || appliationSettings.loggedUser.role == 'admin') && (appliationSettings.loggedUser.teamId != null || appliationSettings.loggedUser.teamId.isEmpty),
                          child: RaisedButton(
                            child: const Text("Changer l'avatar de mon équipe", style: TextStyle(color: Colors.white),),
                            color: Theme.of(context).accentColor,
                            onPressed: () async {
                              if (kIsWeb) {
                                await _updateTeamPictureHtml(appliationSettings.loggedUser.teamId);
                              }
                              else {
                                await _updateTeamPicture(appliationSettings.loggedUser.teamId);
                              }
                            },
                          ),
                        ),

                        // The basic controls (change profil picture
                        // and reset password)
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Changer la photo de profil', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    if (kIsWeb) {
                                      await _updateProfilePictureHtml(appliationSettings.loggedUser.id);
                                    }
                                    else {
                                      await _updateProfilePicture(appliationSettings.loggedUser.id);
                                    }
                                  },
                                ),
                              ),
                              SizedBox(width: 4,),
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Changer son mot de passe', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: null
                                ),
                              )
                            ]
                        ),

                        // The admin control row. Gives access to
                        // - the challenges manage page
                        // - the teams manage page
                        // - the users manage page
                        Visibility(
                          visible: currentUser.role == "admin",
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Gérer les défis', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    widget.onPush("manageDefis");
                                  },
                                ),
                              ),
                              SizedBox(width: 4,),
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Gérer les joueurs', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    widget.onPush("manageUsers");
                                  },
                                ),
                              ),
                              SizedBox(width: 4,),
                              Expanded(
                                child: RaisedButton(
                                  child: const Text('Gérer les équipes', textAlign: TextAlign.center, style: TextStyle(color: Colors.white),),
                                  color: Theme.of(context).accentColor,
                                  onPressed: () async {
                                    widget.onPush("manageTeams");
                                  },
                                ),
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )
          ),
        );
      },
    );
  }

  /// The function upload profil picture to Firebase for the [userId]
  Future _updateProfilePicture(String userId) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      StorageReference storageReference = FirebaseStorage.instance.ref().child('avatars/$userId');    
      StorageUploadTask uploadTask = storageReference.putFile(image);    
      await uploadTask.onComplete;  
              
      setState(() {});  
    }  
  }


  /// The function upload profil picture to Firebase for the [teamId]
  Future _updateTeamPicture(String teamId) async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      StorageReference storageReference = FirebaseStorage.instance.ref().child('avatars/teams/$teamId');    
      StorageUploadTask uploadTask = storageReference.putFile(image);    
      await uploadTask.onComplete;  
              
      setState(() {});  
    }    
  }

  /// This is the same function as _updateProfilePicture but for the web app
  Future _updateProfilePictureHtml(String userId) async {
    // // FIREBASE_WEB Comment this out when running web version
    // final html.InputElement input = html.document.createElement('input');

    // input..type = 'file'..accept = 'image/*';

    // input.onChange.listen((e) async {
    //   if (input.files == null || input.files[0] == null)
    //     return;

    //   final List<html.File> files = input.files;

    //   fb.StorageReference storageRef = fb.storage().ref('avatars/$userId');
    //   await storageRef.put(files[0]).future;

    //   setState(() {});  
    // });

    // input.click();
    
  }

  /// This is the same function as _updateTeamPicture but for the web app
  Future _updateTeamPictureHtml(String teamId) async {
    // // FIREBASE_WEB Comment this out when running web version
    // final html.InputElement input = html.document.createElement('input');

    // input..type = 'file'..accept = 'image/*';

    // input.onChange.listen((e) async {
    //   if (input.files == null || input.files[0] == null)
    //     return;

    //   final List<html.File> files = input.files;

    //   fb.StorageReference storageRef = fb.storage().ref('avatars/teams/$teamId');
    //   await storageRef.put(files[0]).future;

    //   setState(() {});  
    // });

    // input.click();
    
  }
}