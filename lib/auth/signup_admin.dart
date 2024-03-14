import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class signupAdmin extends StatefulWidget {
  const signupAdmin({super.key});

  @override
  State<signupAdmin> createState() => _signupAdminState();
}

class _signupAdminState extends State<signupAdmin> {
  TextEditingController email = TextEditingController();
  TextEditingController nom = TextEditingController();
  TextEditingController prenom = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  bool showpass = true;
  
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(children: [
          Form(
            key: formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              
               CustomLogoAuth(),
            
            Center(
              child: Text("S'inscrire",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            Center(child: Text("Créer un compte Admin", style: TextStyle(color: Colors.grey))),
            SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
      validator: (val) {
        if (val == "") {
         return "Ne peut pas être vide";
       }
      }, 
  controller: nom,
  decoration: InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),
    
    ),
    label: Text('Nom')
  ),
),
SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
      validator: (val) {
        if (val == "") {
         return "Ne peut pas être vide";
       }
      }, 
  controller: prenom,
  decoration: InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Prénom')
  ),
),
 SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
  validator: (val) {
    if (val!.isEmpty) {
      return "Ne peut pas être vide";
    } else if (int.tryParse(val) == null) {
      return "Format invalide. Entrez un numéro de téléphone valide.";
    }
  }, 
  controller: phone,
  decoration: InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Numéro de tél.')
  ),
),
 SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
  validator: (val) {
    if (val == "") {
      return "Ne peut pas être vide";
    } else if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!)) {
      return "Format invalide (ex: exemple@gmail.com)";
    }
  },
  controller: email,
  decoration: InputDecoration(
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Email')
  ),
),
 SizedBox(height: 10),// Ajout d'un espace vertical entre les champs de texte  
TextFormField(
  validator: (val){
     if (val!.isEmpty) {
      return "Ne peut pas être vide";
    }
  },
  obscureText: showpass,
  controller: password,
  decoration: InputDecoration(
    suffixIcon: IconButton(
      onPressed: (){
        setState(() {
          showpass=! showpass;
        });
      },icon: showpass== true? Icon(Icons.visibility_off):Icon(Icons.visibility)),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Mot de passe')
  ),
),
  SizedBox(height: 10),
                 // Ajout d'un espace vertical entre les champs de texte
   
TextFormField(
    validator: (val) {
    if (val!.isEmpty) {
      return "Ne peut pas être vide";
    } else if (val != password.text) {
      return "Les mots de passe ne correspondent pas";
    }
  }, 
  obscureText: showpass,
  controller: confirmpassword,
  decoration: InputDecoration(
    suffixIcon: IconButton(
      onPressed: (){
        setState(() {
          showpass=! showpass;
        });
      },icon: showpass== true? Icon(Icons.visibility_off):Icon(Icons.visibility)),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    label: Text('Confirmer mot de passe')
  ),
), 
],
            ),
          ),
          Container(height: 10),
          MaterialButton(child:   Text("s'inscrire"), onPressed: () async {
          if (formState.currentState!.validate()) {  
          try {
            final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email.text,
            password: password.text,);
            FirebaseAuth.instance.currentUser!.sendEmailVerification();
            Navigator.of(context).pushReplacementNamed("login");
          } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
           print('The password provided is too weak.');
            AwesomeDialog(
             context: context,
             dialogType: DialogType.error,
             animType: AnimType.rightSlide,
             title: 'Error',
             desc: 'The password provided is too weak.',
            ).show();
          } else if (e.code == 'email-already-in-use') {
           print('The account already exists for that email.');
            AwesomeDialog(
             context: context,
             dialogType: DialogType.error,
             animType: AnimType.rightSlide,
             title: 'Error',
             desc: 'The account already exists for that email.',
            ).show();
          }
          } catch (e) {
           print(e);
          }
          } else {
  print("Not valid");
}
  } ,),
          Container(height: 10),
          InkWell(
            onTap: () {
              Navigator.of(context).pushNamed("/loginAdmin");
            },
            child:Center(
             child: Text.rich(TextSpan(children: [
              TextSpan(
                text: "Avez-vous un compte ?",
              ),
              TextSpan(
                text: "Se connecter",
                style: TextStyle(color: Color.fromARGB(255, 25, 96, 167), fontWeight: FontWeight.bold),
              ),
            ])),
            )
          )


        ],)

      ),
    );
  }
}
