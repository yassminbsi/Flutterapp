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
  TextEditingController bus_id = TextEditingController();
  TextEditingController mat_b = TextEditingController();
  TextEditingController year_b = TextEditingController();
  TextEditingController volume_b = TextEditingController();
  TextEditingController assurance_b = TextEditingController();

  CollectionReference bus = FirebaseFirestore.instance.collection('bus');

  addBus() async {
    if (formState.currentState!.validate()) {
      try {
        DocumentReference response = await bus.add({
          "bus_id": bus_id.text,
          "mat_id": mat_b.text,
          "year_b": year_b.text,
          "volume_b": volume_b.text,
          "assurance_b": assurance_b.text,
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
                  hinttext: "Numéro Bus",
                  mycontroller: bus_id,
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter valid number" : null,
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                    vertical: 20, horizontal: 20),
                child: CustomTextFormAdd(
                  hinttext: "Matricule",
                  mycontroller: mat_b,
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter valid number" : null,
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                    vertical: 20, horizontal: 20),
                child: CustomTextFormAdd(
                  hinttext: "Année",
                  mycontroller: year_b,
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter valid number" : null,
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                    vertical: 20, horizontal: 20),
                child: CustomTextFormAdd(
                  hinttext: "volume",
                  mycontroller: volume_b,
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter valid number" : null,
                ),
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                    vertical: 20, horizontal: 20),
                child: CustomTextFormAdd(
                  hinttext: "assurance",
                  mycontroller: assurance_b,
                  validator: (val) =>
                      (val!.isEmpty) ? "Enter valid number" : null,
                ),
              ),
           MaterialButton(onPressed: (){})
            ])));
  }
}

        