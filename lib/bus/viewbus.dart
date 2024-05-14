import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/bus/editbus.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbus.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';

class HomeBus extends StatefulWidget {
  const HomeBus({Key? key}) : super(key: key);

  @override
  _HomeBusState createState() => _HomeBusState();
}

class _HomeBusState extends State<HomeBus> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  String? nomBus;
  String selectedBusDocumentId = "";

   
  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("bus").get();

    setState(() {
      data.addAll(querySnapshot.docs);
      isLoading = false;
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
        backgroundColor: Color(0xFFffd400),
        foregroundColor: Color(0xFF25243A),
        onPressed: () {
          Navigator.of(context).pushNamed("/AddBus");
          
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Liste Ligne',
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
    body: WillPopScope(
  child: isLoading
    ? Center(child: CircularProgressIndicator())
    : Consumer<SelectedBusDocumentIdProvider>(
        builder: (context, provider, _) {
          return GridView.builder(
            itemCount: data.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1,
              mainAxisExtent: 100,
            ),
            itemBuilder: (context, i) {
              return InkWell(
                onTap: () {},
                onLongPress: () {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.info,
                    animType: AnimType.rightSlide,
                    title: 'Confirmation',
                    desc: 'Voulez-vous vraiment modifier ou supprimer ce bus?',
                    btnCancelText: "Supprimer",
                    btnOkText: "Modifier",
                    btnCancelOnPress: () async {
                      await FirebaseFirestore.instance.collection("bus").doc(data[i].id).delete();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => DashboardScreen(initialTabIndex: 1,),
                        ),
                      );
                    },
                    btnOkOnPress: () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => EditBus(
                          docid: data[i].id,
                          oldnombus: data[i]["nombus"],
                          oldimmatriculation: data[i]["immat"],
                        ),
                      ));
                    },
                  ).show();
                },
                child: Card(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    color: Color.fromARGB(255, 236, 236, 236),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Image.asset(
                          "images/308.png",
                          height: 50,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Ligne ${i + 1}: ${data[i]['nombus']}"),
                            Text("immat: ${data[i]['immat']}"),
                          ],
                        ),
                        MaterialButton(
                          child: Icon(Icons.directions, color: Colors.black, size: 30),
                          onPressed: () async {
                            provider.selectedBusDocumentId = data[i].id;
                            final selectedStations = await Navigator.of(context).pushNamed("/Attribuer",);

                            if (selectedStations != null && selectedStations is List<String>) {
                              List<String> newStations = List<String>.from(selectedStations);

                              // Mettre à jour la base de données avec les nouvelles stations
                              await FirebaseFirestore.instance.collection("bus").doc(data[i].id).update({
                                'nomstation': FieldValue.arrayUnion(newStations),
                              });

                              // Afficher un message SnackBar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Nomstations added: $newStations'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),


        onWillPop: () {
          Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 0,) // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
          return Future.value(false);
        },
      ),
    );

  }
}



 /*MaterialButton(
  child: Icon(Icons.directions, color: Colors.black, size: 30),
  onPressed: () async {
    final selectedStations = await Navigator.of(context).pushNamed(
      "/Attribuer");
    

    if (selectedStations != null && selectedStations is List<String>) {
      List<String> newStations = List<String>.from(selectedStations);
      await FirebaseFirestore.instance.collection("bus").doc(data[i].id).update({
        'nomstation': FieldValue.arrayUnion(newStations),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nomstations added: ${newStations}'),
          duration: Duration(seconds: 2), 
        ),
      );
    }
  },
),      */