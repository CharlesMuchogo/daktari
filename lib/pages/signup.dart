// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:cloud_firestore/cloud_firestore.dart';
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
  var selectedCategory;
  TextEditingController firstNamecontroler = TextEditingController();
  TextEditingController lastNamecontroler = TextEditingController();
  TextEditingController emailcontroler = TextEditingController();
  TextEditingController phoneNumbercontroler = TextEditingController();
  TextEditingController passwordcontroler = TextEditingController();
  TextEditingController confirmpasswordcontroler = TextEditingController();
  TextEditingController licensenumbercontroler = TextEditingController();
  TextEditingController currentHospitalcontroler = TextEditingController();

  Future _input() async {
    if ((firstNamecontroler.text.trim().isEmpty ||
        lastNamecontroler.text.trim().isEmpty ||
        emailcontroler.text.trim().isEmpty ||
        phoneNumbercontroler.text.trim().isEmpty ||
        passwordcontroler.text.trim().isEmpty ||
        confirmpasswordcontroler.text.trim().isEmpty ||
        licensenumbercontroler.text.trim().isEmpty ||
        currentHospitalcontroler.text.isEmpty ||
        selectedCategory == null)) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error !"),
              content: Text("Fill in all the details"),
              actions: [
                MaterialButton(
                    child: Text("Okay"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ],
            );
          });
    } else {
      if (passwordcontroler.text != confirmpasswordcontroler.text) {
        return showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Error !"),
                content: Text("Passwords do not match"),
                actions: [
                  MaterialButton(
                      child: Text("Okay"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              );
            });
      }
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
          currentHospitalcontroler.text,
          selectedCategory.toString());

      return Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;
    bool isLoading = false;

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
                                    textfields(
                                        firstNamecontroler,
                                        "Enter your first name",
                                        TextInputType.name),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        lastNamecontroler,
                                        "Enter your last name",
                                        TextInputType.name),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        emailcontroler,
                                        "Enter your email",
                                        TextInputType.emailAddress),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        phoneNumbercontroler,
                                        "Enter phone number",
                                        TextInputType.phone),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        licensenumbercontroler,
                                        "Enter Your Licence number",
                                        TextInputType.name),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    textfields(
                                        currentHospitalcontroler,
                                        "Enter your current hospital",
                                        TextInputType.name),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    StreamBuilder(
                                        stream: FirebaseFirestore.instance
                                            .collection("Doctor Categoty")
                                            .snapshots(),
                                        builder: (context,
                                            AsyncSnapshot<QuerySnapshot>
                                                snapshot) {
                                          if (!snapshot.hasData) {
                                            return Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }

                                          List<DropdownMenuItem>
                                              doctorCategories = [];

                                          for (int i = 0;
                                              i < snapshot.data!.docs.length;
                                              i++) {
                                            DocumentSnapshot snap =
                                                snapshot.data!.docs[i];

                                            doctorCategories
                                                .add(DropdownMenuItem(
                                              child: Text(snap.id),
                                              value: snap.id,
                                            ));
                                          }

                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "Select Your Specialty",
                                                style: TextStyle(fontSize: 17),
                                              ),
                                              SizedBox(width: 50.0),
                                              DropdownButton(
                                                items: doctorCategories,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedCategory =
                                                        value.toString();
                                                  });
                                                },
                                                value: selectedCategory,
                                                isExpanded: false,
                                                hint: Text(
                                                  "Choose your specialty",
                                                ),
                                              ),
                                            ],
                                          );
                                        }),
                                    SizedBox(
                                      height: 10,
                                    ),
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

Widget textfields(TextEditingController textfieldcontroler, String placeholder,
    TextInputType keyboardtype) {
  return TextFormField(
    controller: textfieldcontroler,
    keyboardType: keyboardtype,
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
