import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/auth/login.dart';
import 'package:flutter_app/auth/signup.dart';
import 'package:flutter_app/route/app_views.dart';
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





late String initialRoute;

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
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('=============User is currently signed out!');
      } else {
        print('=============User is signed in!');
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Fixed the case of 'build'
    return GetMaterialApp(
      getPages: AppPageList.MyList,
      initialRoute: AppRoute.dashboard,
      debugShowCheckedModeBanner: false,
      
      themeMode: ThemeMode.light,
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              backgroundColor:  Color(0xFF25243A),
              titleTextStyle: TextStyle(
                 
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              iconTheme: IconThemeData(color: Colors.black87, size: 28))),
     /* getPages: [
        GetPage(name: "/login", page: () => LoginPage()),
        GetPage(name: "/home", page: () => Homepage()),
        GetPage(name: "/signupAdmin", page: () => signupAdmin()),
        GetPage(name: "/loginAdmin", page: () => LoginAdmin()),
        GetPage(name: "/HomeAdmin", page: () => HomeAdmin()),
        GetPage(name: "/HomeBus", page: () => HomeBus()),
        GetPage(name: "/AddBus", page: () => AddBus()),
        GetPage(name: "/AccueilAdmin", page: () => AccueilAdmin()),
        GetPage(name: "/AddAdmin", page: () => AddAdmin()),
        GetPage(name: "/HomeStation", page: () => HomeStation()),
        GetPage(name: "/AddStation", page: () => AddStation()),
        GetPage(name: "/SearchBus", page: () => SearchBus()),
        GetPage(name: "/HomeParcours", page: () => HomeParcours()),
        GetPage(name: "/AddParcours", page: () => AddParcours()),
      ],
      */
      //initialRoute: "/login",
    );
  }
}
