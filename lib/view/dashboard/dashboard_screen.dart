import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/admin/view-admin.dart';
import 'package:flutter_app/bus/viewbus.dart';
import 'package:flutter_app/view/dashboard/homeadminY.dart';

import '../../station/view-station.dart';


class DashboardScreen extends StatefulWidget {
  final int initialTabIndex;
  const DashboardScreen({Key? key, required this.initialTabIndex}) : super(key: key);
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;

    return Scaffold(
    /*  appBar: AppBar(
        
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
          'Bienvenue',
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
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    child: Image.asset('images/icon_user.png'),
                  ),
                  Text('Compte admin:'),
                  Text(email ?? 'user@example.com', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home, color: Color(0xFFffd400)),
              title: Text(
                'Home Admin',
                style: TextStyle(color: Color(0xFFffd400), fontSize: 24),
              ),
              tileColor: Color(0xFF25243A),
            ),
            ListTile(
              onTap: () { Navigator.of(context).pushNamed("/AddBus"); },
              leading: Icon(Icons.add),
              title: Text('Ajouter Bus'),
            ),
            ListTile(
              onTap: () { Navigator.of(context).pushNamed("/AddAdmin"); },
              leading: Icon(Icons.add),
              title: Text('Ajouter Admin'),
            ),
            ListTile(
              onTap: () { Navigator.of(context).pushNamed("/AddStation"); },
              leading: Icon(Icons.add),
              title: Text('Ajouter Station'),
            ),
            ListTile(
              onTap: () { Navigator.of(context).pushNamed("/loginbasedrole"); },
              leading: Icon(Icons.exit_to_app),
              title: Text('Déconnexion'),
            ),
          ],
        ),
      ),*/
      body: TabBarView(
        controller: _tabController,
        children: [
          Container(
            color: Colors.red,
            child: HomeAdmin(),
          ),
          Container(
            color: Colors.blue,
            child: HomeBus(),
          ),
          Container(
            color: Colors.orange,
            child: AccueilAdmin(),
          ),
          Container(
            color: Colors.orange,
            child: HomeStation(),
          ),
        ],
      ),
  bottomNavigationBar: BottomNavigationBar(
  type: BottomNavigationBarType.shifting, // Set type to circular
  currentIndex: _tabController.index,
  onTap: (index) {
    setState(() {
      _tabController.animateTo(index);
    });
  },
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Accueil',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.bus_alert),
      label: 'Ligne',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.account_circle),
      label: 'Admin',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chair_alt_outlined),
      label: 'Station',
    ),
  ],
  selectedItemColor: Color(0xFFffd400),
  unselectedItemColor: Color(0xFF25243A),
  backgroundColor: Color(0xFF25243A),
  showUnselectedLabels: true,
  selectedFontSize: 14,
  unselectedFontSize: 12,
  selectedIconTheme: IconThemeData(color: Color(0xFFffd400)),
  unselectedIconTheme: IconThemeData(color: Color(0xFF25243A)),
  selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
)




    );
  }
}
