import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


/*class HomeFavoris extends StatefulWidget {
   
  const HomeFavoris({super.key});
  State<HomeFavoris> createState() => _HomeStationState();
}

class _HomeStationState extends State<HomeFavoris> {
List<QueryDocumentSnapshot> data = [];
bool isLoading= true;
getData() async{
  QuerySnapshot querySnapshot=
  await FirebaseFirestore.instance.collection("favoris").get();
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
          FloatingActionButton(
            backgroundColor:  Color(0xFFffd400),
            foregroundColor: Colors.black54,
            onPressed:() {
             Navigator.of(context).pushNamed("/MapLigne");
            } ,
            child: Icon(Icons.add),
          ),
      
      SizedBox(height: 20,) // Espacement entre les boutons flottants et le bord inférieur de l'écran
    ],
  ),
    appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Mes favoris',
          style: TextStyle(color: Color(0xFFffd400), fontSize: 20,),
          textAlign: TextAlign.center
        ),
      ),
      body:
      WillPopScope(
        child: isLoading== true ? Center(child: CircularProgressIndicator(),) 
        : Consumer<SelectedStationDocumentIdProvider>(
        builder: (context, provider, _) {
        return GridView.builder(
          itemCount: data.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent:130 ),
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
               title: '',
               desc: 'Voulez-vous vraiment supprimer cette favoris ?',
               btnCancelText: "Supprimer" ,
               btnCancelOnPress: ()  async {
               await FirebaseFirestore.instance.collection("favoris").doc(data [i].id).delete();
                Navigator.of(context).pushNamed("/HomeFavoris");
               },
               ).show();
                },
               
child:Card(
   color: Color.fromARGB(255, 255, 255, 255),
  child: Padding(
    padding: const EdgeInsets.all(2.0), // Adding some padding to avoid edge clipping
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start, // Ensure children are aligned properly
      children: [
       // Icon(Icons.star, color: Color(0xFFffd400), size: 50),
        SizedBox(width: 10), // Add space between the icon and the rest of the content
        Expanded( // Ensure the content takes available space
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  "Ligne: ${data[i]['nomLigne']}",
                  style: TextStyle(fontSize: 15),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Départ: ${data[i]['stationSource']}", style: TextStyle(fontSize: 12)),
                    Text("Destination: ${data[i]['stationDestination']}", style: TextStyle(fontSize: 12)),
                    
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        
                      },
                      child: Icon(Icons.star_border, size: 50, color: Color.fromARGB(242, 255, 226, 61)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
)
 );
            
              
          }
        );
             
}
          ), onWillPop: () {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => MyDrawer(),// 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
            return Future.value(false);
          },
      )
       );
  }
}*/

class HomeFavoris extends StatefulWidget {
   
  const HomeFavoris({super.key});
  State<HomeFavoris> createState() => _HomeStationState();
}

class _HomeStationState extends State<HomeFavoris> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  String? defaultFavoriteId;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("favoris").get();
    setState(() {
      data = querySnapshot.docs;
      // Find the default favorite
      for (var doc in data) {
        if (doc['isDefault'] == true) {
          defaultFavoriteId = doc.id;
          break;
        }
      }
      isLoading = false;
    });
  }

  Future<void> deleteFavoris(String docId) async {
    await FirebaseFirestore.instance.collection("favoris").doc(docId).delete();
    setState(() {
      data.removeWhere((doc) => doc.id == docId);
    });
  }

Future<void> setDefaultFavorite(String docId) async {
  // Remove default from all documents
  WriteBatch batch = FirebaseFirestore.instance.batch();
  for (var doc in data) {
    batch.update(doc.reference, {'isDefault': false});
  }
  // Set default for the selected document
  batch.update(FirebaseFirestore.instance.collection("favoris").doc(docId), {'isDefault': true});
  await batch.commit();

  // Update local state directly
  setState(() {
    for (var doc in data) {
      if (doc.id == docId) {
        doc.reference.update({'isDefault': true});
      } else {
        doc.reference.update({'isDefault': false});
      }
    }
    defaultFavoriteId = docId;
  });
}


  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Mes favoris',
          style: TextStyle(
            color: Color(0xFFffd400),
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFffd400),
        foregroundColor: Colors.black54,
        onPressed: () {
          Navigator.of(context).pushNamed("/MapLigne");
        },
        child: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              itemCount: data.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 140,
              ),
              itemBuilder: (context, i) {
                var doc = data[i];
                bool isDefault = defaultFavoriteId == doc.id;
                return InkWell(
                  onTap: () {
                    // Handle tap if needed
                  },
                  onLongPress: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.info,
                      animType: AnimType.rightSlide,
                      title: '',
                      desc: 'Voulez-vous vraiment supprimer cette favoris ?',
                      btnCancelText: "Supprimer",
                      btnCancelOnPress: () => deleteFavoris(doc.id),
                    ).show();
                  },
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(
                                    "Ligne: ${doc['nomLigne']}",
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Départ: ${doc['stationSource']}",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                      Text(
                                        "Destination: ${doc['stationDestination']}",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                       if (isDefault)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            "by default",
                                            style: TextStyle( fontSize: 13,
                                              color: Color.fromARGB(242, 255, 226, 61),
                                            ),
                                          ),
                                        ),
                                      IconButton(
                                        icon: Icon(
                                          isDefault
                                              ? Icons.star
                                              : Icons.star_border,
                                          size: 50,
                                          color: Color.fromARGB(242, 255, 226, 61),
                                        ),
                                        onPressed: () {
                                          setDefaultFavorite(doc.id);
                                        },
                                      ),
                                     
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}