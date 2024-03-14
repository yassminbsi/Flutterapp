import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/customtextfieldadd.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditAdmin extends StatefulWidget {
  final String docid;
  final String oldnom;
  final String oldprenom;
  final String oldphone;
  final String oldemail;
  final String oldpassword;
  final String oldconfirmpassword;

  const EditAdmin({super.key, required this.docid, required this.oldnom, required this.oldprenom, required this.oldphone, required this.oldemail, required this.oldpassword, required this.oldconfirmpassword});

  @override
  State<EditAdmin> createState() => _EditAdminState();
}

class _EditAdminState extends State<EditAdmin> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nom= TextEditingController();
 TextEditingController prenom= TextEditingController();
 TextEditingController phone= TextEditingController();
 TextEditingController email= TextEditingController();
 TextEditingController password= TextEditingController();
 TextEditingController confirmpassword= TextEditingController();
 CollectionReference admin = FirebaseFirestore.instance.collection('admin');
bool isLoading= false;
EditAdmin() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    await admin.doc(widget.docid).update({
      "nom": nom.text,
      "prenom":prenom.text,
      "phone":phone.text,
      "email":email.text,
      "password":password.text,
      "confirmpassword":confirmpassword.text,

    });
    Navigator.of(context).pushNamedAndRemoveUntil("/AccueilAdmin", (route) => false);
    } catch(e) {
      isLoading= false;
      setState(() {
        
      });
      print("Error $e");
    }
  }
}
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nom.dispose();
    prenom.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    confirmpassword.dispose();

  }
@override
  void initState() {
    super.initState();
    nom.text= widget.oldnom;
    prenom.text= widget.oldprenom;
    phone.text= widget.oldphone;
    email.text= widget.oldemail;
    password.text= widget.oldpassword;
    confirmpassword.text= widget.oldconfirmpassword;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("", style: TextStyle(color: Colors.black54),),
      
      actions: [
        Row(
          children: [
            Text("Déconnexion", style: TextStyle(color: Colors.black54),),
            IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            }, icon: Icon(Icons.exit_to_app, color: Colors.black54,)),
          ],
        )
        ],
        ),
      body: Form(
        key: formState,
        child: isLoading ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
               crossAxisAlignment: CrossAxisAlignment.start, 
               mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomLogoAuth(),
                Center(
          child: Text("Modifier admin",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
                ),
                Container(height: 10,),
                Text("Nom", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
              ),
                CustomTextFormAdd(
          hinttext: "Entrer nom ",
          mycontroller: nom,
          validator: (val) {
            if (val == "") {
              return "Veuillez saisir votre nom";
            }
          }, 
          
                ),
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("Prénom", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
              ),
                CustomTextFormAdd(
          hinttext: "Entrer prénom",
          mycontroller: prenom,
          validator: (val) {
            if (val == "") {
              return "Veuillez saisir votre prénom";
            }
          },
          ),
SizedBox(height: 10),
Text(
  "Numéro de tél.",
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
),
CustomTextFormAdd(
  hinttext: "Entrer numéro de tél.",
  mycontroller: phone,
  validator: (val) {
    if (val!.isEmpty) {
      return "Veuillez saisir votre N° de téléphone";
    } else if (int.tryParse(val) == null) {
      return "Format invalide. Entrez un numéro de téléphone valide.";
    }
  },
),      
SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
          Text("Email", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
),
CustomTextFormAdd(
  hinttext: "Entrer email",
  mycontroller: email,
  validator: (val) {
    if (val == "") {
      return "Veuillez saisir votre e-mail";
    } else if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!)) {
      return "Format invalide (ex: exemple@gmail.com)";
    }
  },
),

                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text(
  "Mot de passe",
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
CustomTextFormAdd(
  hinttext: "Entrer mot de passe",
  mycontroller: password,
  validator: (val) {
    if (val!.isEmpty) {
      return "Veuillez saisir votre mot de passe";
    }
  },
),
SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
Text(
  "Confirmer mot de passe",
  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
),
CustomTextFormAdd(
  hinttext: "Confirmer mot de passe",
  mycontroller: confirmpassword,
  validator: (val) {
    if (val!.isEmpty) {
      return "Veuillez saisir votre mot de passe";
    } else if (val != password.text) {
      return "Les mots de passe ne correspondent pas";
    }
  },
),

              ],
            ),
            ),
            MaterialButton(
              child: Text("Sauvegarder") ,
              onPressed: (){
                EditAdmin();
              },)
          
          ],),
        ),
      ),

    );
  }
}