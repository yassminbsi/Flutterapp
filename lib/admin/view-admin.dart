import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/consulteradmin.dart';
import 'package:flutter_app/admin/editadmin.dart';
import 'package:flutter_app/auth/home_admin.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/parcours/addparcours.dart';
import 'package:flutter_app/parcours/view-parcours.dart';
import 'package:flutter_app/station/addstation.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccueilAdmin extends StatefulWidget {
  const AccueilAdmin({super.key});
  State<AccueilAdmin> createState() => _AccueilAdminState();
}

class _AccueilAdminState extends State<AccueilAdmin> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("admin").get();

    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xFFFFCA20),
          foregroundColor: Colors.black54,
          onPressed: () {
            Navigator.of(context).pushNamed("/AddAdmin");
          },
          child: Icon(Icons.add),
        ),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Color(0xFFffd400)),
          backgroundColor: Color(0xFF25243A),
          title: const Text(
            'Liste Admin',
            style: TextStyle(color: Color(0xFFffd400)),
          ),
          actions: [
            Row(
                /*  children: [
              Text("Déconnexion", style: TextStyle(color: Colors.white),),
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                      }, icon: Icon(Icons.exit_to_app, color: Colors.white,)),
            ],
            */
                )
          ],
        ),
        drawer: Drawer(
          backgroundColor: Color(0xFF25243a),
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('E-Karhabty',
                        style:
                            TextStyle(color: Color(0xFFffd400), fontSize: 28)),
                    Text('Nom Admin'),
                    Text(
                      'Email Admin',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              ListTile(
                onTap: () {
                  Get.to(HomeAdmin());
                },
                leading: Icon(
                  Icons.home,
                  color: Color(0xFFffd400),
                ),
                title: Text(
                  'Menu',
                  style: TextStyle(
                      color: Color.fromARGB(255, 181, 181, 181), fontSize: 24),
                ),
               
              ),
              
ListTile(
                  onTap: () {Get.to(HomeAdmin());},
                  leading: Icon(Icons.home, color: Colors.white,),
                  title: Text('Home Admin', style: TextStyle(color: Colors.white, fontSize: 24 ),
                  ),
                  tileColor: Colors.black87,
                ),
               
                ListTile(
                  onTap: (){ Get.to(HomeBus());},
                  leading: Icon(Icons.list),
                  title: Text('Gérer Bus',
                  ),
                ),
                
               
                
                ListTile(
                  onTap: (){ Get.to(HomeStation());},
                  leading: Icon(Icons.star_outline_sharp),
                  title: Text('Gérer Stations'),
                ),
               
                ListTile(
                  onTap: (){ Get.to(HomeParcours());},
                  leading: Icon(Icons.list),
                  title: Text('Gérer Parcours'),
                ),
              
              ListTile(
                onTap: () {
                  Get.to(LoginPage());
                },
                leading: Icon(
                  Icons.exit_to_app,
                  color: Color.fromARGB(255, 240, 240, 240),
                ),
                title: Text(
                  'Déconnexion',
                  style: TextStyle(
                      color: Color.fromARGB(255, 181, 181, 181), fontSize: 18),
                ),
              ),
            ],
          ),
        ),
        body: WillPopScope(
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.builder(
                  itemCount: data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, mainAxisExtent: 100),
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ConsultAdmin(adminid: data[i].id)));
                      },
                      onLongPress: () {
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: 'Confirmation',
                            desc:
                                'Voulez-vous vraiment modifier ou supprimer cet admin?',
                            btnCancelText: "Supprimer",
                            btnOkText: "Modifier",
                            btnCancelOnPress: () async {
                              await FirebaseFirestore.instance
                                  .collection("admin")
                                  .doc(data[i].id)
                                  .delete();
                              Navigator.of(context)
                                  .pushReplacementNamed("/AccueilAdmin");
                            },
                            btnOkOnPress: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditAdmin(
                                      docid: data[i].id,
                                      oldnom: data[i]["nom"],
                                      oldprenom: data[i]["prenom"],
                                      oldphone: data[i]["phone"],
                                      oldemail: data[i]["email"],
                                      oldpassword: data[i]["password"],
                                      oldconfirmpassword: data[i]["nom"])));
                            }).show();
                      },
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Color.fromARGB(255, 236, 229, 229),
                          child: Container(
                            height: 120,
                            padding: EdgeInsets.all(10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment
                                  .center, // Aligner les éléments en haut
                              children: [
                                Image.asset(
                                  "images/308.png",
                                  width: 50,
                                ),
                                SizedBox(width: 8),
                                // Espace entre l'image et le texte
                                Container(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    // Aligner les textes à gauche
                                    children: [
                                      Text("Nom: ${data[i]['nom']}"),
                                      Text("Prénom: ${data[i]['prenom']}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          onWillPop: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil("/HomeAdmin", (route) => false);
            return Future.value(false);
          },
        ));
  }
}
