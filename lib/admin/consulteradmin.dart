import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/view-admin.dart';
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

class ConsultAdmin extends StatefulWidget {
  final String adminid;
  const ConsultAdmin({super.key, required this.adminid});
  State<ConsultAdmin> createState() => _ConsultAdminState();
}

class _ConsultAdminState extends State<ConsultAdmin> {
  List<QueryDocumentSnapshot> data = [];
bool isLoading= true;
getData() async{
  QuerySnapshot querySnapshot=
  await FirebaseFirestore.instance.
  collection("admin").doc(widget.adminid).collection("note").get();
  
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFFCA20),
        title:  const Text("Consultation", style: TextStyle(color: Colors.black54,)),
        actions: [
          Row(
            children: [
              Text(""),
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                      }, icon: Icon(Icons.exit_to_app)),
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
                  Text('Nom Admin'),
                  Text('Email Admin', style: TextStyle(fontSize: 14),),
                ],
                ),
                ),
                ListTile(
                  onTap: () {Get.to(HomeAdmin());},
                  leading: Icon(Icons.home, color: Colors.black54,),
                  title: Text('Home Admin', style: TextStyle(color: Colors.black54, fontSize: 24 ),
                  ),
                  tileColor: Colors.black54,
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
    );
  }
}