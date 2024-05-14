import 'package:flutter/material.dart';



class CustomButtonAuth extends StatelessWidget {
  final VoidCallback onPressed;
  final String title;
  const CustomButtonAuth({super.key, required this.onPressed, required this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
            height: 50,
            shape: 
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            color: Color(0xFF25243A),
            textColor: Color(0xFFffd400),
            onPressed: onPressed,
            child: Text(title, style: TextStyle(fontSize: 16),),
            
          );
  }
}
