import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddParcours extends StatefulWidget {
  const AddParcours({super.key});

  @override
  State<AddParcours> createState() => _AddParcoursState();
}

class _AddParcoursState extends State<AddParcours> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Ajouter parcours", style: TextStyle(color: Colors.white),),
      
      actions: [
        Row(
          children: [
            Text("Déconnexion", style: TextStyle(color: Colors.black54),),
            IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/login", (route) => false);
            }, icon: Icon(Icons.exit_to_app, color: Colors.black54,)),
          ],
        )
        ],
        ),
    );
  }
}