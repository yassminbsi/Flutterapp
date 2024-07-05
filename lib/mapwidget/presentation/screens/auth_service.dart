import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGooglePopup() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User canceled the sign-in
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> signInWithGoogleRedirect() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _auth.signInWithRedirect(googleProvider);
      final UserCredential userCredential = await _auth.getRedirectResult();
      final User? user = userCredential.user;
      if (user != null) {
        // User is signed in
      } else {
        // No user is signed in
      }
    } catch (e) {
      print(e);
    }
  }
}
