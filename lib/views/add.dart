import 'package:flutter/material.dart';
import 'package:flutter_app/componenents/customtextfieldadd.dart';

class AddCard extends StatefulWidget {
  const AddCard({super.key});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("add Bus")),
        body: Form(
            key: formState,
            child: Column(children: [
              CustomTextFormAdd(
                  hinttext: "Enter New Bus",
                  mycontroller: name,
                                    validator: (val) => (val!.isEmpty
                                    )
                    ? "Enter valid number"
                    : null,
              )
            ])));
  }
}
