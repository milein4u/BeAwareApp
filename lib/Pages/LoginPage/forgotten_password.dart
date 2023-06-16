import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

class ForgottenPasswordWidget extends StatefulWidget {
  const ForgottenPasswordWidget({Key? key}) : super(key: key);

  @override
  _ForgottenPasswordWidgetState createState() =>
      _ForgottenPasswordWidgetState();
}

class _ForgottenPasswordWidgetState extends State<ForgottenPasswordWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final newPasswordController = TextEditingController();
  final emailController = TextEditingController();
  late bool passwordVisibility;

  @override
  void initState() {
    super.initState();
    passwordVisibility = false;
  }

  @override
  void dispose() {
    newPasswordController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    String email = emailController.text;
    String newPassword = newPasswordController.text;

    // Find the user document in Firestore using the email field
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Get the first document found (assuming unique email addresses)
      String userId = querySnapshot.docs[0].id;
      // Update the password field in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'password': hashPassword(newPassword)});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blueGrey,
          content: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Password updated succsefully!'),
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.blueGrey,
          content: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('User not found!'),
          ),
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  String hashPassword(String password) {
    List<int> bytes = utf8.encode(password); // Convert the password to bytes
    Digest sha256Result = sha256.convert(bytes); // Hash the bytes using SHA-256
    String hashedPassword =
        sha256Result.toString(); // Convert the hashed result to a string
    return hashedPassword;
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
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 40),
          const Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'FORGOTTEN PASSWORD',
                style: TextStyle(
                  color: Color(0xFF0B508C),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 4, 24, 0),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFB3E7F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: emailController,
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
            padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 0),
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFB3E7F2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextFormField(
                controller: newPasswordController,
                obscureText: !passwordVisibility,
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
          MaterialButton(
            minWidth: 240,
            color: Colors.white,
            height: 60,
            elevation: 0,
            onPressed: () {
              passwordReset();
            },
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            child: const Text(
              "Reset password",
              style: TextStyle(
                  color: Color(0xFF0B508C),
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                  fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
