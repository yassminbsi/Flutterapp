import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class SignInScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithGooglePopup();
                if (user != null) {
                  print('Signed in with Google: ${user.displayName}');
                } else {
                  print('Google sign-in failed');
                }
              },
              child: Text('Sign in with Google (Popup)'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _authService.signInWithGoogleRedirect();
              },
              child: Text('Sign in with Google (Redirect)'),
            ),
          ],
        ),
      ),
    );
  }
}
