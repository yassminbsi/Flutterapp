import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/view/dashboard/dashboard_screen.dart';

class EditAdmin extends StatefulWidget {
  final String docid;
  final String oldnom;
  final String oldprenom;
  final String oldphone;
  final String oldemail;
  final String oldpassword;
  final String oldconfirmpassword;

  const EditAdmin({super.key, required this.docid, required this.oldnom, required this.oldprenom, required this.oldphone, required this.oldemail, required this.oldpassword, required this.oldconfirmpassword});

  @override
  State<EditAdmin> createState() => _EditAdminState();
}

class _EditAdminState extends State<EditAdmin> {
 GlobalKey<FormState> formState=  GlobalKey<FormState>();
 TextEditingController nom= TextEditingController();
 TextEditingController prenom= TextEditingController();
 TextEditingController phone= TextEditingController();
 TextEditingController email= TextEditingController();
 TextEditingController password= TextEditingController();
 TextEditingController confirmpassword= TextEditingController();
 CollectionReference admin = FirebaseFirestore.instance.collection('admin');
 bool showpass = true;
bool isLoading= false;
EditAdmin() async{
  if (formState.currentState!.validate()){
    try {
      isLoading= true;
      setState(() {
        
      });
    await admin.doc(widget.docid).update({
      "nom": nom.text,
      "prenom":prenom.text,
      "phone":phone.text,
      "email":email.text,
      "password":password.text,
      "confirmpassword":confirmpassword.text,
    });
    //Navigator.of(context).pushNamedAndRemoveUntil("/AccueilAdmin", (route) => false);
    Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                builder: (context) => DashboardScreen(initialTabIndex: 2,),// 2 est l'index de l'onglet "AccueilAdmin"
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
    // TODO: implement dispose
    super.dispose();
    nom.dispose();
    prenom.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    confirmpassword.dispose();

  }
@override
  void initState() {
    super.initState();
    nom.text= widget.oldnom;
    prenom.text= widget.oldprenom;
    phone.text= widget.oldphone;
    email.text= widget.oldemail;
    password.text= widget.oldpassword;
    confirmpassword.text= widget.oldconfirmpassword;

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Color(0xFFffd400)),
        backgroundColor: Color(0xFF25243A),
        title: const Text(
        'Modifier Admin', style: TextStyle(color: Color(0xFFffd400), fontSize: 17,),
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
      body: Form(
        key: formState,
        child: isLoading ? Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
          child: Column(children: [
            Container(
              decoration: BoxDecoration(
            image: DecorationImage(image: AssetImage("images/font.jpg"),
            fit: BoxFit.cover,)),
              padding: EdgeInsets.symmetric(horizontal: 20,vertical: 20),
              child: Column(
               crossAxisAlignment: CrossAxisAlignment.start, 
               mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //CustomLogoAuth(),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit , color:Color(0xFF6750A4),size: 27,),
              Text("Modifier admin",
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
SizedBox(height: 15),              
Center(
              child: CustomButtonAuth(
                title: "Enregistrer les modifications",
                onPressed: (){
                  EditAdmin();
                  ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(
                             content: Text("L'admin a été modifié avec succès", style: TextStyle(color: Colors.black), 
                             ),
                             backgroundColor: const Color.fromARGB(255, 197, 197, 197),
                             duration: Duration(seconds: 2),
                  ),
                );
                },),
            ),
              SizedBox(height: 10,)
           ],
            ),
            ),
          ],),
        ),
      ),

    );
  }
}