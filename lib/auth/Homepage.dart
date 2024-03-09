import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<QueryDocumentSnapshot> data = [];

  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('bus').get();
    data.addAll(querySnapshot.docs);
    setState(() {
      
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black87,
        onPressed: () {
          Navigator.of(context).pushNamed("Addviews");
        },
        child: Icon(
          Icons.add,
          color: Color(0xFFFFCA20),
        ),
      ),
      appBar: AppBar(
        title: const Text('E-Karhabty'),
        actions: [
          IconButton(
              onPressed: () async {
                GoogleSignIn googleSignIn = GoogleSignIn();
                googleSignIn..disconnect();
                await FirebaseAuth.instance.signOut();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("login", (route) => false);
              },
              icon: Icon(Icons.exit_to_app))
        ],
      ),
      body: GridView.builder(
        itemCount: data.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1, mainAxisExtent: 160),
        itemBuilder: (context, i) {
           return Card(
              color: Color.fromARGB(255, 236, 229, 229),
              child: Container(
                  height: 120,
                  padding: EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/308.png",
                        width: 50,
                      ),
                      Text("Ligne 3"),
                      Container(width: 80),
                      Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          children: [Text(
                            '${data [i]['bus_id']}',
                            
                        
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${data[i]['mat_b']}',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                            ),
                          ),
                          ]
                        ),
                      
                       
                        
                        
                        width: 100,
                        height: 65,
                        color: Color(0xFFFFCA20),
                      ),
                    ],
                  )));
        },
      ),
    );
  }
}
