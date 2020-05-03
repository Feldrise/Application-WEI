import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Widgets/CheckBoxFormField.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This is a form to update a challenge
class EditChallenge extends StatefulWidget {
  const EditChallenge({Key key, @required this.challenge}) : super(key: key);
  
  final Challenge challenge;
   
   @override 
  _EditChallengeState createState() => _EditChallengeState();
}

class _EditChallengeState extends State<EditChallenge> {
  final _formKey = GlobalKey<FormState>();

  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (MediaQuery.of(context).size.width > 980) ? null : AppBar(
        title: Text("Edition d'un défi"),
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
                      widget.challenge.imageUrl.isNotEmpty
                      ? Image.network(
                        widget.challenge.imageUrl,
                        fit: BoxFit.fitWidth,
                      )
                      : Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 128,
                      ),
                      TextFormField(
                        initialValue: widget.challenge.imageUrl,
                        decoration: InputDecoration(labelText: "Url de l'image"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez une image au défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.challenge.imageUrl = value,
                      ),
                      TextFormField(
                        initialValue: widget.challenge.name,
                        decoration: InputDecoration(labelText: "Nom"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez un nom au défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.challenge.name = value,
                      ),
                      TextFormField(
                        initialValue: widget.challenge.description,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(labelText: "Description"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez une description au défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.challenge.description = value,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                        ],
                        initialValue: widget.challenge.value.toString(),
                        decoration: InputDecoration(labelText: "Nombre de point du défi"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez un nombre de point à votre défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.challenge.value = num.tryParse(value)
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                        ],
                        initialValue: widget.challenge.numberOfRepetition.toString(),
                        decoration: InputDecoration(labelText: "Nombre de fois que le défi doit être réalisé"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez un nombre de fois que le défi doit être réalisé.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.challenge.numberOfRepetition = num.tryParse(value)
                      ),
                    ],
                  ),
                ),

                WeiCard(
                  margin: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                  child: Column(
                    children: <Widget>[
                      CheckboxFormField(
                        context: context,
                        initialValue: widget.challenge.isForTeam,
                        title: Text("Ce défi est un défi d'équipe"),
                        onSaved: (value) => widget.challenge.isForTeam = value,
                      ),
                      CheckboxFormField(
                        context: context,
                        initialValue: widget.challenge.isVisible,
                        title: Text("Ce défi est visible"),
                        onSaved: (value) => widget.challenge.isVisible = value,
                      )
                    ]
                  )
                ),
                
                // We only show remove button for existing challenge
                Visibility(
                  visible: widget.challenge.id != null,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: RaisedButton(
                      child: const Text('Supprimer le défi...', style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {                    
                        await _deleteChallenge();
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

            await _saveChallengeToFirebase();

            // We update the UI to show the progress indicator
            setState(() {
              _updating = false;
            });
          }
        },
      ),
    );
  }

  /// This function save the challenge to Firebase
  Future _saveChallengeToFirebase() async {
    if (widget.challenge.id == null) {
      await Firestore.instance.collection("activities").add(widget.challenge.toJson());
    }
    else {
      await widget.challenge.update();
    }
  }

  /// This function show a dialog and then delete the challenge from Firebase
  Future _deleteChallenge() async {

    // We want the user to be sure...
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return AlertDialog(
          title: Text("Supression"),
          content: Text("Voulez vous vraiment supprimer ce défi ?"),
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

                await Firestore.instance.collection("activities").document(widget.challenge.id).delete();
                
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }
}