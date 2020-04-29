import 'package:appli_wei/Models/ApplicationSettings.dart';
import 'package:appli_wei/Pages/Auth/AuthPage.dart';
import 'package:appli_wei/Pages/MainPage.dart';
import 'package:appli_wei/Pages/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => new ApplicationSettings(),),
      ],
      child: MaterialApp(
        title: 'Appli du WEI',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,

          primaryColor: Color(0xfff70c36),
          accentColor: Color(0xfff70c36),

          appBarTheme: AppBarTheme(
            color:  Color(0xfff70c36),
            // textTheme: Theme.of(context).textTheme,
            elevation: 0,
          ),

          textTheme: TextTheme(
            title: TextStyle(fontSize: 38.0, fontWeight: FontWeight.w500, color: Colors.black87),
            // subtitle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w200, color: Colors.black87),
            // headline: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: Colors.black87),
            // subhead: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300, color: Colors.black87),
            // body1: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black87),
            // body2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: Colors.black87),
            // caption: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w400, color: Colors.black87)
          ),
        ),
        home: Consumer<ApplicationSettings>(
          builder: (context, applicationSettings, child) {
            if (!applicationSettings.initialized) {
              return SplashScreen();
            }

            if (applicationSettings.loggedUser == null) {
              return AuthPage();
            }

            return MainPage();
          }
        ),
        // home: (applicationSettings.loggedUser == null) ? AuthPage() : MainPage(),
      )
    );
  }
}