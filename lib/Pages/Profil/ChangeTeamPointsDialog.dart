import 'package:appli_wei/Models/Team.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// This dialog show a field with to add or remove
/// points for the given [team]
class ChangeTeamPointsDialog extends StatefulWidget {
  const ChangeTeamPointsDialog({Key key, @required this.team}) : super(key: key);

  final Team team;

  @override
  _ChangeTeamPointsDialogState createState() => _ChangeTeamPointsDialogState();
}

class _ChangeTeamPointsDialogState extends State<ChangeTeamPointsDialog> {
  final _formKey = GlobalKey<FormState>();

  int _pointsToAdd = 0;

  bool _upddating = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Points pour l'équipe"),
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

              await _saveTeamPoints(widget.team);
              
              Navigator.of(context).pop(true);
            }
          },
        )
      ],
    );
  }

  /// Save the [team] with his new points
  Future _saveTeamPoints(Team team) async {
    await team.updateData({
      "points": FieldValue.increment(_pointsToAdd)
    });
  }
}