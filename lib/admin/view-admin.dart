import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/admin/editadmin.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

class AccueilAdmin extends StatefulWidget {
  const AccueilAdmin({super.key});
  State<AccueilAdmin> createState() => _AccueilAdminState();
}
class _AccueilAdminState extends State<AccueilAdmin> {
  List<QueryDocumentSnapshot> data = [];
  bool isLoading = true;
  getData() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("admin").get();

    data.addAll(querySnapshot.docs);
    isLoading = false;
    setState(() {});
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
          foregroundColor: Colors.black54,
          onPressed: () {
            Navigator.of(context).pushNamed("/AddAdmin");
          },
          child: Icon(Icons.add),
        ),
      appBar: AppBar(
        
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Liste Admins',
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
          child: isLoading == true
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : GridView.builder(
                  itemCount: data.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, mainAxisExtent: 100),
                  itemBuilder: (context, i) {
                    return InkWell(
                      onTap: () {
                       
                      },
                      onLongPress: () {
                        AwesomeDialog(
                            context: context,
                            dialogType: DialogType.info,
                            animType: AnimType.rightSlide,
                            title: '',
                            desc: 'Voulez-vous vraiment modifier ou supprimer cet admin?',
                            btnCancelText: "Supprimer",
                            btnOkText: "Modifier",
                            btnCancelOnPress: () async {
                              await FirebaseFirestore.instance.collection("admin").doc(data[i].id).delete();
                              Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                              builder: (context) => DashboardScreen(initialTabIndex: 1,)// 1 est l'index de l'onglet "AccueilAdmin"
                              ),
                             );
                            },
                            btnOkOnPress: () async {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditAdmin(
                                      docid: data[i].id,
                                      oldnom: data[i]["nom"],
                                      oldprenom: data[i]["prenom"],
                                      oldphone: data[i]["phone"],
                                      oldemail: data[i]["email"],
                                      oldpassword: data[i]["password"],
                                      oldconfirmpassword: data[i]["nom"])));
                            }).show();
                      },
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          color: Color.fromARGB(255, 236, 236, 236),
                          child: Container(
                            height: 120,
                            
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center, // Aligner les éléments en haut
                              children: [
                                Image.asset(
                                  "images/308.png",
                                  width: 50,
                                ),
                                SizedBox(width: 30),
                                
                                Container(
        
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Nom: ${data[i]['nom']}"),
                                      Text("Prénom: ${data[i]['prenom']}"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
        ));
  }
}