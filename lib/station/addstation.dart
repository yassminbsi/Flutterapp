import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddStation extends StatefulWidget {
  const AddStation({super.key});

  @override
  State<AddStation> createState() => _AddStationState();
}

class _AddStationState extends State<AddStation> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nomstation= TextEditingController();
 TextEditingController latitude= TextEditingController();
 TextEditingController longtude= TextEditingController();
 
 CollectionReference station = FirebaseFirestore.instance.collection('station');
bool isLoading= false;
AddStation() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    DocumentReference response = await station.add(
  {
    "id" : FirebaseAuth.instance.currentUser!.uid,
    "nomstation": nomstation.text,
    "latitude": latitude.text,
    "longtude": longtude.text,
    
    // Ajoutez d'autres champs du bus au besoin
  },
);
    Navigator.of(context).pushNamedAndRemoveUntil("/HomeStation", (route) => false);
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
    nomstation.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("", style: TextStyle(color: Colors.white),),
      backgroundColor: Color.fromARGB(255, 50, 112, 173),
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
          child: Text("Ajouter une station",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
                ),
                Container(height: 20,),
                Text("Nom de station", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
                CustomTextForm(
          hinttext: "Entrer nom de station ",
          mycontroller: nomstation,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          }, 
                ),
                SizedBox(height: 10),
                Text("Latitude", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ), // Ajout d'un espace vertical entre les champs de texte
                CustomTextForm(
          hinttext: "Entrer latitude",
          mycontroller: latitude,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("Longtude", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
                CustomTextForm(
          hinttext: "Entrer longtude",
          mycontroller: longtude,
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
              child: Text("Sauvegarder Station"),
              onPressed: (){
                AddStation();
              },)
          
          ],),
        ),
      ),

    );
  }
}