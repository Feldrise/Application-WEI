
import 'package:appli_wei/Models/User.dart';
import 'package:appli_wei/Models/AuthService.Dart';
import 'package:appli_wei/Widgets/TextInput.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:appli_wei/Widgets/WeiTitle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This page allows the user to register. We get these information :
///  - A first name
///  - A second name
///  - An email adress
///  - A password
/// 
/// By default, when a user signup he get the "player" role and has no team.
class RegisterPage extends StatefulWidget {

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _secondNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _loading = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(),
      ),
      body: Container(
        child: _loading ? Center(child: CircularProgressIndicator(),) : SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                WeiTitle(title: "Inscription",),
                TextInput(
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  inputDecoration: const InputDecoration(labelText: 'Email'),
                  validator: (String value) {
                    // TODO: check if mail is from university of Rennes 1
                    // if (value.isEmpty || value.contains("etudiant.univ-rennes1.fr")) {
                    if (value.isEmpty) {
                      return 'Veuillez rentrer une adresse mail étudante';
                    }
                    return null;
                  },
                ),
                TextInput(
                  controller: _firstNameController,
                  inputDecoration: InputDecoration(labelText: 'Prénom'),
                  validator: (String value) {
                    if (value.isEmpty || value.contains("etudiant.univ-rennes1.fr")) {
                      return 'Veuillez rentrer votre prénom';
                    }
                    return null;
                  },
                ),
                TextInput(
                  controller: _secondNameController,
                  inputDecoration: const InputDecoration(labelText: 'Nom'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Veuillez rentrer votre nom';
                    }
                    return null;
                  },
                ),
                TextInput(
                  controller: _passwordController,
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
                    child: const Text('Envoyer', style: TextStyle(color: Colors.white),),
                    color: Theme.of(context).accentColor,
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        // We wan't to remove keyboard when it's clicked
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        
                        await _register();
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

  /// We register the user to Firebase using the Auth
  /// service
  Future _register() async {
    User toRegister = User(
      firstName: _firstNameController.text,
      secondName: _secondNameController.text,
      email: _emailController.text,
      role: "player",
      challengesToValidate: [],
      challengesValidated: {}
    );
    
    // We need to notify the state that we are 
    // doing work in background to show the progress
    // indicator
    setState(() {
      _loading = true;
    });

    _statusMessage = await Provider.of<AuthService>(context, listen: false).registerUser(toRegister, _passwordController.text);
    
    setState(() {
      _loading = false;
    });
    
  }
}