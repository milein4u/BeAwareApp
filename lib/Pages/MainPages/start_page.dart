import '../LoginPage/login.dart';
import '../SignupPage/signup.dart';
import 'package:flutter/material.dart';
import '../Design/animation.dart';

class StartPageWidget extends StatefulWidget {
  const StartPageWidget({Key? key}) : super(key: key);

  @override
  _StartPageWidgetState createState() => _StartPageWidgetState();
}

class _StartPageWidgetState extends State<StartPageWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.white,
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: const <Widget>[
                    AnimationEffect(
                        1,
                        Text(
                          "Stay safe,",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            fontFamily: "Poppins",
                          ),
                          textAlign: TextAlign.start,
                        )),
                    AnimationEffect(
                        1,
                        Text(
                          "with BeAware.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            fontFamily: "Poppins",
                          ),
                        )),
                    SizedBox(height: 20)
                  ],
                ),
              ),
              AnimationEffect(
                  1.5,
                  Container(
                    height: MediaQuery.of(context).size.height / 3,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage('assets/images/welcome_icon.png'))),
                  )),
              Column(
                children: <Widget>[
                  AnimationEffect(
                      1.5,
                      MaterialButton(
                        minWidth: 240,
                        color: const Color(0xFF0B508C),
                        height: 60,
                        elevation: 0,
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginWidget()));
                        },
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        child: const Text(
                          "LOGIN",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Poppins",
                              fontSize: 18),
                        ),
                      )),
                  const SizedBox(height: 20),
                  AnimationEffect(
                      1.6,
                      Container(
                        padding: const EdgeInsets.only(top: 3, left: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: MaterialButton(
                          minWidth: 240,
                          height: 60,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SignupWidget()));
                          },
                          //color: Color(0xFFFFB100),
                          color: const Color(0xFFB3E7F2),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          child: const Text(
                            "REGISTER",
                            style: TextStyle(
                                color: Color(0xFF0B508C),
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins",
                                fontSize: 18),
                          ),
                        ),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
