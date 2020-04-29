import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class DefiDetailPage extends StatefulWidget {
  const DefiDetailPage({Key key, @required this.defi}) : super(key: key);

  final Activity defi;
  
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: _uploadingProof ? CircularProgressIndicator() : RaisedButton(
                child: const Text('Envoyer une preuve de validation du défis', style: TextStyle(color: Colors.white),),
                color: Theme.of(context).accentColor,
                onPressed: (widget.defi.pendingValidation) ? null : () async {
                  if (widget.defi.pendingValidation) {
                    return null;
                  }

                  // First we get the image
                  await ImagePicker.pickImage(source: ImageSource.gallery).then((image) async {    
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
                  });

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}