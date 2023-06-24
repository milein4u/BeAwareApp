import '../MainPages/map_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:woman_safety_app/Pages/LoginPage/forgotten_password.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  _LoginWidgetState createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final emailAddressController = TextEditingController();
  final passwordLoginController = TextEditingController();
  final passwordConfirmedLoginController = TextEditingController();
  late bool passwordLoginVisibility;
  late bool emailAddressVisibility;
  bool isloading = false;

  @override
  void initState() {
    super.initState();
    passwordLoginVisibility = false;
    emailAddressVisibility = false;
  }

  @override
  void dispose() {
    super.dispose();
    emailAddressController.dispose();
    passwordLoginController.dispose();
  }

  Future errorMessage(String message) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
          title: Text(
            message,
            style: const TextStyle(
                color: Colors.grey, fontFamily: 'Poppins', fontSize: 16),
          ),
          backgroundColor: Colors.white,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ]),
    );
  }

  Future signIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddressController.text.trim(),
          password: passwordLoginController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.blueGrey,
        content: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
              'You will be automatically logged out after 72 hours of inactivity.'),
        ),
        duration: Duration(seconds: 5),
      ));
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const MapHomePageWidget(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        errorMessage("Incorrect credentials!");
      } else if (e.code == 'wrong-password') {
        errorMessage("Incorrect credentials!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IconButton(
                      color: const Color(0xFF0B508C),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
          actions: const [],
          centerTitle: true,
          elevation: 0,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.all(8.0),
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
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E7F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: emailAddressController,
                  obscureText: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email,
                        color: Color(0xFF0B508C), size: 22),
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFB3E7F2),
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(2, 24, 2, 24),
                  ),
                  maxLines: 1,
                  validator: (value) =>
                      (value!.isEmpty) ? 'Please enter email' : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E7F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: passwordLoginController,
                  obscureText: !passwordLoginVisibility,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock,
                        color: Color(0xFF0B508C), size: 22),
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF0B508C),
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: Color(0x00000000),
                        width: 0,
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFB3E7F2),
                    contentPadding:
                        const EdgeInsetsDirectional.fromSTEB(24, 24, 20, 24),
                    suffixIcon: InkWell(
                      onTap: () => setState(
                        () =>
                            passwordLoginVisibility = !passwordLoginVisibility,
                      ),
                      focusNode: FocusNode(skipTraversal: true),
                      child: Icon(
                        passwordLoginVisibility
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF0B508C),
                        size: 22,
                      ),
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: MaterialButton(
                  minWidth: 200,
                  height: 50,
                  color: const Color(0xFF0B508C),
                  elevation: 0,
                  onPressed: () {
                    signIn();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                        fontSize: 18),
                  ),
                )),
            const SizedBox(height: 20),
            MaterialButton(
              minWidth: 240,
              color: Colors.white,
              height: 60,
              elevation: 0,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const ForgottenPasswordWidget();
                }));
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              child: const Text(
                "Forgot password?",
                style: TextStyle(
                    color: Color(0xFF0B508C),
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                    fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}
