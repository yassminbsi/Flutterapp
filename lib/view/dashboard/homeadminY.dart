import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

class HomeAdmin extends StatelessWidget {
  const HomeAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? email = user?.email;
    return Scaffold(
     appBar: AppBar(
        
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
      ),
      body: Container(
       /* decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("images/Font_Accueil.jpg"),
            fit: BoxFit.cover,)),*/
        padding: EdgeInsets.symmetric(horizontal: 10,),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Container(
            width: 5333,
               height: 200,
               padding: EdgeInsets.all(10),
              /* decoration:  BoxDecoration(
                 color: const Color.fromARGB(255, 255, 255, 255),
                 borderRadius: BorderRadius.circular(70)
                ),*/
               child: Image.asset("images/logo.png", 
               height: 4000,),

          ),
        
          
            Container(
             alignment: Alignment.topCenter,
             child: Text("Accueil",
             style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF25243A), )),
            ),
            SizedBox(height: 10,),
           Center(
              child: MaterialButton(
                child: Text( "   Gérer les lignes   "),
                  height: 50,
            shape: 
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Color(0xFF25243A),
            textColor: Color(0xFFffd400),
        onPressed: () {
  Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => DashboardScreen(initialTabIndex: 1,)),
);
},
               ),
            ), 
            SizedBox(height: 20),
            Center(
              child: 
                  MaterialButton(
                    child: Text( " Gérer les Admins "),
                     height: 50,
            shape: 
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Color(0xFF25243A),
            textColor: Color(0xFFffd400),
                   onPressed: () {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => DashboardScreen(initialTabIndex: 2,), // Set tabIndex to 1 to navigate to HomeBus
    ),
  );
},
                    ),
                    
                
            ),
            SizedBox(height: 20),
            Center(
              child: 
                  MaterialButton(child: Text("Gérer les stations"),
                   height: 50,
            shape: 
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Color(0xFF25243A),
            textColor: Color(0xFFffd400),
                    onPressed: () {
  Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 3,) // 1 est l'index de l'onglet "AccueilAdmin"
                ),
                );
},
                   ),
                 
               
            ),
          ],),
      ),
    );
  }
} 