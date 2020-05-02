import 'dart:async';

import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/Avatar.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:universal_html/prefer_universal/html.dart' as html;
// import 'package:firebase/firebase.dart' as fb;

/// This is a form to update a team
class EditTeam extends StatefulWidget {
  const EditTeam({Key key, @required this.team}) : super(key: key);
  
  final Team team;
  
  @override
  _EditTeamState createState() => _EditTeamState();
}

class _EditTeamState extends State<EditTeam> {
  final _formKey = GlobalKey<FormState>();

  String _initialCaptainId = '';
  bool _updating = false;

  @override
  void initState() {
    super.initState();

    _initialCaptainId = widget.team.captainId;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edition d'une équipe"),
      ),
      body: Container(
        child: _updating ? Center(child: CircularProgressIndicator()) : Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                WeiCard(
                  margin: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                  child: Column(
                    children: <Widget>[
                      Center(child: Avatar(path: 'avatars/teams/${widget.team.id}', backgroundColor: Theme.of(context).accentColor,),),
                      TextFormField(
                        initialValue: widget.team.name,
                        decoration: InputDecoration(labelText: "Nom de l'équipe"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez un nom à l'équipe.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.team.name = value,
                      ),
                      
                      StreamBuilder<QuerySnapshot>(
                        stream: Firestore.instance.collection("users").snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return LinearProgressIndicator();

                          List<DocumentSnapshot> possibleCaptains = [];

                          for (DocumentSnapshot userSnasphot in snapshot.data.documents) {
                            if (userSnasphot.data['role'] == "captain" && userSnasphot.documentID != _initialCaptainId) 
                              continue;
                            
                            possibleCaptains.add(userSnasphot);
                          }

                          return _buildDropdown(context, possibleCaptains);
                        },
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child:RaisedButton(
                    child: const Text("Importer un avatar", style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: (kIsWeb) ? _updateTeamPictureHtml : _updateTeamPicture
                  ),
                ),

                // We only show remove button for existing challenge
                Visibility(
                  visible: widget.team.id != null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: RaisedButton(
                      child: const Text("Supprimer l'équipe...", style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        await _deleteTeam();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        )
      ), 
      floatingActionButton: FloatingActionButton(
        tooltip: "Sauvegarder",
        child: Icon(Icons.check, color: Colors.white,),
        backgroundColor: Colors.green,
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            
            // We update the UI to show the progress indicator
            setState(() {
              _updating = true;
            });

            await _saveTeamToFirebase();
            
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
  }

  /// This function build a dropdown with the list of the users in the [snapshot]
  Widget _buildDropdown(BuildContext context, List<DocumentSnapshot> snapshot) {
    return DropdownButton(
      hint: Text("Veuillez choisir une équipe"),
      onChanged: (newValue) {
        setState(() {
          widget.team.captainId = newValue;
        });
      },
      value: widget.team.captainId.isEmpty ? null : widget.team.captainId,
      items: snapshot.map((data) => _buildDropdownItem(context, data)).toList(),
    );
  }
  
  /// This function build a dropdown item from the [data] provided
  DropdownMenuItem _buildDropdownItem(BuildContext context, DocumentSnapshot data) {
    return DropdownMenuItem(
      child: Text(data["first_name"] + ' ' + data['second_name']),
      value: data.documentID,
    );
  }

  /// This function save the team to Firebase
  Future _saveTeamToFirebase() async {
    CollectionReference teamsCollectionReference = Firestore.instance.collection("teams");
    CollectionReference usersCollectionReference = Firestore.instance.collection("users");

    if (widget.team.id == null) {
      widget.team.id = (await teamsCollectionReference.add(widget.team.toJson())).documentID;
    }
    else {
      await widget.team.update();
    }

    // If the captain has changed, we need to updates roles
    if (_initialCaptainId != widget.team.captainId) {
      if (_initialCaptainId.isNotEmpty && !widget.team.captainIsAdmin) {
        await User(id: _initialCaptainId).updateData({
          'role': 'player',
        });
      }

      // We check if the new user is an admin cause we don't want to 
      // downgrad admins
      Completer completer = new Completer<User>();
      usersCollectionReference.document(widget.team.captainId).snapshots().listen((data) {
        completer.complete(User.fromSnapshot(data));
      });

      User newCaptain = await completer.future;

      // We change the role of the new captain only if he is not 
      // an admin
      if (newCaptain.role != "admin") {
        await newCaptain.updateData({
          'role': 'captain',
        });
      }

      await newCaptain.updateData({
        'team_id': widget.team.id,
      });
    }
  }

  /// This function show a dialog and then delete the team from Firebase
  Future _deleteTeam() async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return AlertDialog(
          title: Text("Supression"),
          content: Text("Voulez vous vraiment supprimer cette équipe ?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Non", style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            FlatButton(
              child: Text("Oui", style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () async {
                
                // We update the UI to show the progress indicator
                setState(() {
                  _updating = true;
                });

                // We need to set the team to nul for all team's players
                CollectionReference usersCollectionReference = Firestore.instance.collection('users');
                CollectionReference teamsCollectionReference = Firestore.instance.collection('teams');

                Completer completer = new Completer();

                usersCollectionReference.getDocuments().then((snaphshot) {
                  snaphshot.documents.forEach((user) async {
                    if (user.data["team_id"] == widget.team.id) {
                      await usersCollectionReference.document(user.data['id']).updateData({
                        "team_id": null
                      });
                    }
                  });

                  completer.complete();
                });

                await completer.future;

                // If the old captain wasn't an admin, he is now a player
                if (_initialCaptainId.isNotEmpty && !widget.team.captainIsAdmin) {
                  await usersCollectionReference.document(_initialCaptainId).updateData({
                    'role': 'player',
                  });
                }

                await teamsCollectionReference.document(widget.team.id).delete();

                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
  
  /// The function upload profil picture to Firebase for the team
  Future _updateTeamPicture() async {
    // First we get the image
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      StorageReference storageReference = FirebaseStorage.instance.ref().child('avatars/teams/${widget.team.id}');    
      StorageUploadTask uploadTask = storageReference.putFile(image);    
      await uploadTask.onComplete;  

      setState(() {});  
    }  
  }

  /// This is the same function as _updateTeamPicture but for the web app
  Future _updateTeamPictureHtml() async {
    // FIREBASE_WEB Comment this out when running web version
    // final html.InputElement input = html.document.createElement('input');

    // input..type = 'file'..accept = 'image/*';

    // input.onChange.listen((e) async {
    //   if (input.files == null || input.files[0] == null)
    //     return;

    //   final List<html.File> files = input.files;

    //   fb.StorageReference storageRef = fb.storage().ref('avatars/teams/${widget.team.id}');
    //   await storageRef.put(files[0]).future;

    //   setState(() {});  
    // });

    // input.click();
    
  }
}