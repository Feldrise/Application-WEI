import 'dart:async';

import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTeam extends StatefulWidget {
  const EditTeam({Key key, @required this.team}) : super(key: key);
  
  final Team team;
   
  EditTeamState createState() => EditTeamState();
}

class EditTeamState extends State<EditTeam> {
  final _formKey = GlobalKey<FormState>();

  int i = 0;

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
                          if (!snapshot.hasData) return CircularProgressIndicator();

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
               
                Visibility(
                  visible: widget.team.id != null,
                  child: RaisedButton(
                    child: const Text("Supprimer l'équipe...", style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      print("Delete defi");
                      
                      await _deleteTeam();
                      Navigator.of(context).pop();
                    },
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
          print("Save the team");

          if (_formKey.currentState.validate()) {
            _formKey.currentState.save();
            
            setState(() {
              _updating = true;
            });

            await _saveDefiToFirebase();
            
            Navigator.of(context).pop(true);
          }
        },
      ),
    );
  }

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
  
  DropdownMenuItem _buildDropdownItem(BuildContext context, DocumentSnapshot data) {
    return DropdownMenuItem(
      child: Text(data["first_name"] + ' ' + data['second_name']),
      value: data.documentID,
    );
  }

  Future _saveDefiToFirebase() async {
    CollectionReference teamsCollectionReference = Firestore.instance.collection("teams");
    CollectionReference usersCollectionReference = Firestore.instance.collection("users");

    if (widget.team.id == null) {
      widget.team.id = (await teamsCollectionReference.add(widget.team.toJson())).documentID;
    }
    else {
      await teamsCollectionReference.document(widget.team.id).setData(widget.team.toJson());
    }

    if (_initialCaptainId != widget.team.captainId) {
      if (_initialCaptainId.isNotEmpty && !widget.team.captainIsAdmin) {
        await usersCollectionReference.document(_initialCaptainId).updateData({
          'role': 'player',
        });
      }

      // We check if the new user is an admin
      Completer completer = new Completer<User>();
      usersCollectionReference.document(widget.team.captainId).snapshots().listen((data) {
        completer.complete(User.fromSnapshot(data));
      });

      User newCaptain = await completer.future;

      // We change the role of the new captain
      if (newCaptain.role != "admin") {
        await usersCollectionReference.document(newCaptain.id).updateData({
          'role': 'captain',
        });
      }

      // We change the team of the new captain
      await usersCollectionReference.document(newCaptain.id).updateData({
        'team_id': widget.team.id,
      });
    }
  }

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
                setState(() {
                  _updating = true;
                });

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
}