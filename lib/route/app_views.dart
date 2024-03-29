import 'package:flutter_app/mapwidget/constnats/strings.dart';
import 'package:flutter_app/mapwidget/presentation/screens/map_screen.dart';
import 'package:flutter_app/userwidget/map-user.dart';
import 'package:flutter_app/view/dashboard/dashboard_binding.dart';
import 'package:get/get.dart';
import 'package:flutter_app/route/app_route.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';
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
import 'package:flutter_app/auth/login.dart';
import 'package:flutter_app/auth/signup.dart';
import 'package:flutter_app/views/add.dart';
import 'package:flutter_app/bus/addbus.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/auth/Homepage.dart';
import 'package:flutter_app/auth/logiin.dart';
import 'package:flutter_app/auth/login_admin.dart';
import 'package:flutter_app/auth/search_bus.dart';
import 'package:flutter_app/auth/signup_admin.dart';
import 'package:flutter_app/auth/logiin.dart';



class AppPageList {
  static var MyList = [
    GetPage(name: "/login", page: () => MainScreen()),
    GetPage(name: "/home", page: () => Homepage()),
    GetPage(name: "/signupAdmin", page: () => signupAdmin()),
    GetPage(name: "/loginAdmin", page: () => LoginAdmin()),
    
    GetPage(name: "/HomeBus", page: () => HomeBus()),
    GetPage(name: "/AddBus", page: () => AddBus()),
    GetPage(name: "/AccueilAdmin", page: () => AccueilAdmin()),
    GetPage(name: "/AddAdmin", page: () => AddAdmin()),
    GetPage(name: "/HomeStation", page: () => HomeStation()),
    GetPage(name: "/AddStation", page: () => AddStation()),
    GetPage(name: "/SearchBus", page: () => SearchBus()),
    GetPage(name: "/HomeParcours", page: () => HomeParcours()),
    GetPage(name: "/AddParcours", page: () => AddParcours()),
  ];
}
