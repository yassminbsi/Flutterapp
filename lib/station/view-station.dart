import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/station/editstation.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

class HomeStation extends StatefulWidget {
   
  const HomeStation({super.key});
  State<HomeStation> createState() => _HomeStationState();
}

class _HomeStationState extends State<HomeStation> {
List<QueryDocumentSnapshot> data = [];
bool isLoading= true;
getData() async{
  QuerySnapshot querySnapshot=
  await FirebaseFirestore.instance.collection("station").get();
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
    floatingActionButton: Column(
    mainAxisAlignment: MainAxisAlignment.end,
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "/AddStation" ,
            backgroundColor:  Color(0xFFffd400),
            foregroundColor: Colors.black54,
            onPressed:() {
              Navigator.of(context).pushNamed("/AddStation");
            } ,
            child: Icon(Icons.add),
          ),
          SizedBox(width: 20,),
          FloatingActionButton(
            heroTag: "/MapAdmin",  
            backgroundColor:  Color(0xFFffd400),
            foregroundColor: Colors.black54,
            onPressed:() {
              Navigator.of(context).pushNamed("/MapAdmin");
            } ,
            child: Icon(Icons.place),
          ),
        ],
      ),
      SizedBox(height: 20,) // Espacement entre les boutons flottants et le bord inférieur de l'écran
    ],
  ),
    appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Liste Station',
          style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/loginbasedrole", (route) => false);
            },
            icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400)),
          ),
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
               await FirebaseFirestore.instance.collection("station").doc(data [i].id).delete();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 3,), // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
               },
               btnOkOnPress: () async {
                Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => EditStation(
                  docid: data[i].id,
                  oldnomstation: data[i]["nomstation"],
                  oldlatitude: data[i]["latitude"],
                  oldlongtude: data[i]["longtude"],
                  )));
               }).show();
                },
            /*    child: Card(
                  child: Container(
                    padding:EdgeInsets.all(10),
                    color: Color.fromARGB(255, 236, 236, 236),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround, // Aligner les éléments en haut
                      children: [
                       Image.asset("images/308.png", height: 50,),
                        SizedBox(width: 8), // Espace entre l'image et le texte
                        Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligner les textes à gauche
                         children: [
                        
                         Text("Station ${i + 1}: ${data[i]['nomstation']}"),
                          Text("Latitude: ${data[i]['latitude']}"),
                          Text("Longtude: ${data[i]['longtude']}"),
                            ],
                         ),
  ],
),
                  ),
                ),*/
  child: Card(
  child: Container(
    padding: EdgeInsets.all(10),
    color: Color.fromARGB(255, 236, 236, 236),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // Image de la station
        Image.asset("images/308.png", height: 50,),
        SizedBox(width: 8), // Espace entre l'image et le texte
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom de la station
            Text("Station ${i + 1}: ${data[i]['nomstation']}"),
            // Latitude
            Text("Latitude: ${data[i]['latitude']}"),
            // Longitude
            Text("Longitude: ${data[i]['longtude']}"),
          ],
        ),
        
        
      ],
    ),
  ),
),
 );
            
              
          },
             
             
          ), onWillPop: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 0,) // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
            return Future.value(false);
          },
      )
       );
  }
}