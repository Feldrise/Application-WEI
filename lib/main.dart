import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Models/AuthService.Dart';
import 'package:appli_wei/Pages/Auth/AuthPage.dart';
import 'package:appli_wei/Pages/MainPage.dart';
import 'package:appli_wei/Pages/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Since we need authentification at the app startup, the provider comes 
    // at the creation of the app widget
    ChangeNotifierProvider<AuthService>(
      child: MyApp(),
      create: (context) => AuthService(),
    )
  );
}

/// This is the main widget of the application. It provides the ChangeNotifierProvider
/// for the appliation settings 
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => new ApplicationSettings(),),
      ],
      // The gesture dectector allows us to "unfocus" and remove keyboard on tap on the screen
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: MaterialApp(
          title: 'Appli du WEI',
          theme: ThemeData(
            scaffoldBackgroundColor: Colors.white,

            primaryColor: Color(0xfff70c36), // These are the color of the ISATI
            accentColor: Color(0xfff70c36),

            appBarTheme: AppBarTheme(
              color:  Color(0xfff70c36),
              elevation: 0,
            ),

            textTheme: TextTheme(
              title: TextStyle(fontSize: 38.0, fontWeight: FontWeight.w500, color: Colors.black87),
              subtitle: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300, color: Colors.black87),
            ),
          ),
          home: FutureBuilder(
            // We need to get the logged user object
            future: Provider.of<AuthService>(context).getUser(),
            // wait for the future to resolve and render the appropriate
            // widget for HomePage or AuthPage
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  // If we have a logged user, we put it on the application settings
                  Provider.of<ApplicationSettings>(context, listen: false).loggedUser = snapshot.data;
                  return MainPage(); 
                } 
                
                return AuthPage();
              } else {
                return SplashScreen();
              }
            },
          ),
        )
      ),
    );
  }
}