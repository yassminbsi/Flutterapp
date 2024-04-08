import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditBus extends StatefulWidget {
  final String docid;
  final String oldnombus;
  final String oldstation;
  const EditBus({super.key, required this.docid, required this.oldnombus, required this.oldstation, });

  @override
  State<EditBus> createState() => _EditBusState();
}

class _EditBusState extends State<EditBus> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nombus= TextEditingController();
 TextEditingController station= TextEditingController();
 CollectionReference bus = FirebaseFirestore.instance.collection('bus');
bool isLoading= false;
EditBus() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    await bus.doc(widget.docid).update({
      "nombus": nombus.text,
      "station":station.text,

    });
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
    station.dispose();
  }
@override
  void initState() {
    super.initState();
    nombus.text= widget.oldnombus;
    station.text= widget.oldstation;
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
          child: Text("Modifier ce bus",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
                ),
           Container(height: 20,), 
           Text("Nom de bus", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
              ),
           SizedBox(height: 10),      
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
                Text("Station", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
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
              color: Color(0xFFFFCA20),
                      child: Text("Sauvegarder",  style: TextStyle(color : Color(0xFF25243A),)),
              onPressed: (){
                EditBus();
              },)
          
          ],),
        ),
      ),

    );
  }
}