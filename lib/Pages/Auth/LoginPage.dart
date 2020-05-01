import 'package:appli_wei/Models/AuthService.Dart';
import 'package:appli_wei/Widgets/TextInput.dart';
import 'package:appli_wei/Widgets/WeiCard.dart';
import 'package:appli_wei/Widgets/WeiTitle.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// This page allows the user to login with his email and password
class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _statusMessage = '';
  bool _loading = false;

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
                WeiTitle(title: "Connexion",),
                TextInput(
                  controller: _emailController,
                  inputType: TextInputType.emailAddress,
                  inputDecoration: const InputDecoration(labelText: 'Email'),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Veuillez rentrer une adresse mail';
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
                        // We wan't to remove keyboard when it's clicked
                        FocusScopeNode currentFocus = FocusScope.of(context);

                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }

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
    super.dispose();

    _emailController.dispose();
    _passwordController.dispose();
  }

  /// We login using the Auth service
  void _login() async {
    // We should indicate that we are doing work in background to 
    // show loading indicator
    setState(() {
        _loading = true;
    });   

    String newStatusMessage = await Provider.of<AuthService>(context, listen: false).loginUser(_emailController.text, _passwordController.text);

    // We leave the login page on success
    if(newStatusMessage == "Success") {
      Navigator.of(context).pop();
    }
    else {
      setState(() {
        _loading = false;
        _statusMessage = newStatusMessage;
      });    
    }
  }
}