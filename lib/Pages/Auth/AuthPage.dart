import 'package:appli_wei/Pages/Auth/LoginPage.dart';
import 'package:appli_wei/Pages/Auth/SignUpPage.dart';
import 'package:appli_wei/Widgets/WeiTitle.dart';
import 'package:flutter/material.dart';

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
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                    ),
                    RaisedButton(
                      child: const Text('S\'inscrire', style: TextStyle(color: Colors.white),),
                      color: Theme.of(context).accentColor,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
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
}