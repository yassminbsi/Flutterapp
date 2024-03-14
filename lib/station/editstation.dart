import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/componenents/textformfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditStation extends StatefulWidget {
  final String docid;
  final String oldnomstation;
  final String oldlatitude;
  final String oldlongtude;
  const EditStation({super.key, required this.docid,  required this.oldnomstation, required this.oldlatitude, required this.oldlongtude});

  @override
  State<EditStation> createState() => _EditStationState();
}

class _EditStationState extends State<EditStation> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nomstation= TextEditingController();
 TextEditingController latitude= TextEditingController();
 TextEditingController longtude= TextEditingController();
 
 CollectionReference station = FirebaseFirestore.instance.collection('station');
bool isLoading= false;
EditStation() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    await station.doc(widget.docid).update({
      "nomstation": nomstation.text,
      "latitude":latitude.text,
      "longtude":longtude.text,
      

    });
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
    latitude.dispose();
    longtude.dispose();
  }
@override
  void initState() {
    super.initState();
    nomstation.text= widget.oldnomstation;
    latitude.text= widget.oldlatitude;
    longtude.text= widget.oldlongtude;
    

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
          child: Text("Modifier station",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
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
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("Latitude", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),
              ),
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
                SizedBox(height: 10),
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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    MaterialButton(
                      child: Text("Modifier"),
                      onPressed: (){
                       EditStation();
                      },),
                      SizedBox(height: 30, width: 20,),
                      MaterialButton(
                      child: Text("Annuler"),
                      onPressed: (){
                      Navigator.of(context).pushReplacementNamed("/HomeStation");
                      },),
                 
               
              ],
            )
  ],),
        ),
      ),

    );
  }
}