import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/view/dashboard/controlepage.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

class AddStationCurrentPosition extends StatefulWidget {
  const AddStationCurrentPosition({super.key});
  @override
  State<AddStationCurrentPosition> createState() => _AddStationCurrentPositionState();
}
class _AddStationCurrentPositionState extends State<AddStationCurrentPosition> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nomstation= TextEditingController();
 TextEditingController currentposition= TextEditingController();
 CollectionReference station = FirebaseFirestore.instance.collection('station');
 bool isLoading= false;
 AddStationCurrentPosition() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
    });
    DocumentReference response = await station.add(
  {
    "id" : FirebaseAuth.instance.currentUser!.uid,
    "nomstation": nomstation.text,
    "latitude": currentposition.text,
  },
);
    //Navigator.of(context).pushNamedAndRemoveUntil("/ControlePage", (route) => false);
    Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 3), // 3 est l'index de l'onglet "AccueilAdmin"
                ),
                );
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
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("Ajout parcours", style: TextStyle(fontSize: 18,color: Color(0xFFffd400)),),
      backgroundColor: Color(0xFF25243A),
      iconTheme: IconThemeData(color: Color(0xFFffd400)),
      actions:[
        Row(
          children:[
            Text("", style: TextStyle(color: Color(0xFFffd400)),),
            IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            }, icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400))),
          ],
        )
        ],),
      body: Form(
        key: formState,
        child: isLoading ? Container(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
           /* decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("images/font.jpg"),
                    fit: BoxFit.cover,)),*/  
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                CustomLogoAuth(),
                Center(
          child:
           Row(
            mainAxisAlignment:MainAxisAlignment.center,
             children: [
               Icon(Icons.add , color:Color(0xFF6750A4),size: 30,),
               Text("Ajouter une station",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF6750A4))),
             ],
           ),
                ),
          Container(height: 20,),
          TextFormField(
                        decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6750A4)),
                        borderRadius: BorderRadius.circular(40)),
                        enabledBorder: OutlineInputBorder(
                              
                        borderSide: BorderSide(color: Color(0xFF6750A4)),
                        borderRadius: BorderRadius.circular(40)), 
                              prefixIcon:Icon(Icons.my_location, color: Color(0xFF6750A4)),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed("/Selectcurrentposition");
                                },
                                icon: Icon(Icons.place,
                              ) ,),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(40),),
                               label: Text("Current location"),
                               labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                            controller: currentposition,
                            validator: (val) {
                              if (val == "") {
                                return "Ne peut pas être vide";
                              }
                            },
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6750A4)),
                                borderRadius: BorderRadius.circular(40)),
                              enabledBorder: OutlineInputBorder(
                              
                                borderSide: BorderSide(color: Color(0xFF6750A4)),
                                borderRadius: BorderRadius.circular(40)), 
                              prefixIcon: Icon(Icons.directions_bus,color: Color(0xFF6750A4),),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(40),),
                               label: Text("Nom de station"),
                               labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                            controller: nomstation,
                            validator: (val) {
                              if (val == "") {
                                return "Ne peut pas être vide";
                              }
                            },
                          ),                            
            SizedBox(height: 20,),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButtonAuth(
                  title: "Sauvegarder Station",
                  onPressed: (){
                    AddStationCurrentPosition();
                    ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(
                               content: Text('La station a été ajoutée avec succès', style: TextStyle(color: Colors.black), 
                               ),
                               backgroundColor: const Color.fromARGB(255, 197, 197, 197),
                               duration: Duration(seconds: 2),
                    ),
                  );
                  },),
              ],
            )
               ],
            ),
          ),
          ],),
        ),
      ),
);
}
}