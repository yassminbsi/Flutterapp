import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddBus extends StatefulWidget {
  const AddBus({super.key});

  @override
  State<AddBus> createState() => _AddBusState();
}

class _AddBusState extends State<AddBus> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nombus= TextEditingController();
 TextEditingController station= TextEditingController();
 CollectionReference bus = FirebaseFirestore.instance.collection('bus');
bool isLoading= false;
AddBus() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    DocumentReference response = await bus.add(
  {
    "nombus": nombus.text,
    "Utilisateur": {
      "id": FirebaseAuth.instance.currentUser!.uid,
    },
    "station": station.text,
    // Ajoutez d'autres champs du bus au besoin
  },
);
    Navigator.of(context).pushNamedAndRemoveUntil("/HomeBus", (route) => false);
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
    nombus.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar( backgroundColor: Color(0xFF25243A),
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        title:  const Text('Ajouter Bus',  style: TextStyle(color: Color(0xFFffd400)),),
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
        child: isLoading ? Center(child: CircularProgressIndicator()) : 
        SingleChildScrollView(
          child: Column(children: [
            Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                 CustomLogoAuth(),
          
                Center(
          child: Text("",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
                ),
                Container(height: 20,),
                Text("Nom de bus", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
          CustomTextForm(
          hinttext: "Entrer le nom de bus",
          mycontroller: nombus,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("Station", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
          CustomTextForm(
          hinttext: "choisir station",
          mycontroller: station,
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
              child: Text("Sauvegarder bus"),
              onPressed: (){
                AddBus();
              },)
          
          ],),
        ),
      ),

    );
  }
}