import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}

class _AddAdminState extends State<AddAdmin> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  CollectionReference admin = FirebaseFirestore.instance.collection('admin');
  bool isLoading = false;
  bool showpass = true;
  AddAdmin() async {
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {});
        DocumentReference response = await admin.add(
          {
            "nom": nom.text,
            "Utilisateur": {
              "id": FirebaseAuth.instance.currentUser!.uid,
            },
            "prenom": prenom.text,
            "phone": phone.text,
            "email": email.text,
            "password": password.text,
            "confirmpassword": confirmpassword.text,
            // "role": "admin"
            // Ajoutez d'autres champs du bus au besoin
          },
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil("/dashboard", (route) => false);
      } catch (e) {
        isLoading = false;
        setState(() {});
        print("Error $e");
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nom.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        backgroundColor: Color(0xFF25243A),
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        title:  const Text('Ajouter Admin',  style: TextStyle(color: Color(0xFFffd400)),),
        
        ),
      body: Form(
        key: formState,
        child: isLoading
            ? Container(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 65, vertical: 95),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         
                          Center(
                            child: Text("Informations Générales",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color:  Color(0xFF25243A))),
                          ),
                          SizedBox(
                              height:
                                  40), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val == "") {
                                return "Veuillez saisir votre nom";
                              }
                            },
                            controller: nom,
                            decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Nom',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
                          ),
                          SizedBox(
                              height:
                                  30), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val == "") {
                                return "Veuillez saisir votre prénom";
                              }
                            },
                            controller: prenom,
                           decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Prénom',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
                          ),
                          SizedBox(
                              height:
                                  30), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Veuillez saisir votre téléphone";
                              } else if (int.tryParse(val) == null) {
                                return "Format invalide. Entrez un numéro de téléphone valide.";
                              }
                            },
                            controller: phone,
                            decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Téléphone',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
                          ),
                          SizedBox(
                              height:
                                  30), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val == "") {
                                return "Veuillez saisir votre email.";
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)) {
                                return "Format invalide (ex: exemple@gmail.com)";
                              }
                            },
                            controller: email,
                           decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Email',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
                          ),
                          SizedBox(
                              height:
                                  30), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
  validator: (val) {
    if (val!.isEmpty) {
      return "Veuillez saisir votre mot de passe.";
    } else if (val != password.text) {
      return "Les mots de passe ne correspondent pas";
    }
  },
  obscureText: showpass,
  controller: password,
  decoration: InputDecoration(
    border: OutlineInputBorder(),
    labelText: 'Saisir votre mot de passe',
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFCA20)),
      borderRadius: BorderRadius.circular(5),
    ),
    suffixIcon: IconButton(
      onPressed: () {
        setState(() {
          showpass = !showpass;
        });
      },
      icon: showpass == true
          ? Icon(Icons.visibility_off)
          : Icon(Icons.visibility),
    ),
  ),
)
,
                          SizedBox(height: 30),
                          // Ajout d'un espace vertical entre les champs de texte

                          TextFormField(
  validator: (val) {
    if (val!.isEmpty) {
      return "Veuillez saisir votre mot de passe.";
    } else if (val != password.text) {
      return "Les mots de passe ne correspondent pas";
    }
  },
  obscureText: showpass,
  controller: confirmpassword,
  decoration: InputDecoration(
    labelText: 'Confirmer mot de passe',
    floatingLabelBehavior: FloatingLabelBehavior.always,
    labelStyle: TextStyle(
      color: Colors.grey,
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFFFCA20)),
      borderRadius: BorderRadius.circular(5),
    ),
    suffixIcon: IconButton(
      onPressed: () {
        setState(() {
          showpass = !showpass;
        });
      },
      icon: showpass == true
          ? Icon(Icons.visibility_off)
          : Icon(Icons.visibility),
    ),
  ),
)
,
                          SizedBox(
                              height:
                                  10), // Ajout d'un espace vertical entre les champs de texte
                        ],
                      ),
                    ),
                    MaterialButton(
                      color: Color(0xFFFFCA20),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
        elevation: 5.0,
        minWidth: 200.0,
        height: 45,
              
              child: Text("Sauvegarder",  style: TextStyle(color : Color(0xFF25243A ),fontSize: 17.0, )),
                      onPressed: () {
                        AddAdmin();
                      },
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
      ),
    );
  }
}
