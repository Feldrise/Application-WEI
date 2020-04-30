import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DefiDetailPage extends StatefulWidget {
  const DefiDetailPage({Key key, @required this.defi, this.userForDefi}) : super(key: key);

  final Activity defi;

  final User userForDefi;
  
  DefiDetailPageState createState() => DefiDetailPageState();
}

class DefiDetailPageState extends State<DefiDetailPage> {
  bool _uploadingProof = false;

  String defiStatutString() {
    if (widget.defi.validatedByUser) {
      return "défi validé";
    }
    
    if (widget.defi.pendingValidation) {
      return "défi en cours de validation";
    }

    return "défi à faire";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Défis : ${widget.defi.name}"),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Image.network(
                widget.defi.imageUrl,
                fit: BoxFit.fitWidth,
              ),
              WeiCard(
                child: Text("Status du défis : " + defiStatutString()),
              ),
              WeiCard(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.defi.name, style: Theme.of(context).textTheme.subtitle,),
                    SizedBox(height: 16),
                    Text(widget.defi.description)
                  ],
                ),
              ),
              Visibility(
                visible: Provider.of<ApplicationSettings>(context, listen: false).loggedUser.role == "player" && !widget.defi.isForTeam,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                    child: const Text('Envoyer une preuve de validation du défis', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: (widget.defi.pendingValidation || widget.defi.validatedByUser) ? null : _uploadProof,
                  ),
                ),
              ),
              Visibility(
                visible: Provider.of<ApplicationSettings>(context, listen: false).loggedUser.role != "player" && widget.userForDefi != null && !widget.defi.isForTeam,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                    child: const Text('Voir la preuve de validation', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: _viewProof,
                  ),
                ),
              ),
              Visibility(
                visible: Provider.of<ApplicationSettings>(context, listen: false).loggedUser.role != "player" && widget.userForDefi != null,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                    child: const Text('Valider le défis', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: _validateDefis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _uploadProof() async {
    if (widget.defi.pendingValidation) {
      return null;
    }

    // First we get the image
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (image != null) {
        setState(() {
          _uploadingProof = true;
        });

        // We update the liste
        Provider.of<ApplicationSettings>(context, listen: false).loggedUser.defisToValidate.add(widget.defi.id);
        Provider.of<ApplicationSettings>(context, listen: false).loggedUser.update();

        String userId = Provider.of<ApplicationSettings>(context, listen: false).loggedUser.id;

        StorageReference storageReference = FirebaseStorage.instance.ref().child('proofs/$userId/${widget.defi.id}');    
        StorageUploadTask uploadTask = storageReference.putFile(image);    
        await uploadTask.onComplete;  
          
        print('File Uploaded');    
        setState(() {
          _uploadingProof = false;
          widget.defi.pendingValidation = true;
        });  
      }    
    }
  }

  Future<Widget> _getProofImage(BuildContext context) async {
    Image image;
    String imageUrl = await FirebaseStorage.instance.ref().child('proofs/${widget.userForDefi.id}/${widget.defi.id}').getDownloadURL();

    print("Image url : $imageUrl");
    
    image = Image.network(
        imageUrl,
        fit: BoxFit.fill,
    );

    return image;
  }

  Future _viewProof() async {
    await showDialog(
      context: context,
      builder: (BuildContext  context) {
        return AlertDialog(
          title: Text("Preuve"),
          content: FutureBuilder(
            future: _getProofImage(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done)
                return snapshot.data;

              if (snapshot.connectionState == ConnectionState.waiting)
                return CircularProgressIndicator();

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

  Future _validateDefis() async {
    widget.userForDefi.defisToValidate.remove(widget.defi.id);

    if (!widget.defi.isRepetable) {
      widget.userForDefi.defisValidated.add(widget.defi.id);
    }

    // We update list in the user fiels
    Firestore.instance.collection("users").document(widget.userForDefi.id).updateData({
      'defis_to_validate': widget.userForDefi.defisToValidate,
      'defis_validated': widget.userForDefi.defisValidated
    });

    // We add the points to the user
    Firestore.instance.collection("users").document(widget.userForDefi.id).updateData({
      'points': FieldValue.increment(widget.defi.value)
    });

    // We add the points to the team
    Firestore.instance.collection("teams").document(widget.userForDefi.teamId).updateData({
      'points': FieldValue.increment(widget.defi.value)
    });

    Navigator.of(context).pop();
  }
}