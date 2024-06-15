import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedbus.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

//const googleAPIKey =  'AIzaSyC7ckSip1a_oVGM1y7nPSWGUdTEPbkANIA';

class Attribuer extends StatefulWidget {
  const Attribuer({Key? key}) : super(key: key);

  @override
  State<Attribuer> createState() => _AttribuerState();
}

class _AttribuerState extends State<Attribuer> {
  final GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading = false;
  List<String> stationNames = [];
  List<String> selectedStations = ['', '', ''];
  List<TextEditingController> arrivalTimeControllers = [];

  @override
  void initState() {
    super.initState();
    fetchStationNames();
    fetchOldStations();
    fetchRouteDetails;
  }

  Future<void> fetchStationNames() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('station').get();
      setState(() {
        stationNames = snapshot.docs.map((doc) => "${doc['nomstation']} (ID: ${doc.id})").toList();
      });
    } catch (e) {
      print("Error fetching stations: $e");
    }
  }

  Future<void> fetchOldStations() async {
    final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context, listen: false);
    String selectedBusDocumentId = selectedBusProvider.selectedBusDocumentId;

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('bus').doc(selectedBusDocumentId).get();

      if (snapshot.exists) {
        List<dynamic> nomStations = snapshot['nomstation'];
         // Fetch the old list of arrival times
        setState(() {
          selectedStations = nomStations.cast<String>();
          // Set the existing arrival times to the corresponding controllers
        });
      }

      // Add an additional empty line for new station selection
      addStationSelectionLine();
    } catch (e) {
      print("Error fetching old stations: $e");
    }
  }

  void addStationSelectionLine() {
    setState(() {
      selectedStations.add(""); // Add an empty string initially
    });
  }

  Future<void> removeStationSelectionLine(int index) async {
    final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context, listen: false);
    String selectedBusDocumentId = selectedBusProvider.selectedBusDocumentId;

    String stationToRemove = selectedStations[index];

    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('bus').doc(selectedBusDocumentId).get();

      if (snapshot.exists) {
        List<dynamic> nomStations = snapshot['nomstation'];
        nomStations.remove(stationToRemove);

        // Recalculate route details after removing the station
        List<String> updatedStations = nomStations.cast<String>();
        Map<String, dynamic> routeDetails = await fetchRouteDetails(updatedStations);

        await FirebaseFirestore.instance.collection('bus').doc(selectedBusDocumentId).update({
          'nomstation': updatedStations,
          'route_details': routeDetails,
        });

        setState(() {
          selectedStations.removeAt(index);
        });
      }
    } catch (e) {
      print("Error removing station: $e");
    }
  }

 /* Future<void> updateArrivalTime(String busId, List<String> arrivalTimes) async {
    try {
      await FirebaseFirestore.instance.collection('bus').doc(busId).update({
        'arrival_times': FieldValue.arrayUnion(arrivalTimes),
      });
    } catch (e) {
      print("Error updating arrival time: $e");
    }
  }*/

