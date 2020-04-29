import 'package:appli_wei/Models/Activity.dart';
import 'package:appli_wei/Widgets/CheckBoxFormField.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditDefi extends StatefulWidget {
  const EditDefi({Key key, @required this.defi}) : super(key: key);
  
  final Activity defi;
   
  EditDefiState createState() => EditDefiState();
}

class EditDefiState extends State<EditDefi> {
  final _formKey = GlobalKey<FormState>();

  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                      widget.defi.imageUrl.isNotEmpty
                      ? Image.network(
                        widget.defi.imageUrl,
                        fit: BoxFit.fitWidth,
                      )
                      : Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 128,
                      ),
                      TextFormField(
                        initialValue: widget.defi.imageUrl,
                        decoration: InputDecoration(labelText: "Url de l'image"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez une image au défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.defi.imageUrl = value,
                      ),
                      TextFormField(
                        initialValue: widget.defi.name,
                        decoration: InputDecoration(labelText: "Nom"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez un nom au défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.defi.name = value,
                      ),
                      TextFormField(
                        initialValue: widget.defi.description,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(labelText: "Description"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez une description au défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.defi.description = value,
                      ),
                      TextFormField(
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                            WhitelistingTextInputFormatter.digitsOnly
                        ],
                        initialValue: widget.defi.value.toString(),
                        decoration: InputDecoration(labelText: "Nombre de point du défi"),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Donnez un nombre de point à votre défi.";
                          }

                          return null;
                        },
                        onSaved: (value) => widget.defi.value = num.tryParse(value)
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
                        initialValue: widget.defi.isForTeam,
                        title: Text("Ce défi est un défi d'équipe"),
                        onSaved: (value) => widget.defi.isForTeam = value,
                      ),
                      CheckboxFormField(
                        context: context,
                        initialValue: widget.defi.isRepetable,
                        title: Text("Ce défi peut être répété"),
                        onSaved: (value) => widget.defi.isRepetable = value,
                      )
                    ]
                  )
                ),
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
          print("Save the defi");

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

  Future _saveDefiToFirebase() async {
    CollectionReference defisCollectionReference = Firestore.instance.collection("activities");

    if (widget.defi.id == null) {
      await defisCollectionReference.add(widget.defi.toJson());
    }
    else {
      await defisCollectionReference.document(widget.defi.id).setData(widget.defi.toJson());
    }
    
  }
}