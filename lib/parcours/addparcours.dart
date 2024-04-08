import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
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

 
 CollectionReference parcours = FirebaseFirestore.instance.collection('parcours');
bool isLoading= false;
AddParcours() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    DocumentReference response = await parcours.add(
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
     appBar: AppBar(
        backgroundColor: Color(0xFF25243A),
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        title:  const Text('Ajouter Parcours',  style: TextStyle(color: Color(0xFFffd400)),),
      
        ),
     
     
      body: Form(
        key: formState,
        child: isLoading ? Container(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 65, vertical: 55),
            
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
              Center(
                            child: Text("Informations Générales",
                                style: TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color:  Color(0xFF25243A))),
                          ),
                          SizedBox(
                              height:
                                  40),
                
                TextFormField(
          
          controller: nomparcours,
           decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Nom Parcours',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          }, 
                ),
                SizedBox(height: 30),
                TextFormField(
          
          controller: departparcours,
          decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Depart Parcours',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                SizedBox(height: 30),
               
              
               // Ajout d'un espace vertical entre les champs de texte
                 TextFormField(
          
          controller: arriveparcours,
          decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: ' Arrivée Parcours',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    labelStyle: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(0xFFFFCA20)),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                   
                                    
                                  ),
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                // Ajout d'un espace vertical entre les champs de texte
                
                 
                
              ],
            ),
          ),
            MaterialButton(
              color: Color(0xFFFFCA20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
        elevation: 5.0,
        minWidth: 200.0,
        height: 45,
              
              child: Text("Sauvegarder",  style: TextStyle(color : Color(0xFF25243A ),fontSize: 17.0, )),
              onPressed: (){
                AddParcours();
              },)
              
          
          ],),
        ),
      ),

    );
  }
}