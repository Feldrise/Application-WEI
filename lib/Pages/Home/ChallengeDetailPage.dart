import 'package:appli_wei/Models/Challenge.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/Team.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// This page show the details of a challenge. The details are
///  - The picture of the challenge
///  - The name and description
///  - Some controls (validate, send proof, etc.)
class ChallengeDetailPage extends StatefulWidget {
  const ChallengeDetailPage({
    Key key, 
    @required this.challenge, 
    this.userForChallenge, 
    this.teamForChallenge
  }) : super(key: key);

  final Challenge challenge;

  final User userForChallenge;
  final Team teamForChallenge;
  
  _DefiDetailPageState createState() => _DefiDetailPageState();
}

class _DefiDetailPageState extends State<ChallengeDetailPage> {
  bool _uploadingProof = false;
  Image _proofImage;

  /// We have serval status for a challange (done, todo, waiting validation, etc.)
  String defiStatutString() {
    if (widget.challenge.validatedByUser) {
      return "défi validé";
    }
    
    if (widget.challenge.pendingValidation) {
      return "défi en cours de validation";
    }

    return "défi à faire encore ${widget.challenge.numberOfRepetition - widget.challenge.userRepetition} fois(s)";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Défis : ${widget.challenge.name}"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // The challenge picture
              Image.network(
                widget.challenge.imageUrl,
                fit: BoxFit.fitWidth,
              ),

              // The challenge state
              WeiCard(
                child: Text("Status du défi : " + defiStatutString()),
              ),

              // The challenge description (title + description)
              WeiCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.challenge.name, style: Theme.of(context).textTheme.subtitle,),
                    SizedBox(height: 16),
                    Text(widget.challenge.description)
                  ],
                ),
              ),

              // The challenge "send proof" button
              // Only visible for players and for non team challenge
              Visibility(
                visible: Provider.of<ApplicationSettings>(context).loggedUser.role == "player" && !widget.challenge.isForTeam,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                    child: const Text('Envoyer une preuve de validation du défi', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: (widget.challenge.pendingValidation || widget.challenge.validatedByUser) ? null : _uploadProof,
                  ),
                ),
              ),

              // The challenge "see proof" button
              // Only visible for non player user, if the challenge is not for team and if 
              // the challenge has a user attached to it
              Visibility(
                visible: Provider.of<ApplicationSettings>(context).loggedUser.role != "player" && widget.userForChallenge != null && !widget.challenge.isForTeam,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                    child: const Text('Voir la preuve de validation', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: _viewProof,
                  ),
                ),
              ),

              // The challenge "validate" button
              // Only visible for non player user and the challenge has a user attached to it
              // (the team challenges have the captain of the team attached)
              Visibility(
                visible: Provider.of<ApplicationSettings>(context).loggedUser.role != "player" && widget.userForChallenge != null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                    child: const Text('Valider le défi', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: widget.challenge.validatedByUser ? null : _validateChallenge,
                  ),
                ),
              ),
              SizedBox(height: 32,)
            ],
          ),
        ),
      ),
    );
  }

  /// This function upload a proof from the user gallery
  /// to Firebase.
  Future _uploadProof() async {
    // We don't want to upload proof when their is already a validation waiting
    if (widget.challenge.pendingValidation) {
      return null;
    }

    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // We indicate to the UI we are currently doing work in
      // background so it can show the progress indicator
      setState(() {
        _uploadingProof = true;
      });

      User loggedUser = Provider.of<ApplicationSettings>(context, listen: false).loggedUser;

      loggedUser.challengesToValidate.add(widget.challenge.id);

      StorageReference storageReference = FirebaseStorage.instance.ref().child('proofs/${loggedUser.id}/${widget.challenge.id}');    
      StorageUploadTask uploadTask = storageReference.putFile(image);    
      await uploadTask.onComplete;  
            
      loggedUser.update();
        
      setState(() {
        _uploadingProof = false;
        widget.challenge.pendingValidation = true; // We update the UI to not send proof again
      });  
    }
  }

  /// This function is used for captain and admin to get proof image
  Future<Widget> _getProofImage() async {
    // We don't want to download proof image multiple time
    if (_proofImage != null) 
      return _proofImage;

    String imageUrl = await FirebaseStorage.instance.ref().child('proofs/${widget.userForChallenge.id}/${widget.challenge.id}').getDownloadURL();
    
    _proofImage = Image.network(
        imageUrl,
        fit: BoxFit.fill,
    );

    return _proofImage;
  }

  /// This function show a dialog with the proof
  Future _viewProof() async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return AlertDialog(
          title: Text("Preuve"),
          content: FutureBuilder(
            future: _getProofImage(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return snapshot.data;

              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator());

              if (snapshot.hasError) 
                return Text("Erreur : " + snapshot.error.toString());

              return Container();
            },
          ),
          actions: <Widget>[
            FlatButton(
              child: Text("Ok", style: TextStyle(color: Theme.of(context).accentColor),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  /// This function validate a challenge and update Firebase accordingly
  Future _validateChallenge() async {
    User userForChallenge = widget.userForChallenge;
    Team teamForChallenge = widget.teamForChallenge;

    userForChallenge.challengesToValidate.remove(widget.challenge.id);
    userForChallenge.challengesValidated[widget.challenge.id] = widget.challenge.userRepetition + 1;

    await userForChallenge.updateData({
      'defis_to_validate': widget.userForChallenge.challengesToValidate,
      'defis_validated': widget.userForChallenge.challengesValidated,
      'points': FieldValue.increment(widget.challenge.value)
    });

    await Team(id: widget.userForChallenge.teamId).updateData({
      'points': FieldValue.increment(widget.challenge.value)
    });

    // If it's a team challenge we need to add it in the validated team challengs
    if (widget.challenge.isForTeam) {
      assert(teamForChallenge != null); // The team must be set

     teamForChallenge.challengesValidated[widget.challenge.id] = widget.challenge.userRepetition + 1;

      teamForChallenge.updateData({
        'defis_validated': widget.teamForChallenge.challengesValidated
      });
    }

    Navigator.of(context).pop();
  }
}