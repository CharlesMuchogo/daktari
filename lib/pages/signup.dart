// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:daktari/GlobalComponents/authenticationservice.dart';

import 'package:daktari/GlobalComponents/restapi.dart';
import 'package:daktari/pages/login.dart';
import 'package:provider/provider.dart';

import '../GlobalComponents/authenticationservice.dart';

class Signup extends StatefulWidget {
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController firstNamecontroler = TextEditingController();
    TextEditingController lastNamecontroler = TextEditingController();
    TextEditingController emailcontroler = TextEditingController();
    TextEditingController phoneNumbercontroler = TextEditingController();
    TextEditingController passwordcontroler = TextEditingController();
    TextEditingController confirmpasswordcontroler = TextEditingController();
    TextEditingController licensenumbercontroler = TextEditingController();
    TextEditingController currentHospitalcontroler = TextEditingController();

    double heightOfDevice = MediaQuery.of(context).size.height;
    bool isLoading = false;

    void _input() async {
      await context.read<AuthenticationService>().signUp(
          email: emailcontroler.text.toLowerCase().trim(),
          password: passwordcontroler.text.trim());

      RestApi rest = RestApi();

      await rest.createData(
          firstNamecontroler.text.trim(),
          lastNamecontroler.text.trim(),
          emailcontroler.text.trim(),
          phoneNumbercontroler.text,
          licensenumbercontroler.text.trim(),
          currentHospitalcontroler.text);

      return Navigator.of(context).pop();
    }

    return Scaffold(
      body: FutureBuilder<Object>(
          future: null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              setState(() {
                isLoading = true;
              });
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return MaterialApp(
                home: Scaffold(
                  body: Center(child: Text("Error Occured")),
                ),
              );
            }
            List<String> gender = ["Male", "Female", "Non-binary"];

            String dropdownValue = "Male";

            return Column(
              children: [
                SizedBox(
                  height: heightOfDevice * 0.25,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      logo("Daktari", 32, Colors.teal),
                      logo("Health Is Wealth", 15, Colors.black)
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  children: [
                                    textfields(firstNamecontroler,
                                        "Enter your first name"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(lastNamecontroler,
                                        "Enter your last name"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        emailcontroler, "Enter your email"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(phoneNumbercontroler,
                                        "Enter phone number"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ListTile(
                                      title: Text("Select your gender"),
                                      trailing: DropdownButton(
                                        value: dropdownValue,
                                        onChanged: (value) {
                                          setState(
                                            () {
                                              dropdownValue = value.toString();
                                            },
                                          );
                                        },
                                        items: gender.map(
                                          (String items) {
                                            return DropdownMenuItem(
                                              value: items,
                                              child: Text(items),
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                    textfields(licensenumbercontroler,
                                        "Enter Your Licence number"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(currentHospitalcontroler,
                                        "Enter your current hospital"),

                                    SizedBox(
                                      height: 10,
                                    ),

                                    /// add sex and specialty
                                    passwordFields(
                                        passwordcontroler, "Create password"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    passwordFields(confirmpasswordcontroler,
                                        "Confirm password"),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    SizedBox(
                                      height: 42,
                                      width: 196,
                                      child: isLoading
                                          ? CircularProgressIndicator()
                                          : ElevatedButton(
                                              onPressed: _input,
                                              style: ElevatedButton.styleFrom(
                                                  primary: Colors.teal),
                                              child: Text("Sign up"),
                                            ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
    );
  }
}

Widget textfields(
  TextEditingController textfieldcontroler,
  String placeholder,
) {
  return TextFormField(
    controller: textfieldcontroler,
    decoration: InputDecoration(
      labelText: placeholder,
      //hintText: placeholder
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

Widget passwordFields(
  TextEditingController textfieldcontroler,
  String placeholder,
) {
  return TextFormField(
    controller: textfieldcontroler,
    obscureText: true,
    decoration: InputDecoration(
      labelText: placeholder,
      //hintText: placeholder
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
