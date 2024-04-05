import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/auth/home_admin.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/editbus.dart';
import 'package:flutter_app/parcours/addparcours.dart';
import 'package:flutter_app/parcours/view-parcours.dart';
import 'package:flutter_app/station/addstation.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeBus extends StatefulWidget {
  const HomeBus({super.key});
  State<HomeBus> createState() => _HomeBusState();
}

class _HomeBusState extends State<HomeBus> {
List<QueryDocumentSnapshot> data = [];
bool isLoading= true;
getData() async{
  QuerySnapshot querySnapshot=
  await FirebaseFirestore.instance.collection("bus").get();
  
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
          Navigator.of(context).pushNamed("/AddBus");
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
        title:  const Text('Liste de Bus',  style: TextStyle(color: Color(0xFFffd400)),),
        actions: [
          Row(
            children: [
              Text("Déconnexion", style: TextStyle(color: Color.fromARGB(255, 183, 178, 178)),),
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                      }, icon: Icon(Icons.exit_to_app, color: const Color.fromARGB(255, 183, 178, 178),)),
            ],
          )
        ],
      ),
      drawer:
      Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Image.asset('images/icon_user.png'),
                  ),
                 Text('Compte admin:'),
                Text(email ?? 'user@example.com', style: TextStyle(fontSize: 14),),
                ],
                ),
                ),
                ListTile(
                  onTap: () {Get.to(HomeAdmin());},
                  leading: Icon(Icons.home, color: Colors.white,),
                  title: Text(
                    'Home Admin',
                    style: TextStyle(color: Colors.white, fontSize: 24 ),
                  ),
                  tileColor: Color.fromARGB(255, 50, 112, 173),
                ),
                ListTile(
                  onTap: (){ Get.to(AddBus());},
                  leading: Icon(Icons.add),
                  title: Text('Ajouter bus'),
                ),
                ListTile(
                  onTap: (){ Get.to(HomeBus());},
                  leading: Icon(Icons.list),
                  title: Text('Gérer les lignes de bus',
                  ),
                ),
                ListTile(
                  onTap: (){ Get.to(AddAdmin());},
                  leading: Icon(Icons.add),
                  title: Text('Ajouter Admin'),
                ),
                ListTile(
                  onTap: (){ Get.to(AccueilAdmin());},
                  leading: Icon(Icons.admin_panel_settings),
                  title: Text('Gérer les admins'),
                ),
                ListTile(
                  onTap: (){ Get.to(AddStation());},
                  leading: Icon(Icons.add),
                  title: Text('Ajouter Station'),
                ),
                ListTile(
                  onTap: (){ Get.to(HomeStation());},
                  leading: Icon(Icons.star_outline_sharp),
                  title: Text('Gérer les stations'),
                ),
                ListTile(
                  onTap: (){ Get.to(AddParcours());},
                  leading: Icon(Icons.add),
                  title: Text('Ajouter un parcours'),
                ),
                ListTile(
                  onTap: (){ Get.to(HomeParcours());},
                  leading: Icon(Icons.list),
                  title: Text('Gérer les parcours'),
                ),
                ListTile(
                  onTap: (){ Get.to(LoginPage());},
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Déconnexion'),
                ),
          ],
        ),
      ),
      body:
      WillPopScope(
        child: isLoading== true ? Center(child: CircularProgressIndicator(),) 
        :GridView.builder(
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent:100 ),
          itemBuilder: (context, i) {
            return  
              InkWell(
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
               await FirebaseFirestore.instance.collection("bus").doc(data [i].id).delete();
               Navigator.of(context).pushReplacementNamed("/HomeBus");
               },
               btnOkOnPress: () async {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditBus(
                  docid: data[i].id,
                  oldnombus: data[i]["nombus"],
                  oldstation: data[i]["station"],
                  )));
               }).show();
                },
                child: Card(
                  child: Container(
                    padding:EdgeInsets.all(10),
                    color: Color.fromARGB(255, 236, 236, 236),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Aligner les éléments en haut
                      children: [
                       Image.asset("images/308.png", height: 50,),
                        SizedBox(width: 8), // Espace entre l'image et le texte
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligner les textes à gauche
                         children: [
                        Text("Bus: ${data[i]['nombus']}"),
                         Text("Station: ${data[i]['station']}"),
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