import 'package:flutter/material.dart';



class CustomButtonAuth extends StatelessWidget {
  final void Function()? onPressed;
  final String title;
  const CustomButtonAuth({super.key, this.onPressed, required this.title, required String hinttext, required String? Function(dynamic val) validator, required TextEditingController mycontroller, required bool obscureText});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
            height: 50,
            shape: 
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Color.fromARGB(255, 25, 96, 167),
            textColor: Colors.white,
            onPressed: onPressed,
            child: Text(title),
            
          );
  }
}
