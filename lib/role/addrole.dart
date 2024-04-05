



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customlogoauth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';



void createUserCollection() async { 
  
 
  CollectionReference admin = FirebaseFirestore.instance.collection('admin');
 
  AddAdmin() async {
    
    
      
        DocumentReference response = await admin.add(
          {
      'email': 'example@example.com', // Example email
      'role': 'user', // Example role
            // "role": "admin"
            // Ajoutez d'autres champs du bus au besoin
          },
        );
        
    
    }
  }

 

