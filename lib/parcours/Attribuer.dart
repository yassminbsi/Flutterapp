import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbus.dart';
import 'package:provider/provider.dart';

class Attribuer extends StatefulWidget {


  const Attribuer({Key? key}) : super(key: key);

  @override
  State<Attribuer> createState() => _AttribuerState();
}

class _AttribuerState extends State<Attribuer> {
  List<QueryDocumentSnapshot> data = [];
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading = false;
  List<String> stationNames = [];
  List<String> selectedStations = [];
  List<String> stationIds = [];
  
  @override
  void initState() {
    super.initState();
    fetchStationNames();
 
  }
  

 /* void fetchBusNames() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('bus').get();
    setState(() {
      stationNames = snapshot.docs.map((doc) => "${doc['nombus']} ").toList();
    });
  }*/

  void fetchStationNames() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('station').get();
    setState(() {
      stationNames = snapshot.docs
          .map((doc) => "${doc['nomstation']} (ID: ${doc.id})")
          .toList();
    });
  }

  void addBus(List<String> selectedStations) async {
    try {
      await FirebaseFirestore.instance.collection('bus').add({
        'nomstations': selectedStations,
        'immat': 'Your Bus Immatriculation',
      });
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushNamedAndRemoveUntil("/HomeBus", (route) => false);
    } catch (e) {
      print("Error $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  Widget MyBus(String selectedBusDocumentId) {
  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance.collection('bus').doc(selectedBusDocumentId).get(),
    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || !snapshot.data!.exists) {
        return Text('Document does not exist');
      } else {
        String? nombus = snapshot.data!.get('nombus');
        return Text(
               "Ajouter parcours au bus : ${nombus ?? ''}",
                style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
                ),
              );
      }
    },
  );
}

  @override
  Widget build(BuildContext context) {
     final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context);
    return Scaffold(
       appBar: AppBar(
      iconTheme: IconThemeData(color: Color(0xFFffd400)),
      backgroundColor: Color(0xFF25243A),
      title: Text(
       "Ajouter Parcours",
        style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
      ),
      
        actions: [
          Row(
            children: [
              Text(
                "",
                style: TextStyle(color: Color(0xFFffd400)),
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/login", (route) => false);
                },
                icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400)),
              ),
            ],
          )
        ],
      ),
      body: Form(
        key: formState,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 65, vertical: 55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         Center(
  child: MyBus( selectedBusProvider.selectedBusDocumentId)
),

                          SizedBox(height: 40),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Nom Stations',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: Color(0xFF6750A4),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFF6750A4),),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF6750A4),),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            value: null,
                            onChanged: (newValue) {
                              setState(() {
                                selectedStations.add(newValue!);
                              });
                            },
                            items: stationNames
                                .toSet()
                                .map<DropdownMenuItem<String>>((String value) {
                              // Split the value to get only the station name
                              String stationName =
                                  value.split('(ID:')[0].trim();
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(stationName),
                              );
                            }).toList(),
                            isExpanded: true,
                            // Allow multiple selection
                            icon: Icon(Icons.arrow_drop_down),
                            iconSize: 24,
                            elevation: 16,
                            dropdownColor: Colors.white,
                            onSaved: (value) {
                              selectedStations.add(value!);
                            },
                          ),
                          SizedBox(height: 20),
                          // Display selected stations
                          Wrap(
                            spacing: 8.0,
                            runSpacing: 4.0,
                            children: selectedStations
                                .map((station) => Chip(
                                      label: Text(station
                                          .split('(ID:')[0]
                                          .trim()), // Display only the station name
                                      onDeleted: () {
                                        setState(() {
                                          selectedStations.remove(station);
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    MaterialButton(
                      height: 50,
                      shape: 
                     RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                     color: Color(0xFF6750A4),
                      elevation: 5.0,
                      child: Text(
                        "Sauvegarder",
                        style:
                            TextStyle(color: Color(0xFFffd400), fontSize: 17.0),
                      ),
                      onPressed: () {
                        if (formState.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          Navigator.of(context).pop(selectedStations);
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
