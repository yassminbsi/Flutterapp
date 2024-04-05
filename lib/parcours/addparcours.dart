import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddParcours extends StatefulWidget {
  const AddParcours({super.key});

  @override
  State<AddParcours> createState() => _AddParcoursState();
}

class _AddParcoursState extends State<AddParcours> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
  TextEditingController nomparcours= TextEditingController();
 TextEditingController departparcours= TextEditingController();
 TextEditingController arriveparcours= TextEditingController();

 
 CollectionReference station = FirebaseFirestore.instance.collection('parcours');
bool isLoading= false;
AddParcours() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    DocumentReference response = await station.add(
  {
    "Utilisateur": {
      "id": FirebaseAuth.instance.currentUser!.uid,
    },
    "nomparcours" : nomparcours.text,
    "departparcours": departparcours.text,
    "arriveparcours": arriveparcours.text,
   
    
    // Ajoutez d'autres champs du bus au besoin
  },
);
    Navigator.of(context).pushNamedAndRemoveUntil("/HomeParcours", (route) => false);
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
    nomparcours.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("", style: TextStyle(color: Colors.white),),
     
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
        ],),
      body: Form(
        key: formState,
        child: isLoading ? Container(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomLogoAuth(),
                Center(
          child: Text("Ajouter une parcours",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
                ),
                Container(height: 20,),
                Text("Nom de parcours", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
                CustomTextForm(
          hinttext: "Entrer nom de parcours ",
          mycontroller: nomparcours,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          }, 
                ),
                SizedBox(height: 10),
                Text("arrivee parcours", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ), // Ajout d'un espace vertical entre les champs de texte
                CustomTextForm(
          hinttext: "arrivee parcours",
          mycontroller: arriveparcours,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("depart", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
                CustomTextForm(
          hinttext: "depart",
          mycontroller: departparcours,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                
              ],
            ),
          ),
            MaterialButton(
              child: Text("Sauvegarder Parcours"),
              onPressed: (){
                AddParcours();
              },)
          
          ],),
        ),
      ),

    );
  }
}