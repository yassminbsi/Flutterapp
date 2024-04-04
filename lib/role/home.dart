import 'package:flutter/material.dart';

class HomeUser extends StatefulWidget {
  @override
  _HomeUserState createState() => _HomeUserState();
}

class _HomeUserState extends State<HomeUser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "HomeUser",
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Please press the subscribe button for more videos",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 40,
            ),
            MaterialButton(
              color: Colors.red,
              onPressed: () {},
              child: Text(
                'Subscribe',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*FirebaseAuth.instance.authStateChanges().listen((user) async {
  if (user == null) {
    initialRoute = loginScreen;
  } else {
    final userDataSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (userDataSnapshot.exists) {
      final userRole = userDataSnapshot.get('role');
      initialRoute = userRole == "Admin" ? otpScreen : bus;
    } else {
      print('Document does not exist in the database');
      // Set default route or handle error case
    }
  }
});
 */