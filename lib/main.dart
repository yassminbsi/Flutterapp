import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/auth/login.dart';
import 'package:flutter_app/auth/signup.dart';
import 'package:flutter_app/mapwidget/constnats/strings.dart';
import 'package:flutter_app/mapwidget/presentation/screens/map_screen.dart';
import 'package:flutter_app/role/home.dart';
import 'package:flutter_app/route/app_views.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';
import 'package:flutter_app/views/add.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/route/app_page.dart';
import 'package:flutter_app/route/app_route.dart';

import 'package:flutter_app/auth/signup_admin.dart';
import 'package:flutter_app/parcours/addparcours.dart';
import 'package:flutter_app/parcours/view-parcours.dart';
import 'package:flutter_app/station/addstation.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_app/admin/addadmin.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/auth/home_admin.dart';

import 'package:flutter_app/auth/Homepage.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/auth/login_admin.dart';
import 'package:flutter_app/auth/search_bus.dart';
import 'package:flutter_app/auth/signup_admin.dart';
import 'package:get/get.dart';
import 'mapwidget/constnats/strings.dart';
import 'mapwidget/app_router.dart';

String ?initialRoute;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
 await Firebase.initializeApp(
    // Replace with actual values
    options: FirebaseOptions(
      apiKey: "AIzaSyAtrv9RvhCFSzO9QA3VbCsg0SSuN8yy_EM",
      appId: "1:478912769142:android:3b8d047fbbd19072c94357",
      messagingSenderId: "478912769142",
      projectId: "flutterapp-6a28d",
    ),
  );

FirebaseAuth.instance.authStateChanges().listen((user) {
    if (user == null) {
      initialRoute = loginScreen;
    } else {
       FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user != null) {
    var kk = FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        if (documentSnapshot.get('rool') == "Admin") {
           initialRoute = Connecter;
        } else {
         initialRoute= bus;
        }
      } else {
        print('Document does not exist on the database');
      }
    });
}});
    }
  });

 

 
 /*FirebaseAuth.instance.authStateChanges().listen((User? user) {
  if (user != null) {
    FirebaseFirestore.instance.collection('admin').doc(user.uid).get().then((documentSnapshot) {
      if (documentSnapshot.exists) {
        String? role = (documentSnapshot.data() as Map<String, dynamic>?)?['role'];
        if (role == "role") initialRoute = mapScreen;
      }
    }).catchError((error) {
      print("Error getting user data: $error");
    });
  }
});
*/

  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AppRouter appRouter;

  @override
  void initState() {
    super.initState();
    appRouter = AppRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: appRouter.generateRoute,
      initialRoute: initialRoute,
    );
  }
}
