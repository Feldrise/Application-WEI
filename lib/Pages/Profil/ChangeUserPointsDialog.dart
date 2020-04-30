import 'package:appli_wei/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChangeUserPointsDialog extends StatefulWidget {
  const ChangeUserPointsDialog({Key key, @required this.user}) : super(key: key);

  final User user;

  ChangeUserPointsDialogState createState() => ChangeUserPointsDialogState();
}

class ChangeUserPointsDialogState extends State<ChangeUserPointsDialog> {
  final _formKey = GlobalKey<FormState>();

  int _pointsToAdd = 0;

  bool _upddating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Points pour l'utilisateur"),
      content: _upddating ? CircularProgressIndicator() : Form(
        key: _formKey,
        child: TextFormField(
          keyboardType: TextInputType.numberWithOptions(signed: true),
          inputFormatters: <TextInputFormatter>[
              WhitelistingTextInputFormatter(RegExp("[0-9\-]"))
          ],
          initialValue: _pointsToAdd.toString(),
          decoration: InputDecoration(labelText: "Nombre de points à ajouter (négatif pour retirer)"),
          validator: (value) {
            if (value.isEmpty || num.tryParse(value) == 0) {
              return "Donnez un nombre de points différent de 0.";
            }

            return null;
          },
          onSaved: (value) => _pointsToAdd = num.tryParse(value)
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor),),
          onPressed: () async {
            if (_formKey.currentState.validate()) {
              _formKey.currentState.save();

              setState(() {
                _upddating = true;
              });

              await _saveUserPoints(widget.user);
              
              Navigator.of(context).pop(true);
            }
          },
        )
      ],
    );
  }

  Future _saveUserPoints(User user) async {
    await Firestore.instance.collection('users').document(user.id).updateData({
      "points": FieldValue.increment(_pointsToAdd)
    });
  }
}