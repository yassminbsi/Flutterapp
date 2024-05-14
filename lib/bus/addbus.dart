import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

/*class AddBus extends StatefulWidget {
  const AddBus({Key? key}) : super(key: key);

  @override
  State<AddBus> createState() => _AddBusState();
}

class _AddBusState extends State<AddBus> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController nombus = TextEditingController();
  TextEditingController immat = TextEditingController();
  CollectionReference bus = FirebaseFirestore.instance.collection('bus');
  bool isLoading = false;
  List<String> stationNames = [];
  String? selectedStation; // Added to store the selected station
AddBus() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    DocumentReference response = await bus.add(
  {
    "nombus": nombus.text,
    "Utilisateur": {
      "id": FirebaseAuth.instance.currentUser!.uid,
    },
    "immat": immat.text,
   "nomstation": selectedStation,
  },
);
    Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => ControlePage(initialTabIndex: 1), // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
    } catch(e) {
      isLoading= false;
      setState(() {
        
      });
      print("Error $e");
    }
  }
}
 @override
  void initState() {
    super.initState();
   fetchStationNames();
  }
  
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nombus.dispose();
  }

 void fetchStationNames() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('station').get();
    setState(() {
      stationNames = snapshot.docs.map((doc) => doc['nomstation'] as String).toList();
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF25243A),
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        title: const Text(
          'Ajouter Bus',
          style: TextStyle(color: Color(0xFFffd400)),
        ),
      ),
      body: Form(
        key: formState,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 65, vertical: 55),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "Informations Générales",
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF25243A),
                              ),
                            ),
                          ),
                          SizedBox(height: 40),
                          TextFormField(
                            controller: nombus,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: ' Nom Bus',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFFCA20)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            validator: (val) {
                              if (val == "") {
                                return "Ne peut pas être vide";
                              }
                            },
                          ),
                          SizedBox(height: 30),
                                     TextFormField(
                            controller: immat,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: ' Immatriculation',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFFCA20)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            validator: (val) {
                              if (val == "") {
                                return "Ne peut pas être vide";
                              }
                            },
                          ),
                          
                         /* DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: ' Nom Station',
                              floatingLabelBehavior: FloatingLabelBehavior.always,
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xFFFFCA20)),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            value: selectedStation, // Use selectedStation here
                            onChanged: (newValue) {
                              setState(() {
                                selectedStation = newValue; // Update selectedStation when value changes
                              });
                            },
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Veuillez sélectionner une station';
                              }
                              return null;
                            },
                            items: stationNames.map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          */
                        ],
                      ),
                    ),
                    MaterialButton(
                      color: Color(0xFFFFCA20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15.0))),
                      elevation: 5.0,
                      minWidth: 200.0,
                      height: 45,
                      child: Text(
                        "Sauvegarder",
                        style: TextStyle(color: Color(0xFF25243A), fontSize: 17.0),
                      ),
                      onPressed: () {
                        if (formState.currentState!.validate()) {
                         AddBus(); // Save logic here
                        }
                      },
                    )
                  ],
                ),
              ),
      ),
    );
  }
}
*/
class AddBus extends StatefulWidget {
  const AddBus({Key? key}) : super(key: key);

  @override
  State<AddBus> createState() => _AddBusState();
}

class _AddBusState extends State<AddBus> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController immatriculation = TextEditingController();
  TextEditingController nomBus = TextEditingController();
  String? selectedStation;
  List<String> stations = [];

  @override
  void initState() {
    super.initState();
    fetchStations();
  }

  Future<void> fetchStations() async {
    try {
      QuerySnapshot stationSnapshot =
          await FirebaseFirestore.instance.collection('station').get();
      List<String> fetchedStations = [];
      stationSnapshot.docs.forEach((doc) {
        fetchedStations.add(doc['nomstation']);
      });
      setState(() {
        stations = fetchedStations;
      });
    } catch (e) {
      print("Error fetching stations: $e");
    }
  }
    CollectionReference bus = FirebaseFirestore.instance.collection('bus');
  bool isLoading = false;
  AddBus() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
   
    DocumentReference response = await bus.add(
  {
    "immat": immatriculation.text,
        "Utilisateur": {"id": FirebaseAuth.instance.currentUser!.uid},
        "nombus": nomBus.text,
        "nomstation": selectedStation,
         
  },
);
    
    Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 1,), // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
    } catch(e) {
      isLoading= false;
      setState(() {
      });
      print("Error $e");
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
          backgroundColor: Color(0xFF25243A),
          title: const Text('Ajout Ligne',style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
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
                      .pushNamedAndRemoveUntil("/loginbasedrole", (route) => false);
                },
                icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400)),
              ),
            ],
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
                        image: DecorationImage(image: AssetImage("images/font.jpg"),
                        fit: BoxFit.cover,)),
        child: Form(
          key: formState,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Container(
                        
                        padding:EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                            CustomLogoAuth(),
                            Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add , color:Color(0xFF6750A4),size: 27,),
                              Text(
                                "Ajouter Ligne",
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6750A4),),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6750A4)),
                              borderRadius: BorderRadius.circular(30)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6750A4)),
                              borderRadius: BorderRadius.circular(30)), 
                            prefixIcon: Icon(Icons.confirmation_number ,color: Color(0xFF6750A4),),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                             label: Text("Immatriculation"),
                             labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                          controller: immatriculation,
                          validator: (val) {
                            if (val == "") {
                              return "Ne peut pas être vide";
                            }
                          },
                        ),
                        SizedBox(height: 9),
                        TextFormField(
                          decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6750A4)),
                              borderRadius: BorderRadius.circular(30)),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF6750A4)),
                              borderRadius: BorderRadius.circular(30)), 
                            prefixIcon: Icon(Icons.directions_bus,color: Color(0xFF6750A4),),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
                             label: Text("nom de bus"),
                             labelStyle: TextStyle(color: Color(0xFF6750A4)),),
                          controller: nomBus,
                          validator: (val) {
                            if (val == "") {
                              return "Ne peut pas être vide";
                            }
                          },
                        ),
                        SizedBox(height: 9),
                  SizedBox(height: 35),
                   Center(
                        child: CustomButtonAuth(
                        title: "Sauvegarder bus",
                         onPressed: () {
                        AddBus();
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                           content: Text('Le bus a été ajouté avec succès', style: TextStyle(color: Colors.black), 
               ),
             backgroundColor: const Color.fromARGB(255, 197, 197, 197),
              duration: Duration(seconds: 2),
             ),
             );
                                                },
              ),
              ),
              SizedBox(height: 10),
                ],
              ),
             )
             ],
            ),
              ),
            ),
        ),
      ),
    );
  }
}

