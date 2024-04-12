import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'login.dart';

// import 'model.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  _RegisterState();

  bool showProgress = false;
  bool visible = false;

  final _formkey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController confirmpassController =
      new TextEditingController();
  final TextEditingController name = new TextEditingController();
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController mobile = new TextEditingController();
  bool _isObscure = true;
  bool _isObscure2 = true;
  File? file;
  var options = [
    'Admin',
    'SuperAdmin',
  ];
  var _currentItemSelected = "Admin";
  var rool = "Admin";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF25243A),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              color:  Color(0xFF25243A),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.all(52),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        Text(
                          "Track My Bus",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color:  Colors.orange[800],
                            fontSize: 40,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        TextFormField(
                          controller: emailController,
                         decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'E-mail',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Color.fromARGB(255, 225, 225, 225),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                     
                                            borderSide: BorderSide(color: Color.fromARGB(255, 242, 242, 242)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
                          validator: (value) {
                            if (value!.length == 0) {
                              return "Email cannot be empty";
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please enter a valid email");
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {},
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: _isObscure,
                          controller: passwordController,
                           decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Saisir votre mot de passe',
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
      color: Colors.white,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 242, 242, 242)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFCA20)),
      borderRadius: BorderRadius.circular(5),
    ),
    suffixIcon: IconButton(
      onPressed: () {
        setState(() {
          _isObscure = !_isObscure;
        });
      },
      icon: _isObscure == true
          ? Icon(Icons.visibility_off)
          : Icon(Icons.visibility),
    ),
  ),
                          validator: (value) {
                            RegExp regex = new RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return "Password cannot be empty";
                            }
                            if (!regex.hasMatch(value)) {
                              return ("please enter valid password min. 6 character");
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {},
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        TextFormField(
                          obscureText: _isObscure2,
                          controller: confirmpassController,
                          decoration: InputDecoration(
    labelText: 'Confirmer mot de passe',
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
      
      color: Color.fromARGB(255, 233, 233, 233),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 242, 242, 242)),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 242, 242, 242)),
      borderRadius: BorderRadius.circular(5),
    ),
    suffixIcon: IconButton(
      onPressed: () {
        setState(() {
          _isObscure2 = !_isObscure2;
        });
      },
      icon: _isObscure2 == true
          ? Icon(Icons.visibility_off)
          : Icon(Icons.visibility),
    ),
  ),
                          validator: (value) {
                            if (confirmpassController.text !=
                                passwordController.text) {
                              return "Password did not match";
                            } else {
                              return null;
                            }
                          },
                          onChanged: (value) {},
                        ),
                        SizedBox(
                          height: 20,
                        ),
                       Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    
    Row(
      children: options.map((String option) {
        return Row(
          children: [
            Radio(
              value: option,
              groupValue: rool,
              onChanged: (String? value) {
                setState(() {
                  rool = value!;
                });
              },
              activeColor: Colors.white,
              
            ),
            Text(
              option,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        );
      }).toList(),
    ),
  ],
),

                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              elevation: 5.0,
                              height: 40,
                              onPressed: () {
                                CircularProgressIndicator();
                                Navigator.of(context).pushNamed("/loginbasedrole");
                              },
                              child: Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              color: Colors.white,
                            ),
                            MaterialButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20.0))),
                              elevation: 5.0,
                              height: 40,
                              onPressed: () {
                                setState(() {
                                  showProgress = true;
                                });
                                signUp(emailController.text,
                                    passwordController.text, rool);
                              },
                              child: Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Colors.yellowAccent[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void signUp(String email, String password, String rool) async {
    CircularProgressIndicator();
    if (_formkey.currentState!.validate()) {
      await _auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => {postDetailsToFirestore(email, rool)})
          .catchError((e) {});
    }
  }

  Future<void> postDetailsToFirestore(String email, String rool) async {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  var user = _auth.currentUser;

  // Reference the "users" collection and add a document to it
  CollectionReference ref = FirebaseFirestore.instance.collection('users');
  ref.doc(user!.uid).set({'email': email, 'rool': rool});
  
  Navigator.of(context).pushNamed("/loginbasedrole");
}
}


