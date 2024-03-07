import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_app/auth/Homepage.dart';
import 'package:flutter_app/auth/login.dart';
import 'package:flutter_app/auth/signup.dart';
import 'package:flutter_app/views/add.dart';

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
    return MaterialApp(
      theme: ThemeData(appBarTheme: AppBarTheme(
        backgroundColor:  Color(0xFFFFCA20),
        titleTextStyle: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
      iconTheme: IconThemeData(color: Colors.black87 , size: 28)
      )),
      debugShowCheckedModeBanner: false,
      home: (FirebaseAuth.instance.currentUser != null &&
              FirebaseAuth.instance.currentUser!.emailVerified)
          ? Homepage()
          : Login(),
      routes: {
        "signup": (context) => signup(),
        "login": (context) => Login(),
        "homepage": (context) => Homepage(),
        "Addviews": (context) => AddCard(),
      },
    );
  }
}
