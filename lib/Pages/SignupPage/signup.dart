import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignupWidget extends StatefulWidget {
  const SignupWidget({Key? key}) : super(key: key);

  @override
  _SignupWidgetState createState() => _SignupWidgetState();
}

class _SignupWidgetState extends State<SignupWidget> {
  final _auth = FirebaseAuth.instance;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  TextEditingController? confirmPasswordController;
  late bool confirmPasswordVisibility;
  late bool passwordVisibility;
  late User currentUser;
  bool isloading = false;


  @override
  void initState() {
    super.initState();
    confirmPasswordController = TextEditingController();
    confirmPasswordVisibility = false;
    passwordVisibility = false;
  }

  @override
  void dispose() {
    confirmPasswordController?.dispose();
    emailAddressController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        currentUser = user;
        if (kDebugMode) {
          print(currentUser.email);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
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

  Future addUserDetails(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
      'email': emailAddressController.text.trim(),
      'phone': phoneController.text.trim(),
      'password': hashPassword(passwordController.text)
    });
  }

  Future register() async {
    if (emailConfirmed() && confirmedPassword() && phoneConfirmed()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: emailAddressController.text.trim(),
            password: passwordController.text.trim());
        getCurrentUser();
        addUserDetails(currentUser.uid.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.blueGrey,
            content: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Successfully Register.You Can Login Now'),
            ),
            duration: Duration(seconds: 5),
          ),
        );

        Navigator.pushReplacementNamed(context, 'start_page');

        setState(() {
          isloading = false;
        });
      } on FirebaseAuthException catch (e) {
        if (kDebugMode) {
          print(e);
        }
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(e.message.toString()),
              );
            });
      }
    }
  }

  bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  bool emailConfirmed() {
    if (emailAddressController.text.isEmpty) {
      errorMessage("Please write your email address!");
      return false;
    }
    if (isValidEmail(emailAddressController.text) == false) {
      errorMessage("Please write a valid email address!");
      return false;
    } else {
      return true;
    }
  }

  bool isValidPhoneNumber(String phone) {
    String pattern = r'^(?:\+40|0)[ ]?7\d{2}[ ]?\d{3}[ ]?\d{3}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(phone);
  }

  bool phoneConfirmed() {
    if (phoneController.text.isEmpty) {
      errorMessage("Please write your phone number!");
      return false;
    }
    if (isValidPhoneNumber(phoneController.text) == false) {
      errorMessage("Please write a valid phone number!");
      return false;
    } else {
      return true;
    }
  }

  String hashPassword(String password) {
    List<int> bytes = utf8.encode(password); // Convert the password to bytes
    Digest sha256Result = sha256.convert(bytes); // Hash the bytes using SHA-256
    String hashedPassword =
        sha256Result.toString(); // Convert the hashed result to a string
    return hashedPassword;
  }

  bool confirmedPassword() {
    if (passwordController.text != confirmPasswordController?.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Passwords don\'t match!',
          ),
        ),
      );
      return false;
    } else {
      return true;
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
                  'GET STARTED',
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
                    prefixIcon:
                        const Icon(Icons.email, color: Color(0xFF0B508C), size: 22),
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
                  controller: phoneController,
                  obscureText: false,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.phone, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Enter your phone number',
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
                      (value!.isEmpty) ? 'Please enter phone number' : null,
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
                  controller: passwordController,
                  obscureText: !passwordVisibility,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Type your password',
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
                      focusNode: FocusNode(skipTraversal: true),
                      child: const Icon(
                        Icons.visibility_off_outlined,
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
              padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 0),
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E7F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !confirmPasswordVisibility,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock, color: Color(0xFF0B508C), size: 22),
                    hintText: 'Retype your password',
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
                      focusNode: FocusNode(skipTraversal: true),
                      child: const Icon(
                        Icons.visibility_off_outlined,
                        color: Color(0xFF0B508C),
                        size: 22,
                      ),
                    ),
                  ),
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                child: MaterialButton(
                  minWidth: 200,
                  height: 50,
                  color: const Color(0xFF0B508C),
                  elevation: 0,
                  onPressed: () {
                    register();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                        fontSize: 18),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
