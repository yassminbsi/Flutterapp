import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/custombuttonauth.dart';
import 'package:flutter_app/componenents/customtextfieldadd.dart';

class AddCard extends StatefulWidget {
  const AddCard({super.key});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  CollectionReference bus = FirebaseFirestore.instance.collection('bus');

  addBus() async {
    if (formState.currentState!.validate()) {
      try {
        DocumentReference response = await
        bus
        .add({
          "name": name.text
          });
        Navigator.of(context).pushReplacementNamed("homepage");
      } catch (e) {
        print("error $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
        appBar: AppBar(title: Text("add Bus")),
        body: Form(
            key: formState,
            child: Column(children: [
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                    vertical: 20, horizontal: 20),
                child: CustomTextFormAdd(
                  hinttext: "Enter New Bus",
                  mycontroller: name,
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter valid number" : null,
                ),
              ),
              CustomButton(
                title: "Add Bus",
                onPressed: () {
                  addBus();
                },
              ),
            ])));
  }
}
