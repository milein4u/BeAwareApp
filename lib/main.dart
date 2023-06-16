import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:woman_safety_app/Pages/MainPages/map_home_page.dart';
import 'package:woman_safety_app/Pages/MainPages/start_page.dart';
import 'Pages/LoginPage/login.dart';
import 'Pages/SignupPage/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
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
        primarySwatch: Colors.blue,
      ),
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (ctx, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const StartPageWidget();
            }
            if (userSnapshot.hasData) {
              return const StartPageWidget();
            }
            return const StartPageWidget();
          }),
      routes: {
        'start_page': (context) => const StartPageWidget(),
        'login_screen': (context) => const LoginWidget(),
        'signup_screen': (context) => const SignupWidget(),
        'map_screen': (context) => const MapHomePageWidget(),
      },
    );
  }
}
