import 'package:flutter/material.dart';
 class CustomLogoAuth extends StatelessWidget {
   const CustomLogoAuth({super.key});
 
   @override
   Widget build(BuildContext context) {
     return  Center(
                child: Container(
                 
                  alignment: Alignment.center,
                  width: 90,
                  height: 90,
                  padding: EdgeInsets.all(10),
                 
                  
                        child: Image.asset(
                            "images/Bus.png",
                            width: 60, height:60,
                            //fit: BoxFit.fill,
                          ),
                     
                ),
              );
   }
 }