import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/parcours/addparcours.dart';
import 'package:flutter_app/parcours/view-parcours.dart';
import 'package:flutter_app/station/addstation.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:get/get.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 50, 112, 173),
        title:  Text("Accueil", style: TextStyle(color: Colors.white),), 
        actions: [
          Row(
            children: [
              Text("Déconnexion", style: TextStyle(color: Colors.white),),
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/loginAdmin", (route) => false);
                      }, 
                      
                      icon: Icon(Icons.exit_to_app, color: Colors.white,)),
            ],
          ),
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
      backgroundColor: Colors.white,
      body: Container(
        
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Container(
               alignment: Alignment.topCenter,
               width: 3320,
               height: 120,
               padding: EdgeInsets.all(10),
               decoration:  BoxDecoration(
                 color: const Color.fromARGB(255, 255, 255, 255),
                 borderRadius: BorderRadius.circular(70)
                ),
               child: Image.asset("images/icon_admiiin.jpg",
               height: 1000,),

          ),
        
          
            Container(
             alignment: Alignment.topCenter,
             child: Text("Page Admin",
             style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
            ),
            Container(height: 20,),
            Center(
              child: MaterialButton(child: Text ("Gérer les lignes de bus"),
               onPressed: () async {
                  Get.to(HomeBus());
                },
               ),
            ),
            SizedBox(height: 20),
            Center(
              child: 
              MaterialButton(child: Text( "Gérer les comptes"),
                onPressed: (){
                  Get.to(AccueilAdmin());
                },
             ),
            ),
            SizedBox(height: 20),
            Center(
              child:  MaterialButton (child: Text("Gérer les stations"),
                onPressed: (){
                  Get.to(HomeStation());
                },
               ),
            ),
            SizedBox(height: 20),
            Center(
              child: MaterialButton(child:Text("Gérer les parcours"),
                onPressed: (){
                  Get.to(HomeParcours());
                },
               ),
            ),
          ],),
      ),
    );
  }
}