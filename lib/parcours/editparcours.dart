import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditParcours extends StatefulWidget {
   final String docid;
  final String nomparcours;
  final String departparcours;
  final String arriveparcours;
  
  const EditParcours({super.key, required this.docid, required this.nomparcours,  required this.departparcours, required this.arriveparcours, });

  @override
  State<EditParcours> createState() => _EditStationState();
}

class _EditStationState extends State<EditParcours> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nomparcours= TextEditingController();
 TextEditingController departparcours= TextEditingController();
 TextEditingController arriveparcours= TextEditingController();
 
 CollectionReference parcours = FirebaseFirestore.instance.collection('parcours');
bool isLoading= false;
EditParcours() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    await parcours.doc(widget.docid).update({
      "nomparcours": nomparcours.text,
      "departparcours": departparcours.text,
      "arriveparcours":arriveparcours.text,
      

    });
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
    departparcours.dispose();
    arriveparcours.dispose();
  }
@override
  void initState() {
    super.initState();
    nomparcours.text= widget.nomparcours;
    departparcours.text= widget.departparcours;
    arriveparcours.text= widget.arriveparcours;
    

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
          child: Text("Modifier parcours",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
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
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("Arrivee", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
                CustomTextForm(
          hinttext: "Entrer Arrivée",
          mycontroller: departparcours,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                SizedBox(height: 10),
                Text("Depart", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
                CustomTextForm(
          hinttext: "Entrer Depart",
          mycontroller: arriveparcours,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                
              ],
            ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    MaterialButton(
                      child: Text("Modifier"),
                      onPressed: (){
                       EditParcours();
                      },),
                      SizedBox(height: 30, width: 20,),
                      MaterialButton(
                      child: Text("Annuler"),
                      onPressed: (){
                      Navigator.of(context).pushReplacementNamed("/HomeParcours");
                      },),
                 
               
              ],
            )
  ],),
        ),
      ),

    );
  }
}