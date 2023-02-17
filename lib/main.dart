import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:woman_safety_app/Pages/MapHomePage.dart';
import 'package:woman_safety_app/Pages/StartPage.dart';

import 'Pages/LoginPage/Login.dart';
import 'Pages/SignupPage/Signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BeAware',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),

      home:  StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const StartPageWidget();
            }
            if (userSnapshot.hasData) {
              return const StartPageWidget();
            }
            return const StartPageWidget();
          }
      ),

      routes: {
        'start_page': (context) => StartPageWidget(),
        'login_screen': (context) => LoginWidget(),
        'signup_screen': (context) => SignupWidget(),
        'map_screen': (context) => MapHomePageWidget(),
      },



    );
  }
}
