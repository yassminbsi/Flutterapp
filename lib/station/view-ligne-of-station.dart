import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/mapwidget/presentation/screens/selectedstation.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';

class ViewLigneOfStation extends StatefulWidget {
  const ViewLigneOfStation({super.key});

  @override
  State<ViewLigneOfStation> createState() => _ViewLigneOfStationState();
}

class _ViewLigneOfStationState extends State<ViewLigneOfStation> {
  List<String> busNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBusDocuments();
  }

  Future<void> fetchBusDocuments() async {
    try {
      final provider = Provider.of<SelectedStationDocumentIdProvider>(context, listen: false);
      String selectedStationDocumentId = provider.selectedStationDocumentId!;
      
      QuerySnapshot busSnapshot = await FirebaseFirestore.instance.collection('bus').get();
      List<String> fetchedBusNames = [];
      
      for (var doc in busSnapshot.docs) {
        List<dynamic> stations = doc['nomstation'];
        bool stationExists = stations.any((station) => station.contains("ID: $selectedStationDocumentId"));
        
        if (stationExists) {
          fetchedBusNames.add(doc['nombus']);
        }
      }

      setState(() {
        busNames = fetchedBusNames;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching bus documents: $e');
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('An error occurred. Please try again.'),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Liste Ligne',
          style: TextStyle(color: Color(0xFFffd400), fontSize: 17),
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
        onWillPop: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => DashboardScreen(initialTabIndex: 0),
            ),
          );
          return Future.value(false);
        },
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: busNames.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text( busNames[index],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
