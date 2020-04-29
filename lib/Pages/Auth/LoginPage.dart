
import 'package:appli_wei/Helper/AuthHelper.dart';
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Widgets/TextInput.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:appli_wei/Widgets/WeiTitle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _statusMessage = '';
  String _userUID;

  @override
  Widget build(BuildContext context) {
    if (_userUID != null) {
      return Scaffold(
        appBar: AppBar(
          title: Container(),
        ),
        body: Container(
          child: Center(
            child: StreamBuilder<DocumentSnapshot>(
              stream: Firestore.instance.collection('users').document(_userUID).snapshots(),
              builder: (_, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();

                if (snapshot.data["team_id"] == null) {
                  _userUID = '';
                  return Text("Désolé, vous n'avez pas encore d'équipe. Merci de réessayer plus tard.");
                }

                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString("userId", _userUID);
                });

                User loggedUser = User.fromSnapshot(snapshot.data);
                Provider.of<ApplicationSettings>(context).loggedUser = loggedUser;
                // Provider.of<ApplicationSettings>(context).notifyListeners();

                Navigator.of(context).pop();
                return Text("Connexion réussi");
              },
            )
          )
        )
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Container(),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                WeiTitle(title: "Connexion",),
                TextInput(
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  inputDecoration: const InputDecoration(labelText: 'Email'),
                  validator: (String value) {
                    // if (value.isEmpty || value.contains("etudiant.univ-rennes1.fr")) {
                    if (value.isEmpty) {
                      return 'Veuillez rentrer une adresse mail étudante';
                    }
                    return null;
                  },
                ),
                TextInput(
                  controller: _passwordController,
                  obscureText: true,
                  inputDecoration: const InputDecoration(labelText: 'Mot de Passe'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Veuillez rentrer un mot de passe';
                    }
                    return null;
                  },
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: RaisedButton(
                    child: const Text('Connexion', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        _login();
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: _statusMessage.isNotEmpty,
                  child: WeiCard(
                    child: Text(_statusMessage),
                  ),
                ),
                SizedBox(height: 32,)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the Widget is disposed
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Example code for registration.
  void _login() async {
    
    _userUID = await AuthHelper.instance.loginUser(_emailController.text, _passwordController.text);
    
    setState(() {
      if (_userUID == null) {
        _statusMessage = "Erreur lors de la connexion. Vérifiez que vous avez entré le bon mot de passe, la bonne adresse mail et que vous l'avez vérifié.";
      }
    });
    
  }
}