import 'package:appli_wei/Pages/Auth/LoginPage.dart';
import 'package:appli_wei/Pages/Auth/RegisterPage.dart';
import 'package:appli_wei/Widgets/WeiTitle.dart';
import 'package:flutter/material.dart';

/// This is the first page of the application. Here the user
/// have the choice between register himself or login
class AuthPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(),
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            WeiTitle(title: "Authentification",),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    RaisedButton(
                      child: const Text('Se connecter', style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).accentColor,
                      onPressed: () async => await _loginClicked(context),
                    ),
                    RaisedButton(
                      child: const Text('S\'inscrire', style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).accentColor,
                      onPressed: () async => await _registerClicked(context),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// We simply navigate to the login page from the [context]
  Future _loginClicked(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  /// We simply navigate to the register page from the [context]
  Future _registerClicked(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegisterPage()),
    );
  }
}