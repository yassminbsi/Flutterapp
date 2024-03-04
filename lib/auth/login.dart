// ignore_for_file: prefer_const_constructors

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(50),
          child: ListView(
            children: [
              Form(
                key: formState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 20,
                    ),
                    CustomLogoAuth(),
                    Container(
                      height: 20,
                    ),
                    Text("Login",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    Container(
                      height: 10,
                    ),
                    Text("Login to continue using the app",
                        style: TextStyle(color: Colors.grey)),
                    Container(
                      height: 20,
                    ),
                    Text("Email",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      height: 10,
                    ),
                    CustomTextForm(
                      hinttext: " Enter Your Email",
                      mycontroller: email,
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter some text';
                        }
                        return null;
                      },
                    ),
                    Container(
                      height: 20,
                    ),
                    Text("Password",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Container(
                      height: 10,
                    ),
                    CustomTextForm(
                        hinttext: " Enter Your password",
                        mycontroller: password,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(top: 10, bottom: 20),
                      child: Text("Forget Password ?",
                          style: TextStyle(fontSize: 14)),
                    ),
                  ],
                ),
              ),
              CustomButton(
                title: "login",
                onPressed: () async {
                  if (formState.currentState!.validate()) {
                    try {
                      final credential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: email.text,
                        password: password.text,
                      );
                      Navigator.of(context).pushReplacementNamed("homepage");
                    } catch (e) {
                      String errorMessage =
                          "An error occurred, please try again.";
                      if (e is FirebaseAuthException) {
                        switch (e.code) {
                          case 'user-not-found':
                            errorMessage = 'No user found with this email.';
                            break;
                          case 'wrong-password':
                            errorMessage =
                                'Wrong password provided for this user.';
                            break;
                          case 'invalid-email':
                            errorMessage =
                                'The email address is badly formatted.';
                            break;
                        }
                      }
                      print(errorMessage); // Print error message for debugging
                      // Show error dialog
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'Error',
                        desc: errorMessage,
                      ).show();
                    }
                  } else {
                    print("Not Valid");
                  }
                },
              ),
              Container(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), // Set border radius
                  border: Border.all(
                    color: Color.fromARGB(255, 56, 159, 59),
                  ), // Set border color
                ),
                child: MaterialButton(
                    minWidth: 20,
                    height: 50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    textColor: Color.fromARGB(255, 56, 159, 59),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Login With Google",
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Image.asset(
                          "images/google.png",
                          width: 30,
                          //fit: BoxFit.fill,
                        ),
                      ],
                    )),
              ),
              Container(height: 20),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("signup");
                  },
                  child: Center(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: "Don't Have An Account ? ",
                      ),
                      TextSpan(
                          text: "Register ?",
                          style: TextStyle(
                              color: Color.fromARGB(255, 56, 159, 59),
                              fontWeight: FontWeight.bold))
                    ])),
                  ))
            ],
          )),
    );
  }
}
