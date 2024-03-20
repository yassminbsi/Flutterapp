import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/auth/home_admin.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/parcours/addparcours.dart';
import 'package:flutter_app/station/addstation.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeParcours extends StatefulWidget {
  const HomeParcours({super.key});

  @override
  State<HomeParcours> createState() => _HomeParcoursState();
}

class _HomeParcoursState extends State<HomeParcours> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste de parcours", style: TextStyle(color: Colors.white),),
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
                  Text('Yassmin Bsissa'),
                  Text('yassminbsissa74@gmail.com', style: TextStyle(fontSize: 14),),
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
    );
  }
}