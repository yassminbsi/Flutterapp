import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/station/view-station.dart';
import 'package:flutter_app/view/dashboard/homeadminY.dart';

class ControlePage extends StatefulWidget {
  final int initialTabIndex;
  const ControlePage({super.key, required this.initialTabIndex});
  @override
  State<ControlePage> createState() => _ControlePageState();
}

class _ControlePageState extends State<ControlePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     _tabController = TabController(
      length: 4, 
      vsync: this, initialIndex: widget.initialTabIndex );
   // _tabController.index = ModalRoute.of(context)!.settings.arguments as int? ?? 0;
  }
  @override
  Widget build(BuildContext context) {
     User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
        backgroundColor: Color.fromARGB(242, 255, 226, 61),
       // Color.fromARGB(255, 50, 112, 173),
        title:  Text("Accueil", style: TextStyle(color: Colors.black,),), 
        actions: [
          Row(
            children: [
              Text("", style: TextStyle(color: Colors.black),),
              IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/loginAdmin", (route) => false);
                      }, icon: Icon(Icons.exit_to_app, color: Colors.black)),
            ],
          )
        ],
       bottom: TabBar(
        controller: _tabController,
        labelColor: Color.fromARGB(255, 21, 165, 209),
        unselectedLabelColor: Colors.black,
        indicatorColor: Color.fromARGB(255, 21, 165, 209),
        tabs: [
          Tab(icon: Icon(Icons.home, size: 25), text: "Home",),
          Tab(icon: Icon(Icons.directions_bus, size: 25), text: "Ligne", ),
          Tab(icon: Icon(Icons.person, size: 25), text: "Admin", ),
          Tab(icon: Icon(Icons.location_on, size: 25), text: "Station", ),
        ],),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          HomeAdmin(),
          HomeBus(),
          AccueilAdmin(),
          HomeStation(),
        ],),
      ),

    );
  }
}