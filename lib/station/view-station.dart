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
import 'package:flutter_app/station/editstation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeStation extends StatefulWidget {
  const HomeStation({super.key});
  State<HomeStation> createState() => _HomeStationState();
}

class _HomeStationState extends State<HomeStation> {
List<QueryDocumentSnapshot> data = [];
bool isLoading= true;
getData() async{
  QuerySnapshot querySnapshot=
  await FirebaseFirestore.instance.collection("station").where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid).get();
  
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
      floatingActionButton: FloatingActionButton(
        backgroundColor:  Color(0xFFFFCA20),
        foregroundColor: Colors.black54,
        onPressed:() {
          Navigator.of(context).pushNamed("/AddStation");
        } ,
        child: Icon(Icons.add),
        ),
      appBar: AppBar(
        title:  const Text('Liste Station', style: TextStyle(color: Colors.white),),
        backgroundColor: Color.fromARGB(255, 50, 112, 173),
        actions: [
          Row(
            children: [
              Text("Déconnexion",  style: TextStyle(color: Colors.white),),
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                      }, icon: Icon(Icons.exit_to_app, color: Colors.white,)),
            ],
          )
        ],
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
            return  Card(
              color: Color.fromARGB(255, 236, 229, 229),
              child: ListTile(
                title: Text("Station: ${data[i]['nomstation']}", style: TextStyle(fontSize: 20),),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Latitude:${data[i]['latitude']}",),
                    Text("Longtude:${data[i]['longtude']}",),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed:(){
                        showDialog(
                          context: context,
                           builder: (context) => EditStation(
                  docid: data[i].id,
                  oldnomstation: data[i]["nomstation"],
                  oldlatitude: data[i]["latitude"],
                  oldlongtude: data[i]["longtude"],
                  ));
                  },
                  child: Icon(Icons.edit, size: 32,color: Colors.green,),
                  ),
                  TextButton(
                  onPressed:(){
                  FirebaseFirestore.instance.collection("station").doc(data [i].id).delete();
               Navigator.of(context).pushReplacementNamed("/HomeStation");
               },
               child: Icon(Icons.delete, size: 32,color: Colors.red,),
                ),
                  ],
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