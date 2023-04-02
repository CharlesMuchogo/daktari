import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../GlobalComponents/autheticationwrapper.dart';
import 'login.dart';


class Not_Authorized extends StatelessWidget {
  const Not_Authorized({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(child: Text("Oops.. You are not authorized to continue. \n Please log out and use the right credentials"),),
          ElevatedButton(onPressed: () {     try {
           FirebaseAuth.instance.signOut();
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>AuthenticationWrapper())
            );

          } on FirebaseAuth catch (e) {
            print(e);
          } }, child: Text("Log Out"),)
        ],
      ),
    );
  }
}
