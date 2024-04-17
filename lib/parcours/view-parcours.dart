import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/auth/home_admin.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/parcours/addparcours.dart';
import 'package:flutter_app/parcours/editparcours.dart';
import 'package:flutter_app/station/addstation.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeParcours extends StatefulWidget {
  
  const HomeParcours({super.key});
  State<HomeParcours> createState() => _HomeParcoursState();
}

class _HomeParcoursState extends State<HomeParcours> {
List<QueryDocumentSnapshot> data = [];
bool isLoading= true;
getData() async{
  QuerySnapshot querySnapshot=
  await FirebaseFirestore.instance.collection("parcours").get();
  
  data.addAll(querySnapshot.docs) ;
  isLoading= false;
  setState(() {
    
  });
}
@override
  void initState() {
    getData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
     User? user = FirebaseAuth.instance.currentUser;
    
    String? email = user?.email;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Color(0xFFFFCA20),
        foregroundColor: Colors.black54,
        onPressed:() {
          Navigator.of(context).pushNamed("/AddParcours");
        } ,
        child: Icon(Icons.add),
        ),
     appBar: AppBar(
        backgroundColor: Color(0xFF25243A),
       leading: IconButton(
          icon: Icon(Icons.arrow_back), // Icon for returning to the previous component
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil("/dashboard", (route) => false);
          },
        ),
       
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        title:  const Text('Liste parcours',  style: TextStyle(color: Color(0xFFffd400), fontSize: 17), ),
       
        ),

     
      body:
      WillPopScope(
        child: isLoading== true ? Center(child: CircularProgressIndicator(),) 
        :GridView.builder(
          
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent:120 ),
          itemBuilder: (context, i) {
            return  InkWell(
                onTap: () {
                 // Navigator.of(context).push(MaterialPageRoute(
                  //  builder: (context) =>
                   // NoteView(categoryid: data[i].id)));
                },
                onLongPress: () {
                  AwesomeDialog(
               context: context,
               dialogType: DialogType.info,
               animType: AnimType.rightSlide,
               title: 'Confirmation',
               desc: 'Voulez-vous vraiment modifier ou supprimer ce bus?',
               btnCancelText: "Supprimer" ,
               btnOkText: "Modifier",
               btnCancelOnPress: ()  async {
               await FirebaseFirestore.instance.collection("parcours").doc(data [i].id).delete();
               Navigator.of(context).pushReplacementNamed("/HomeParcours");
               },
               btnOkOnPress: () async {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditParcours(
                  docid: data[i].id,
                  oldnomparcours: data[i]["nomparcours"],
                  olddepartparcours: data[i]["departparcours"],
                  oldarriveparcours: data[i]["arriveparcours"],

    
                
                  )));
               }).show();
                },
                child: Card(
                  child: Container(
                    padding:EdgeInsets.all(10),
                    color: Color.fromARGB(255, 236, 236, 236),
                    child: Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     
                      // Aligner les éléments en haut
                      children: [
                       Image.asset("images/308.png", height: 50,),
                        SizedBox(width: 8), // Espace entre l'image et le texte
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligner les textes à gauche
                         children: [
                        
                         Text("parcours: ${data[i]['nomparcours']}"),
                          Text("Depart: ${data[i]['arriveparcours']}"),
                          Text("Arrivée: ${data[i]['departparcours']}"),
                            ],
                         ),
  ],
),
                  ),
                ),
              );
            
              
          },
             
             
          ), onWillPop: () {
            
            Navigator.of(context).pushNamedAndRemoveUntil("/HomeAdmin", (route) => false);
            return Future.value(false);
          },
      )
       );
  }
}