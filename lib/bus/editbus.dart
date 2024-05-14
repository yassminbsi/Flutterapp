import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

/*class EditBus extends StatefulWidget {
  final String docid;
  final String oldnombus;
  final String oldimmat;
  const EditBus({super.key, required this.docid, required this.oldnombus, required this.oldimmat, });

  @override
  State<EditBus> createState() => _EditBusState();
}

class _EditBusState extends State<EditBus> {
  
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nombus= TextEditingController();
 TextEditingController immat= TextEditingController();
 CollectionReference bus = FirebaseFirestore.instance.collection('bus');
bool isLoading= false;
EditBus() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    await bus.doc(widget.docid).update({
      "nombus": nombus.text,
      "immat":immat.text,

    });
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    nombus.dispose();
    immat.dispose();
  }
@override
  void initState() {
    super.initState();
    nombus.text= widget.oldnombus;
    immat.text= widget.oldimmat;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("", style: TextStyle(color: Colors.white),),
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
      body: Form(
        key: formState,
        child: isLoading ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
           children: [
           CustomLogoAuth(),
           Center(
          child: Text("Modifier ce bus",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 25, 96, 167))),
                ),
           Container(height: 20,), 
           Text("Nom de bus", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
              ),
           SizedBox(height: 10),      
           CustomTextForm(
          hinttext: "Entrer le nom de bus",
          mycontroller: nombus,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
                SizedBox(height: 10), // Ajout d'un espace vertical entre les champs de texte
                Text("Station", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
              ),
                CustomTextForm(
          hinttext: "choisir station",
          mycontroller: immat,
          validator: (val) {
            if (val == "") {
              return "Ne peut pas être vide";
            }
          },
                ),
              ],
            ),
            ),
            MaterialButton(
              color: Color(0xFFFFCA20),
                      child: Text("Sauvegarder",  style: TextStyle(color : Color(0xFF25243A),)),
              onPressed: (){
                EditBus();
              },)
          
          ],),
        ),
      ),

    );
  }
}
*/
class EditBus extends StatefulWidget {
  final String docid;
  final String oldimmatriculation;
  final String oldnombus;
  //final String oldstation;
  const EditBus(
      {Key? key,
      required this.docid,
       required this.oldimmatriculation, required this.oldnombus})
      : super(key: key);

  @override
  State<EditBus> createState() => _EditBusState();
}

class _EditBusState extends State<EditBus> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController immatriculation = TextEditingController();
  TextEditingController nomBus = TextEditingController();
  String? selectedStation;
  // Liste des options de stations
  List<String> stations = [];
  

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
  @override
  void initState() {
    super.initState();
    immatriculation.text = widget.oldimmatriculation;
    nomBus.text = widget.oldnombus;
    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
          backgroundColor: Color(0xFF25243A),
          title: const Text('Modifier Ligne',style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
          ),
        actions:[
          Row(
            children:[
              Text(
                "",
                style: TextStyle(color: Color(0xFFffd400),),
              ),
              IconButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil("/loginbasedrole", (route) => false);
                },
                icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400),),
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
                    decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage("images/font.jpg"),
                    fit: BoxFit.cover,)),
                      padding:EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        
                        children: [
                          CustomLogoAuth(),
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_note , color:Color(0xFF6750A4),size: 33,),
                                Text(
                                  "Modifier Ligne",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6750A4),),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            height: 30,
                          ),
                          TextFormField(
                        decoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6750A4)),
                            borderRadius: BorderRadius.circular(30)),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF6750A4)),
                            borderRadius: BorderRadius.circular(30)), 
                          prefixIcon: Icon(Icons.confirmation_number,color: Color(0xFF6750A4),),
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
                      SizedBox(height: 8),
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
                    SizedBox(height: 30),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomButtonAuth(
                          title: "Sauvegarder la modification",
                          onPressed: () {
                           EditBus();
                           ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                           content: Text("Le bus a été modifié avec succès", style: TextStyle(color: Colors.black), 
                           ),
                           backgroundColor: const Color.fromARGB(255, 197, 197, 197),
                           duration: Duration(seconds: 2),
                ),
              );
              },
              ),
              SizedBox(
                height: 20,
                width: 20,
                ),
                        CustomButtonAuth(
                          title: "    Annuler la modification    ",
                          onPressed: () {
                           // Navigator.of(context).pushReplacementNamed("/ControlePage");
                           Navigator.of(context).pushReplacement(
                           MaterialPageRoute(
                           builder: (context) => DashboardScreen(initialTabIndex: 2,), // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ],
                    ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void EditBus() async {
    if (formState.currentState!.validate()) {
      try {
        isLoading = true;
        setState(() {
        });

        await bus.doc(widget.docid).update({
          "nombus": nomBus.text,
          "immatriculation": immatriculation.text,
          "station": selectedStation,
        });
        //Navigator.of(context).pushNamedAndRemoveUntil("/ControlePage", (route) => false);
        Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 2,), // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
      } catch (e) {
        isLoading = false;
        setState(() {});
        print("Error $e");
      }
    };
    
  }

  @override
  void dispose() {
    super.dispose();
    immatriculation.dispose();
  }
}
