import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
    'Client',
  ];
  Color getRadioButtonColor(Set<MaterialState> states) {
    // If the radio button is selected, return yellow, else return blue
    if (states.contains(MaterialState.selected)) {
      return Color.fromARGB(255, 255, 255, 255);
    }
    return Color.fromARGB(255, 253, 253, 253);
  }

  var _currentItemSelected = "Admin";
  var rool = "Admin";
  Color buttonColor = Color(0xFF25243A);
Color textColor = Color(0xFFffd400); 
  @override
  Widget build(BuildContext context) {
    return Scaffold(

                               
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox( height: 20,),
          Image.asset("images/308.png", height: 200,),
          SizedBox(height: 30,),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 11),
              child: Container(
              //  height: 550,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  color:  Color(0xFF25243A),
                  border: Border(
                    left: BorderSide(
                      width: 3,
                    ),
                  ),
                ),
                child: Container(
                  child: Container(
                    margin: EdgeInsets.all(22),
                    child: Form(
                      key: _formkey,
                      child: Column(
                        children: [
                          Text(
                            "Commencer",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFffd400),
                              fontSize:35,
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            cursorColor:Color(0xFFffd400), 
                            style: TextStyle(color: Colors.white),
                            controller: emailController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '  E-mail',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: const Color.fromARGB(255, 255, 255, 255),
                              ),
                              contentPadding: EdgeInsets.only(left: 14.0,bottom: 8.0,top: 15.0,),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFffd400),),
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
                            cursorColor:Color(0xFFffd400), 
                            style: TextStyle(color: Colors.white),
                            obscureText: _isObscure,
                            controller: passwordController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: '  Saisir votre mot de passe',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: Colors.white,
                              ),
                              contentPadding: EdgeInsets.only(left: 14.0,bottom: 8.0,top: 15.0,),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 242, 242, 242)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFffd400),),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              suffixIcon: IconButton(
                                color: Color.fromARGB(255, 242, 242, 242),
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
                            cursorColor:Color(0xFFffd400), 
                            style: TextStyle(color: Colors.white),
                            obscureText: _isObscure2,
                            controller: confirmpassController,
                            decoration: InputDecoration(
                              labelText: '  Confirmer mot de passe',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: Color.fromARGB(255, 233, 233, 233),
                              ),
                              contentPadding: EdgeInsets.only(left: 14.0,bottom: 8.0,top: 15.0,),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 242, 242, 242)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFffd400), ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              suffixIcon: IconButton(
                                color: Color.fromARGB(255, 242, 242, 242),
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
                         /* Row(
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
                                        fillColor: MaterialStateColor.resolveWith(
                                            getRadioButtonColor),
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
                          ),*/
                          SizedBox(
                            height: 15,
                          ),
                          /*Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                            MaterialButton(
                             shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.all(Radius.circular(20.0)),
                             side: BorderSide(color: Color(0xFFffd400)),
                ),
                elevation: 5.0,
                height: 40,
                onPressed: () {
                  CircularProgressIndicator(); // Je ne suis pas sûr de ce que vous voulez ici, c'est peut-être une erreur
                  Navigator.of(context).pushNamed("/loginbasedrole");
                },
                child: Text(
                  "  Login  ",
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 18,
                    color: Color(0xFFffd400),
                  ),
                ),
                color: Color(0xFF25243A),
              ),*/
              
               MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      side: BorderSide(color: Color(0xFFffd400)),
                    ),
                    elevation: 5.0,
                    height: 40,
                    onPressed: () {
                      setState(() {
                        showProgress = true;
                        buttonColor = Color(0xFFffd400);
                        textColor = Color(0xFF25243A);
                      });
                      signUp(emailController.text, passwordController.text, rool);
                    },
                    child: Text(
                      "S'inscrire",
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    color: buttonColor,
                  ),
              
              
                          //  ],
                        //  ),
                          SizedBox(height: 20,),
                          InkWell(
              onTap: () {
                Navigator.of(context).pushNamed("/loginbasedrole");
              },
              child:Center(
               child: Text.rich(TextSpan(children: [
                TextSpan(
                  text: "Avez-vous un compte ?",
                  style: TextStyle(color: Colors.white)
                ),
                TextSpan(
                  text: " Se connecter",
                  style: TextStyle(color: Color(0xFFffd400), fontWeight: FontWeight.normal, fontSize: 14),
                ),
              ])),
              )
                        )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
           
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

    
    CollectionReference ref = FirebaseFirestore.instance.collection('users');
    ref.doc(user!.uid).set({'email': email, 'rool': rool});

    Navigator.of(context).pushNamed("/loginbasedrole");
  }
}
