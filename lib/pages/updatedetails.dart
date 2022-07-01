// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class UpdateDetails extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String currentHospital;
  UpdateDetails(this.userId, this.firstName, this.lastName, this.phoneNumber,
      this.currentHospital);

  @override
  State<UpdateDetails> createState() => _UpdateDetailsState();
}

class _UpdateDetailsState extends State<UpdateDetails> {
  @override
  Widget build(BuildContext context) {
    TextEditingController firstnamecontroler = TextEditingController();
    TextEditingController lastnamecontroler = TextEditingController();
    TextEditingController addresscontroler = TextEditingController();
    TextEditingController phonenumbercontroler = TextEditingController();

    firstnamecontroler.text = widget.firstName;
    lastnamecontroler.text = widget.lastName;
    phonenumbercontroler.text = widget.phoneNumber;
    addresscontroler.text = widget.currentHospital;

    Future updateDetails() async {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
      try {
        await FirebaseFirestore.instance
            .collection("Doctor")
            .doc(widget.userId)
            .update(
          {
            "First Name": firstnamecontroler.text,
            "Last Name": lastnamecontroler.text,
            "Current Hospital": addresscontroler.text,
            "Phone Number": phonenumbercontroler.text
          },
        );

        Navigator.pop(context);
      } on FirebaseException catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error!"),
              content: Text(
                e.message.toString(),
              ),
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Update Details"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            textfields(firstnamecontroler, "First Name"),
            SizedBox(
              height: 10,
            ),
            textfields(lastnamecontroler, "Last name"),
            SizedBox(
              height: 10,
            ),
            textfields(addresscontroler, "Address"),
            SizedBox(
              height: 10,
            ),
            textfields(phonenumbercontroler, "Phone Number"),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: updateDetails, child: Text("Save Details"))
          ],
        ),
      ),
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
