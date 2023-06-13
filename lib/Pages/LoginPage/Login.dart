import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:woman_safety_app/Pages/LoginPage/ForgottenPassword.dart';

import '../MainPages/MapHomePage.dart';
import '../flutter_flow/flutter_flow_google_map.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final emailAddressController = TextEditingController();
  final passwordLoginController =TextEditingController();
  final passwordConfirmedLoginController =TextEditingController() ;

  bool isloading = false;

  late bool passwordLoginVisibility;
  late bool emailAddressVisibility;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future errorMessage(String message)
  async {
    return await showDialog(
      context: context,
      builder: (context) =>
      AlertDialog(
          title: Text(message,
            selectionColor: CupertinoColors.systemGrey,
            style: const TextStyle(color: Colors.grey, fontFamily: 'Lexend Deca', fontSize: 15),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ]
      ),
    );
  }

  void fetchMarkersFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    final markersSnapshot = await FirebaseFirestore.instance
        .collection('markers')
        .where('userId', isEqualTo: user?.uid)
        .get();

    setState(() {
    });
  }


  Future signIn() async {
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
          email: emailAddressController.text.trim(),
          password: passwordLoginController.text.trim()
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueGrey,
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  'You will be automatically logged out after 72 hours of inactivity.'),
            ),
            duration: Duration(seconds: 5),
          )
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (contex) => MapHomePageWidget(),
        ),
      );
      fetchMarkersFromFirestore();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage("Incorrect credentials!") ?? false;
      } else if (e.code == 'wrong-password') {
        errorMessage("Incorrect credentials!") ?? false;
      }
    }
  }


    @override
    void initState() {
      super.initState();
      passwordLoginVisibility = false;
      emailAddressVisibility = false;
    }

    @override
    void dispose() {
      emailAddressController.dispose();
      passwordLoginController.dispose();
      super.dispose();
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      color: Color(0xFF0B508C),
                      icon: Icon(Icons.arrow_back_ios_new_rounded),
                      iconSize: 34,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [],
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(145, 0, 0, 8),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: const [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          color: Color(0xFF0B508C),
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFB3E7F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: emailAddressController,
                  obscureText: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                        Icons.email,
                        color: Color(0xFF0B508C),
                        size:22
                    ),
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                    ),
                    filled: true,
                    fillColor: Color(0xFFB3E7F2),
                    contentPadding:
                    EdgeInsetsDirectional.fromSTEB(2, 24, 2, 24),
                  ),
                  maxLines: 1,
                  validator:
                      (value) => (value!.isEmpty)
                      ? 'Please enter email'
                      : null,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Color(0xFFB3E7F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: passwordLoginController,
                  obscureText: !passwordLoginVisibility,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                        Icons.lock,
                        color: Color(0xFF0B508C),
                        size:22
                    ),
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                    ),
                    filled: true,
                    fillColor: Color(0xFFB3E7F2),
                    contentPadding:
                    EdgeInsetsDirectional.fromSTEB(24, 24, 20, 24),
                    suffixIcon: InkWell(
                      onTap: () => setState(
                            () => passwordLoginVisibility =
                        !passwordLoginVisibility,
                      ),
                      focusNode: FocusNode(skipTraversal: true),
                      child: Icon(
                        passwordLoginVisibility
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Color(0xFF0B508C),
                        size: 22,
                      ),
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
                padding: EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: MaterialButton(
                  minWidth: 200,
                  height: 50,
                  color: Color(0xFF0B508C),
                  elevation: 0,
                  onPressed: () { signIn();},
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)
                  ),
                  child: const Text("Login", style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins",
                      fontSize: 18
                  ),),
                )
            ),
            SizedBox(height: 20),
            MaterialButton(
              minWidth: 240,
              color: Colors.white,
              height: 60,
              elevation: 0,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {return ForgottenPasswordWidget();}));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)
              ),
              child: const Text("Forgot password?", style: TextStyle(
                  color: Color(0xFF0B508C),
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                  fontSize: 16
              ),),
            )
          ],
        ),
      ),
    );
  }
}

