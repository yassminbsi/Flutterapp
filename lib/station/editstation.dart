import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

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
    //Navigator.of(context).pushNamedAndRemoveUntil("/ControlePage", (route) => false);
    Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 3,), 
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
     appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
        'Modifier Station', style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
         ),
      actions: [
        Row(
          children: [
            Text("", style: TextStyle(color: Color(0xFFffd400)),),
            IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/loginbasedrole", (route) => false);
            }, icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400),)),
          ],
        )
        ],),
      body: Form(
        key: formState,
        child: isLoading ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage("images/font.jpg"),
              fit: BoxFit.cover,)),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
              
             children: [
             CustomLogoAuth(),
             Center(
              
             child: Row(
              mainAxisAlignment:MainAxisAlignment.center,
             children: [
             Icon(Icons.edit , color:Color(0xFF6750A4),size: 30,), // Ajoutez l'icône de modification ici
             SizedBox(width: 5), // Pour espacer l'icône du texte
             Text("Modifier station",
             style: TextStyle(
             fontSize: 25,
             fontWeight: FontWeight.bold,
             color: Color(0xFF6750A4),
        ),
      ),
    ],
  ),
),
  Container(height: 20,), 
 TextFormField(
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6750A4)),
                                borderRadius: BorderRadius.circular(30)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6750A4)),
                                borderRadius: BorderRadius.circular(30)), 
                              prefixIcon: Icon(Icons.directions_bus, color: Color(0xFF6750A4),),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                               label: Text("Nom de station"),
                               labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                            controller: nomstation,
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
                                borderRadius: BorderRadius.circular(30)),
                              enabledBorder: OutlineInputBorder(
                              
                                borderSide: BorderSide(color: Color(0xFF6750A4)),
                                borderRadius: BorderRadius.circular(30)), 
                              prefixIcon:Icon(Icons.my_location, color: Color(0xFF6750A4)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                               label: Text("Latitude"),
                               labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                            controller: latitude,
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
                                borderRadius: BorderRadius.circular(30)),
                              enabledBorder: OutlineInputBorder(
                              
                                borderSide: BorderSide(color: Color(0xFF6750A4)),
                                borderRadius: BorderRadius.circular(30)), 
                              prefixIcon: Icon(Icons.my_location_outlined,color: Color(0xFF6750A4)),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                               label: Text("Longitude"),
                               labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                            controller: longtude,
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
                      title: "Modifier",
                      onPressed: (){
                       EditStation();
                       ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                           content: Text('La station a été modifié avec succès', style: TextStyle(color: Colors.black), 
                           ),
                           backgroundColor: const Color.fromARGB(255, 197, 197, 197),
                           duration: Duration(seconds: 2),
              ),
              );
              },),
                      SizedBox(height: 20, width: 20,),
                      CustomButtonAuth(
                      title: "Annuler",
                      onPressed: (){
                      //Navigator.of(context).pushReplacementNamed("/ControlePage");
                      Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 3,), // 3 est l'index de l'onglet "AccueilAdmin"
                ),
                );
                      },),
              ],
            ),
            ],
            ),
            ),

  ],),
  ),
      ),

    );
  }
}