import 'LoginPage/Login.dart';
import 'SignupPage/Signup.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/flutter_flow_widgets.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'
as smooth_page_indicator;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class StartPageWidget extends StatefulWidget {
  const StartPageWidget({Key? key}) : super(key: key);

  @override
  _StartPageWidgetState createState() => _StartPageWidgetState();
}

class _StartPageWidgetState extends State<StartPageWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  static const headline = TextStyle(
    color: Colors.black,
    fontSize: 34,
    fontWeight: FontWeight.bold,
  );
  static const bodytext = TextStyle(
    color: Colors.black,
    fontSize: 15,
  );
  static const button = TextStyle(
    color: Colors.white,
    fontSize: 15,
  );

  Route _createRoute(String type) {
    if (type == "login") {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginWidget(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutSine;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    else if (type == "registerEmail") {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SignupWidget(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutSine;

          var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      );
    }
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const StartPageWidget(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: scaffoldKey,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
            Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 50,
                ),
                Center(
                  child:
                  Container(
                      width: MediaQuery.of(context).size.width*0.8,
                      child: const Image(
                        image: AssetImage('assets/images/welcome_logo.png'),
                      ),
                    ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text("BeAware",
                style: headline,
                textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width*0.6,
                  child: Text("Stay safe on the streets with our street safety app - empowering you with tools for personal protection and real-time incident reporting.",
                    style: bodytext,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: Container(
                          height: 60,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                    onPressed: () {Navigator.of(context).push(_createRoute("registerEmail"));},
                                    child: Text("Register",
                                    style: button)
                               ),
                              ),
                              Expanded(
                                child: TextButton(
                                    onPressed: () {Navigator.of(context).push(_createRoute("login"));},
                                    child: Text("Login",
                                        style: button)
                                ),
                              ),
                            ],
                          ),
                        )
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
        ),
      );
    }
  }


