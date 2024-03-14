import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:flutter_app/auth/login.dart';

class signup extends StatefulWidget {
  const signup({super.key});

  @override
  State<signup> createState() => _signupState();
}

class _signupState extends State<signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: EdgeInsets.all(20),
          child: ListView(
            children: [
              Form(
                key: formState,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 50),
                    CustomLogoAuth(),
                    Container(
                      height: 20,
                    ),
                    Text("signup",
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold)),
                    Container(
                      height: 10,
                    ),
                    Text("signup To Continue Using The App",
                        style: TextStyle(color: Colors.grey)),
                    Container(height: 20),
                    Text(
                      "Username",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(height: 10),
                    CustomTextForm(
                        hinttext: "Enter Your Username",
                        mycontroller: username,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                    Text(
                      "Email",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(height: 10),
                    CustomTextForm(
                        hinttext: "Enter Your Email",
                        mycontroller: email,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                    Text(
                      "Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(height: 10),
                    CustomTextForm(
                        hinttext: "Enter Your Password",
                        mycontroller: password,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                    Text(
                      "Confirm Password",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    Container(height: 10),
                    CustomTextForm(
                        hinttext: " Confirm Your Password",
                        mycontroller: confirmpassword,
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        }),
                  ],
                ),
              ),
              Container(height: 20),
              MaterialButton(
                child: Text ("Signup"),
                onPressed: () async {
                  if (formState.currentState!.validate()) {
                    try {
                      // ignore: unused_local_variable
                      final credential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: email.text,
                        password: password.text,
                      );
                      FirebaseAuth.instance.currentUser!.sendEmailVerification(); // to send message inbox to verify
                      Navigator.of(context).pushReplacementNamed("login");
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        print('The password provided is too weak.');
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Dialog Title',
                          desc: 'Dialog description here',
                        ).show();
                      } else if (e.code == 'email-already-in-use') {
                        print('The account already exists for that email.');
                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          animType: AnimType.rightSlide,
                          title: 'Dialog Title',
                          desc: 'Dialog description here',
                        ).show();
                      }
                    } catch (e) {
                      print(e);
                    }
                  }
                },
              ),
              Container(height: 20),
              Container(height: 10),
              InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed("login");
                  },
                  child: Center(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                        text: "Have An Account?",
                      ),
                      TextSpan(
                        text: "Login",
                        style: TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ])),
                  ))
            ],
          )),
    );
  }
}
