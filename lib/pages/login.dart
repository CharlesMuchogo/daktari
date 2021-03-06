// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:daktari/pages/signup.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

final Future<FirebaseApp> initialize = Firebase.initializeApp();

class _loginState extends State<login> {
  int _selectedPageIndex = 0;

  int navigateToSignup() {
    setState(() {
      _selectedPageIndex = 1;
    });
    return _selectedPageIndex;
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, Widget>> widgetList = [
      {'page': loginfunctionality(context, navigateToSignup)},
      {'page': Signup()}
    ];

    return Scaffold(body: widgetList[_selectedPageIndex]['page']);
  }
}

Widget loginfunctionality(BuildContext context, Function navigation) {
  double heightOfDevice = MediaQuery.of(context).size.height;
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool waiting = false;

  void navigate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Signup()),
    );
  }

  void login() {
    if (ConnectionState.waiting == true) {
      waiting = true;
    }
    try {
      _auth.signInWithEmailAndPassword(
          email: emailcontroler.text.toLowerCase().trim(),
          password: passwordcontroler.text.trim());
    } catch (e) {
      print(e);
    }
  }

  return Scaffold(
    body: FutureBuilder<Object>(
      future: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Material(
            child: Center(
              child: Text("Error Occured. Reaload the application"),
            ),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: heightOfDevice * 0.25,
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    logo(
                      "daktari",
                      32,
                      Colors.teal,
                    ),
                    logo("Health Is Wealth", 17, Colors.black)
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    textfields(emailcontroler, "Enter your Email Address"),
                    const SizedBox(
                      height: 20,
                    ),
                    textfields(passwordcontroler, "Enter your password"),
                    const SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(fontSize: 18, color: Colors.teal),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Signup()),
                        );
                      },
                    ),
                    SizedBox(
                      height: 23,
                    ),
                    SizedBox(
                      height: 42,
                      width: 196,
                      child: waiting
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: login,
                              child: Text("Login"),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.teal,
                              ),
                            ),
                    ),
                    SizedBox(
                      height: 35,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Dont have an account? ",
                          style: TextStyle(color: Colors.black, fontSize: 18),
                        ),
                        InkWell(
                          onTap: navigate,
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.teal,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          );
        }
      },
    ),
  );
}

Widget textfields(
  TextEditingController textfieldcontroler,
  String placeholder,
) {
  if (placeholder == "Enter your password") {
    return TextFormField(
      obscureText: true,
      controller: textfieldcontroler,
      decoration: InputDecoration(
        labelText: placeholder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.teal),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black45,
            width: 1.5,
          ),
        ),
      ),
    );
  } else {
    return TextFormField(
      controller: textfieldcontroler,
      decoration: InputDecoration(
        labelText: placeholder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.teal),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(
            color: Colors.black,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black45,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

Widget logo(String logocomponent, double fontsize, Color textcolor) {
  return Text(
    logocomponent,
    style: TextStyle(color: textcolor, fontSize: fontsize, letterSpacing: 1.5),
  );
}
