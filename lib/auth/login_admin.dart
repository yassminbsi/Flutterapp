import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginAdmin extends StatefulWidget {
  const LoginAdmin({super.key});

  @override
  State<LoginAdmin> createState() => _LoginAdminState();
}

class _LoginAdminState extends State<LoginAdmin> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading= false;
  bool showpass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading ? Center(child: CircularProgressIndicator())
        :Container(
        padding: EdgeInsets.all(20),
        child: ListView(children: [
          Form(
            key: formState,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Container(height: 20),
               CustomLogoAuth(),
            Container(height: 5),
            Center(
              child: Text("Se connecter",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            ),
            
            //Container(height: 20),
            //Text("Email", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
            //),
           // Container(height: 10),
           // CustomTextForm(hinttext: "Entrer votre Email", mycontroller: email, validator: (val) {
           //   if (val == ""){
            //    return "Ne peut pas être vide.";
            //  }
            //},),
  SizedBox(height: 20),
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
 SizedBox(height: 20),// Ajout d'un espace vertical entre les champs de texte  
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
        //    Text("Mot de passe" , style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
         //   ),
         //   Container(height: 10),
         //   CustomTextForm(hinttext: "Entrer votre mot de passe", mycontroller: password , validator: (val) {
          //    if (val == ""){
          //      return "Ne peut pas être vide.";
          //    }
         //   }),
            InkWell(
              onTap: () async{
                if (email.text == "") {
                  AwesomeDialog(
             context: context,
             dialogType: DialogType.error,
             animType: AnimType.rightSlide,
             title: 'Error',
             desc: 'Enter Your Email',
            ).show();
                  return;
                }
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
                AwesomeDialog(
             context: context,
             dialogType: DialogType.success,
             animType: AnimType.rightSlide,
             title: 'success',
             desc: 'Send Email',
            ).show();
              } catch (e) {
                AwesomeDialog(
                context: context,
                dialogType: DialogType.error,
                animType: AnimType.rightSlide,
                title: 'Error',
                desc: 'Verified your Email and try again',
            ).show();
             }  
                
              },
              child: Container(
                margin: EdgeInsets.only(top: 10, bottom:20 ),
                alignment: Alignment.topRight,
                child: Text(
                  "mot de passe oublié?",
                  style: TextStyle( fontSize: 14,),
                ),
              ),
            )
            ],
            ),
          ),
          MaterialButton(child: Text("Se connecter"), onPressed: () async {
            if (formState.currentState!.validate()) {
          try {
            isLoading= true;
            setState(() {
              
            });
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email.text,
    password: password.text,
  );
  isLoading= false;
            setState(() {
              
            });
  if (credential.user!.emailVerified){
   
     Navigator.pushNamed( context,"/HomeAdmin");
  } else {
    AwesomeDialog(
             context: context,
             dialogType: DialogType.error,
             animType: AnimType.rightSlide,
             title: 'Erreur',
             desc: 'Veuillez vérifier votre e-mail',
            ).show();
  }
} on FirebaseAuthException catch (e) {
  isLoading= false;
  setState(() {  });
  if (e.code == 'Utilisateur introuvable') {
    print('Aucun utilisateur trouvé pour cet e-mail.');
    AwesomeDialog(
             context: context,
             dialogType: DialogType.error,
             animType: AnimType.rightSlide,
             title: 'Erreur',
             desc: 'Utilisateur introuvable pour cet e-mail.',
            ).show();
  } else if (e.code == 'Mot de passe incorrect') {
    print('Mot de passe incorrect fourni pour cet utilisateur.');
    AwesomeDialog(
             context: context,
             dialogType: DialogType.error,
             animType: AnimType.rightSlide,
             title: 'Erreur',
             desc: 'Mot de passe incorrect fourni pour cet utilisateur.',
            ).show();
  }
}} else {
  print("Non valide");
}
          },),
          Container(height: 20),
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacementNamed("/signupAdmin");
            },
            child:Center(
             child: Text.rich(TextSpan(children: [
              TextSpan(
                text: "Vous n'avez pas de compte ?",
              ),
              TextSpan(
                text: "S'inscrire",
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