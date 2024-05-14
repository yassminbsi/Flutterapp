import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

class AddAdmin extends StatefulWidget {
  const AddAdmin({super.key});

  @override
  State<AddAdmin> createState() => _AddAdminState();
}
class _AddAdminState extends State<AddAdmin> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nom= TextEditingController();
 TextEditingController prenom= TextEditingController();
 TextEditingController phone= TextEditingController();
 TextEditingController email= TextEditingController();
 TextEditingController password= TextEditingController();
 TextEditingController confirmpassword= TextEditingController();
 CollectionReference admin = FirebaseFirestore.instance.collection('admin');
bool isLoading= false;
bool showpass = true;
AddAdmin() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
      });
    DocumentReference response = await admin.add(
  {
    "nom": nom.text,
    "Utilisateur": {
      "id": FirebaseAuth.instance.currentUser!.uid,
    },
    "prenom": prenom.text,
    "phone": phone.text,
    "email": email.text,
    "password": password.text,
    "confirmpassword": confirmpassword.text,
    // Ajoutez d'autres champs du bus au besoin
  },
);
    //Navigator.of(context).pushNamedAndRemoveUntil("/ControlePage", (route) => false);
    Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 2,) // 2 est l'index de l'onglet "AccueilAdmin"
                ),
                );
    } catch(e) {
      isLoading= false;
      setState(() {
      });
      print("Error $e");
    }
  }
}
@override
  void dispose() {
    
    super.dispose();
    nom.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
        'Ajout Admin', style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
         ),
      actions: [
        Row(
          children: [
            Text("", style: TextStyle(color: Color(0xFFffd400)),),
            IconButton(onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushNamedAndRemoveUntil("/loginbasedrole", (route) => false);
            }, icon: Icon(Icons.exit_to_app, color: Color(0xFFffd400),)),
          ],
        )
        ],),
        backgroundColor: Colors.white,
      body: Form(
        key: formState,
        child: isLoading ? Container(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(
            children: [
            Container(
              decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("images/font.jpg"),
            fit: BoxFit.cover,)),
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Center(
                child: Container(
                 alignment: Alignment.topCenter,
                 width: 100,
                 height: 100,
                 padding: EdgeInsets.all(10),
                 decoration:  BoxDecoration(
                   
                   borderRadius: BorderRadius.circular(70)
                  ),
                 child: Image.asset("images/user.png",
                 height: 100,),
                 ),
              ),
              Center(
             child:
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add , color:Color(0xFF6750A4),size: 27,),
              Text("Ajouter un admin",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, 
              color: Color(0xFF6750A4),)),
            ],
          ),
           ),    
TextFormField(
   validator: (val) {
       if (val == "") {
        return "Ne peut pas être vide";
      }
     }, 
 controller: nom,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.person,),
  //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
 label: Text('Nom')
 ),
),


SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
      validator: (val) {
        if (val == "") {
         return "Ne peut pas être vide";
       }
      }, 
  controller: prenom,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.person,),
    //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Prénom')
  ),
),
 SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
  validator: (val) {
    if (val!.isEmpty) {
      return "Ne peut pas être vide";
    } else if (int.tryParse(val) == null) {
      return "Format invalide. Entrez un numéro de téléphone valide.";
    }
  }, 
  controller: phone,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.phone,),
   // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Numéro de tél.')
  ),
),
 SizedBox(height: 10),            // Ajout d'un espace vertical entre les champs de texte
TextFormField(
  validator: (val) {
    if (val == "") {
      return "Ne peut pas être vide";
    } else if (!RegExp(r"^[a-zA-Z0-9]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(val!)) {
      return "Format invalide (ex: exemple@gmail.com)";
    }
  },
  controller: email,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.email,),
  //  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Email')
  ),
),
 SizedBox(height: 10),// Ajout d'un espace vertical entre les champs de texte  
TextFormField(
  validator: (val){
     if (val!.isEmpty) {
      return "Ne peut pas être vide";
    }
  },
  obscureText: showpass,
  controller: password,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.lock,),
    suffixIcon: IconButton(
      onPressed: (){
        setState(() {
          showpass=! showpass;
        });
      },icon: showpass== true? Icon(Icons.visibility_off):Icon(Icons.visibility)),
   // border: OutlineInputBorder(borderRadius: BorderRadius.circular(20),),
    label: Text('Mot de passe')
  ),
),
  SizedBox(height: 10),
                 // Ajout d'un espace vertical entre les champs de texte
   
TextFormField(
    validator: (val) {
    if (val!.isEmpty) {
      return "Ne peut pas être vide";
    } else if (val != password.text) {
      return "Les mots de passe ne correspondent pas";
    }
  }, 
  obscureText: showpass,
  controller: confirmpassword,
  decoration: InputDecoration(
    prefixIcon: Icon(Icons.lock,),
    suffixIcon: IconButton(
      onPressed: (){
        setState(() {
          showpass=! showpass;
        });
      },icon: showpass== true? Icon(Icons.visibility_off):Icon(Icons.visibility)),
    //border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), ),
    label: Text('Confirmer mot de passe')
  ),
),
SizedBox(height: 10), 

 Center(
   child: CustomButtonAuth(
      title: "Ajouter",
      onPressed: (){
      AddAdmin();
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
      content: Text("L'admin a été ajouté avec succès", style: TextStyle(color: Colors.black), 
      ),
      backgroundColor: const Color.fromARGB(255, 197, 197, 197),
      duration: Duration(seconds: 2),
      ),
      );
     },),
 ),
     SizedBox(height: 10), 
     ],
 ),
),    
   ],),
        ),
      ),

    );
  }
}