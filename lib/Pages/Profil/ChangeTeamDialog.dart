import 'package:appli_wei/Models/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// This dialog show a dropdown with the list of teams 
/// and update the given [user] team accordingly
class ChangeTeamDialog extends StatefulWidget {
  const ChangeTeamDialog({Key key, @required this.user}) : super(key: key);

  final User user;

  @override
  _ChangeTeamDialogState createState() => _ChangeTeamDialogState();
}

class _ChangeTeamDialogState extends State<ChangeTeamDialog> {
  String _selectedTeamId;

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    _selectedTeamId = widget.user.teamId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Equipe pour l'utilisateur"),
      content: _loading ? CircularProgressIndicator() : StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection("teams").snapshots(),
        builder: (context, snaphot) {
          if (!snaphot.hasData) return CircularProgressIndicator();

          return _buildDropdown(context, snaphot.data.documents);
        },
      ),
      actions: <Widget>[
        FlatButton(
          child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor),),
          onPressed: () async {
            setState(() {
              _loading = true;
            });

            await _saveUserTeam(widget.user);

            Navigator.of(context).pop();
          },
        )
      ],
    );
  }

  /// This return the dropdown with the teams from the [snapshot]
  Widget _buildDropdown(BuildContext context, List<DocumentSnapshot> snapshot) {
    return DropdownButton(
      hint: Text("Veuillez choisir une équipe"),
      onChanged: (newValue) {
        setState(() {
          _selectedTeamId = newValue;
        });
      },
      value: _selectedTeamId,
      items: snapshot.map((data) => _buildDropdownItem(context, data)).toList(),
    );
  }
  
  /// This function return the dropdown item corresponding to the [data] provided
  DropdownMenuItem _buildDropdownItem(BuildContext context, DocumentSnapshot data) {
    return DropdownMenuItem(
      child: Text(data["name"]),
      value: data.documentID,
    );
  }

  /// Save the [user] with his new team
  Future _saveUserTeam(User user) async {
    await user.updateData({
      "team_id": _selectedTeamId
    });
  }
}