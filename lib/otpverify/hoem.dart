import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/otpverify/login_screen.dart';
import 'package:get/get.dart';
import 'package:flutter_app/otpverify/controllers/login_controller.dart';


import 'controllers/login_controller.dart';

class HomeScreen extends StatelessWidget {
  final LoginController loginController = Get.find();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(loginController.authStatus()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await auth.signOut();
          if (auth.currentUser == null) {
            Get.to(LoginScreen());
          }
        },
        child: Icon(Icons.logout),
      ),
    );
  }
}