/*Future<Map<String, dynamic>> fetchRouteDetails(List<String> stations) async {
  List<Map<String, dynamic>> stationsDetails = [];
  double totalDistance = 0;
  double totalDuration = 0;

  for (int i = 0; i < stations.length - 1; i++) {
    String currentStationId = stations[i].split('ID: ')[1].replaceAll(')', '');
    String nextStationId = stations[i + 1].split('ID: ')[1].replaceAll(')', '');

    DocumentSnapshot currentStationSnapshot = await FirebaseFirestore.instance.collection('station').doc(currentStationId).get();
    DocumentSnapshot nextStationSnapshot = await FirebaseFirestore.instance.collection('station').doc(nextStationId).get();

    if (currentStationSnapshot.exists && nextStationSnapshot.exists) {
      double currentLat = double.parse(currentStationSnapshot['latitude']);
      double currentLng = double.parse(currentStationSnapshot['longtude']);
      double nextLat = double.parse(nextStationSnapshot['latitude']);
      double nextLng = double.parse(nextStationSnapshot['longtude']);

      var response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$currentLat,$currentLng&destinations=$nextLat,$nextLng&key=AIzaSyCFynJpxjv1XdWMhYPooJETpkrcofGQ7TM'),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print("API response: $data");

        if (data['rows'] != null && data['rows'].isNotEmpty && data['rows'][0]['elements'] != null && data['rows'][0]['elements'].isNotEmpty) {
          var element = data['rows'][0]['elements'][0];

          if (element['status'] == 'OK') {
            var distance = element['distance']['value'];
            var duration = element['duration']['value'];

            totalDistance += distance / 1000;
            totalDuration += duration / 60;

            stationsDetails.add({
              'name': stations[i].split(' (')[0],
              'id': currentStationId,
              'distance_to_next': "${(distance / 1000).toStringAsFixed(2)} km",
              'duration_to_next': "${(duration / 60).toStringAsFixed(2)} min"
            });
          } else {
            print("Error: No route found for stations $currentStationId to $nextStationId.");
          }
        } else {
          print("Error: No distance data found for stations $currentStationId to $nextStationId.");
        }
      } else {
        print("Error: API request failed with status code ${response.statusCode}");
      }
    } else {
      print("Error: One of the stations does not exist in Firestore.");
    }
  }

  // Add the last station with no distance and duration to next
  if (stations.isNotEmpty) {
    stationsDetails.add({
      'name': stations.last.split(' (')[0],
      'id': stations.last.split('ID: ')[1].replaceAll(')', ''),
      'distance_to_next': null,
      'duration_to_next': null,
    });
  }

  return {
    'total_distance': "${totalDistance.toStringAsFixed(2)} km",
    'total_duration': "${totalDuration.toStringAsFixed(2)} min",
    'stations': stationsDetails
  };
}
*/
Future<Map<String, dynamic>> fetchRouteDetails(List<String> stations) async {
  List<Map<String, dynamic>> stationsDetails = [];
  double totalDistance = 0;
  double totalDuration = 0;

  for (int i = 0; i < stations.length; i++) {
    String currentStationId = stations[i].split('ID: ')[1].replaceAll(')', '');

    if (i < stations.length - 1) {
      String nextStationId = stations[i + 1].split('ID: ')[1].replaceAll(')', '');

      DocumentSnapshot currentStationSnapshot = await FirebaseFirestore.instance.collection('station').doc(currentStationId).get();
      DocumentSnapshot nextStationSnapshot = await FirebaseFirestore.instance.collection('station').doc(nextStationId).get();

      if (currentStationSnapshot.exists && nextStationSnapshot.exists) {
        double currentLat = double.parse(currentStationSnapshot['latitude']);
        double currentLng = double.parse(currentStationSnapshot['longtude']);
        double nextLat = double.parse(nextStationSnapshot['latitude']);
        double nextLng = double.parse(nextStationSnapshot['longtude']);

        var response = await http.get(
          Uri.parse('https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$currentLat,$currentLng&destinations=$nextLat,$nextLng&key=AIzaSyBq0BhOTqB2jW6wW2ZHNxQRYFzDaEZRL7o'),
        );

        if (response.statusCode == 200) {
          var data = json.decode(response.body);

          if (data['rows'] != null && data['rows'].isNotEmpty && data['rows'][0]['elements'] != null && data['rows'][0]['elements'].isNotEmpty) {
            var element = data['rows'][0]['elements'][0];

            if (element['status'] == 'OK') {
              var distance = element['distance']['value'];
              var duration = element['duration']['value'];

              totalDistance += distance / 1000;
              totalDuration += duration / 60;

              stationsDetails.add({
                'name': stations[i].split(' (')[0],
                'id': currentStationId,
                'distance_to_next': "${(distance / 1000).toStringAsFixed(2)} km",
                'duration_to_next': "${(duration / 60).toStringAsFixed(2)} min"
              });
            } else {
              print("Error: No route found for stations $currentStationId to $nextStationId.");
            }
          } else {
            print("Error: No distance data found for stations $currentStationId to $nextStationId.");
          }
        } else {
          print("Error: API request failed with status code ${response.statusCode}");
        }
      } else {
        print("Error: One of the stations does not exist in Firestore.");
      }
    } else {
      // For the last station, use the details of the previous station for duration_to_next and distance_to_next
      if (stationsDetails.isNotEmpty) {
        var lastStationDetails = stationsDetails[stationsDetails.length - 1];
        stationsDetails.add({
          'name': stations[i].split(' (')[0],
          'id': currentStationId,
          'distance_to_next': lastStationDetails['distance_to_next'],
          'duration_to_next': lastStationDetails['duration_to_next'],
        });
      } else {
        // Handle the edge case where there is only one station
        stationsDetails.add({
          'name': stations[i].split(' (')[0],
          'id': currentStationId,
          'distance_to_next': "0 km",
          'duration_to_next': "0 min",
        });
      }
    }
  }

  return {
    'total_distance': "${totalDistance.toStringAsFixed(2)} km",
    'total_duration': "${totalDuration.toStringAsFixed(2)} min",
    'stations': stationsDetails
  };
}




  Widget buildStationSelectionLine(int index) {
    final selectedBusProvider = Provider.of<SelectedBusDocumentIdProvider>(context);
    if (index >= arrivalTimeControllers.length) {
      arrivalTimeControllers.add(TextEditingController());
    }
    bool isStationSelected = selectedStations[index].isNotEmpty;
    return Column(
      children: [
        Row(
          children: [
            Text(
                  'Station ${index + 1}:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6750A4),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "  Choisir une station",
                      hintStyle: TextStyle(fontSize: 9),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelStyle: TextStyle(
                        color: Color(0xFF6750A4),
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6750A4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF6750A4)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    value: selectedStations[index].isEmpty ? null : selectedStations[index],
                    onChanged: (newValue) async {
                      setState(() {
                        selectedStations[index] = newValue!;
                      });
                      // Calculate route details when a station is selected
                      Map<String, dynamic> routeDetails = await fetchRouteDetails(selectedStations);
                      print(routeDetails); // Use routeDetails as needed, e.g., update UI
                    },
                    items: stationNames.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value.split('(ID:')[0].trim(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.normal),
                        ), // Show only the station name
                      );
                    }).toList(),
                    isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down),
                    iconSize: 24,
                    elevation: 16,
                    dropdownColor: Colors.white,
                  ),
                ),
            SizedBox(width: 10), // Add space between the Dropdown and TextField
           /* Expanded(
              child: Container(
                height: 50, // Specify the desired height
                width: 1,
                 // Specify the desired width
                child: TextField(
                  controller: arrivalTimeControllers[index],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6750A4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF6750A4)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    label: Text("Heure d'arrivée (min)"),
                    labelStyle: TextStyle(color: Color(0xFF6750A4), fontSize: 7),
                    hintText: '',
                    
                  ),
                  enabled: isStationSelected, // Disable the text field if no station is selected
                ),
              ),
            ),*/
            SizedBox(width: 5),
            if (index == selectedStations.length - 1)
              MaterialButton(
                onPressed: addStationSelectionLine,
                height: 50,
                minWidth: 20,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                color: Color(0xFF6750A4),
                elevation: 3.0,
                child: Text(
                  "+",
                  style: TextStyle(color: Color(0xFFffd400), fontSize: 17.0),
                ),
              ),
            if (selectedStations.length > 1)
              IconButton(
                icon: Stack(
                  children: [
                    Icon(Icons.delete, color: Color(0xFF6750A4)), // Background icon
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.center,
                        child:  Icon(Icons.delete, color: Color(0xFFffd400)), // White slash icon
                        
                      ),
                    ),
                  ],
                ),
                onPressed: () => removeStationSelectionLine(index),
              ),
          ],
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Future<void> addBus(List<String> selectedStations, List<String> arrivalTimes) async {
    try {
      // Generate station names dynamically
      List<String> stationNames = List.generate(selectedStations.length, (index) => "station${index + 1}");

      // Add the bus to Firestore with generated station names and arrival times
      DocumentReference busRef = await FirebaseFirestore.instance.collection('bus').add({
        'nomstation': stationNames,
       
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
            "Parcours de Ligne : ${nombus ?? ''}",
            style: TextStyle(
              fontSize: 16,
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
          style: TextStyle(color: Color(0xFFffd400), fontSize: 17),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            },
            icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400)),
          ),
        ],
      ),
      body: Form(
        key: formState,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      Center(child: MyBus(selectedBusProvider.selectedBusDocumentId)),
                      SizedBox(height: 30),
                      Column(
                        children: List.generate(selectedStations.length, (index) => buildStationSelectionLine(index)),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: MaterialButton(
  height: 50,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  color: Color(0xFF6750A4),
  elevation: 5.0,
  child: isLoading
      ? CircularProgressIndicator(color: Color(0xFFffd400))
      : Text(
          "Sauvegarder",
          style: TextStyle(color: Color(0xFFffd400), fontSize: 17.0),
        ),
  onPressed: () async {
    if (formState.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      List<String> nonEmptyStations = selectedStations
          .where((station) => station.isNotEmpty)
          .toList();

      List<String> arrivalTimes = [];
      for (int i = 0; i < nonEmptyStations.length; i++) {
        String arrivalTimeString = arrivalTimeControllers[i].text;
        if (arrivalTimeString.isNotEmpty) {
          arrivalTimes.add(arrivalTimeString);
        }
      }
      try {
        Map<String, dynamic> routeDetails = await fetchRouteDetails(nonEmptyStations);

        await FirebaseFirestore.instance.collection('bus').doc(selectedBusProvider.selectedBusDocumentId).update({
          'nomstation': nonEmptyStations,
          'route_details': routeDetails,
        });

        setState(() {
          isLoading = false;
        });

        Navigator.of(context).pop(nonEmptyStations);
      } catch (e) {
        print("Error fetching route details: $e");
        setState(() {
          isLoading = false;
        });
      }
    }
  },
),

                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
