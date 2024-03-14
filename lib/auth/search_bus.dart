import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SearchBus extends StatefulWidget {
  const SearchBus({super.key});

  @override
  State<SearchBus> createState() => _SearchBusState();
}

class _SearchBusState extends State<SearchBus> {
  String nombus="";
  List<Map<String, dynamic>> data = [];
bool isLoading= true;
AddData() async{
  for (var element in data) {
 FirebaseFirestore.instance.collection('bus').add(element);
  }
  print('all data added');
  isLoading= false;
  setState(() {
  });
}
@override
  void initState() {
    AddData();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        actions: [
          Row(
            children: [
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
                      }, icon: Icon(Icons.exit_to_app)),
            ],
          )
        ],
        title:  Container(
          child: Card(
            color: Color.fromARGB(255, 236, 229, 229),
            child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search), hintText: 'Recherche...',),
            onChanged: (val){
              setState(() {
                nombus= val;
              });
            },
          ),
                 
                ),
        ),
      ),
body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance.collection('bus').snapshots(),
  builder: (context, snapshots){
    return (snapshots.connectionState == ConnectionState.waiting)
    ? Center(child: CircularProgressIndicator())
    : ListView.builder(
       
      itemCount: snapshots.data!.docs.length,
      itemBuilder: (context, Index){
      var data= snapshots.data!.docs[Index].data()
      as Map<String, dynamic>;
      if(nombus.isEmpty){
        return ListTile(
          title: Text(
            data['nombus'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black54,
              fontSize:16,
              fontWeight: FontWeight.bold
            ),
          ),
          subtitle:Text(
            data['station'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black54,
              fontSize:16,
              fontWeight: FontWeight.bold
            ),
          ),
        //  leading: CircleAvatar(
        //    backgroundImage:  NetworkImage(data['image']),
          //  ),
        );
      }
      if (data['nombus'].toString().startsWith(nombus.toLowerCase())){ 
        return ListTile(
          title: Text(
            data['nombus'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black54,
              fontSize:16,
              fontWeight: FontWeight.bold
            ),
          ),
          subtitle:Text(
            data['station'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.black54,
              fontSize:16,
              fontWeight: FontWeight.bold
            ),
          ),
         // leading: CircleAvatar(
          //  backgroundImage:  NetworkImage(data['image']),
            
          // ),
        );
      }
      return Container();
      });
  }
  ),
    );
  }
}