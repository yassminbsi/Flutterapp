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
        actions: [
          Row(
          children: [
            Text("Déconnexion", style: TextStyle(color: Colors.white),),
            IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            }, icon: Icon(Icons.exit_to_app, color: Colors.white,)),
          ],
        )
        ],
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
                          EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomLogoAuth(),
                          Center(
                            child: Text("Ajouter un admin",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54)),
                          ),
                          SizedBox(
                              height:
                                  10), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val == "") {
                                return "Veuillez saisir id Admin";
                              }
                            },
                            controller: nom,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text('Nom')),
                          ),
                          SizedBox(
                              height:
                                  10), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val == "") {
                                return "Veuillez saisir votre nom";
                              }
                            },
                            controller: prenom,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text('Prénom')),
                          ),
                          SizedBox(
                              height:
                                  10), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Veuillez saisir votre prénom";
                              } else if (int.tryParse(val) == null) {
                                return "Format invalide. Entrez un numéro de téléphone valide.";
                              }
                            },
                            controller: phone,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text('Numéro de tél.')),
                          ),
                          SizedBox(
                              height:
                                  10), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val == "") {
                                return "Veuillez saisir votre N° téléphone.";
                              } else if (!RegExp(
                                      r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(val!)) {
                                return "Format invalide (ex: exemple@gmail.com)";
                              }
                            },
                            controller: email,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text('Email')),
                          ),
                          SizedBox(
                              height:
                                  10), // Ajout d'un espace vertical entre les champs de texte
                          TextFormField(
                            validator: (val) {
                              if (val!.isEmpty) {
                                return "Veuillez saisir votre e-mail.";
                              }
                            },
                            obscureText: showpass,
                            controller: password,
                            decoration: InputDecoration(
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showpass = !showpass;
                                      });
                                    },
                                    icon: showpass == true
                                        ? Icon(Icons.visibility_off)
                                        : Icon(Icons.visibility)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text('Mot de passe')),
                          ),
                          SizedBox(height: 10),
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
                                suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        showpass = !showpass;
                                      });
                                    },
                                    icon: showpass == true
                                        ? Icon(Icons.visibility_off)
                                        : Icon(Icons.visibility)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                label: Text('Confirmer mot de passe')),
                          ),
                          SizedBox(
                              height:
                                  5), // Ajout d'un espace vertical entre les champs de texte
                        ],
                      ),
                    ),
                    MaterialButton(
                      color: Color(0xFFFFCA20),
                      child: Text("Ajouter",  style: TextStyle(color: Colors.black54)),
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
