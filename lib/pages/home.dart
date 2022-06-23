// ignore_for_file: prefer_const_constructors, unnecessary_new, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:daktari/pages/appointment.dart';
import 'package:daktari/pages/doctor_information.dart';

class home extends StatefulWidget {
  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  @override
  Widget build(BuildContext context) {
    double heightOfDevice = MediaQuery.of(context).size.height;
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? _user = _auth.currentUser;
    final _uid = _user?.uid;

    return Scaffold(
      backgroundColor: Colors.teal,
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("Doctor")
                  .doc(_uid)
                  .snapshots(),
              builder: (context,
                  AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                      snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {}

                var hour = DateTime.now().hour;
                String greeting() {
                  hour = DateTime.now().hour;

                  if (hour < 12) {
                    return 'Good Morning';
                  }
                  if (hour < 17) {
                    return 'Good Afternoon';
                  }
                  return 'Good Evening';
                }

                return Container(
                  height: heightOfDevice / 4,
                  width: double.infinity,
                  color: Colors.teal,
                  child: Center(
                    child: Text(
                      greeting() + ", Dr. " + snapshot.data?.get("First Name"),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }),
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    borderRadius: new BorderRadius.only(
                      topLeft: const Radius.circular(30.0),
                      topRight: const Radius.circular(30.0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 33,
                      ),
                      textInfo('Upcoming appointments'),
                      SizedBox(
                        height: 10,
                      ),
                      doctorInfoCard()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget textInfo(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
    child: Text(
      text,
      style: TextStyle(
          color: Colors.teal, fontSize: 25, fontWeight: FontWeight.bold),
    ),
  );
}

Widget doctorInfoCard() {
  return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("Appointments").snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("An error occured. please try again later");
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 700,
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) => Container(
                    height: 100,
                    width: 300,
                    margin: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                      color: Color.fromRGBO(245, 242, 242, 20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: infocards(
                          context,
                          snapshot.data!.docs[index].get("Date"),
                          snapshot.data!.docs[index].get("Address"),
                          snapshot.data!.docs[index].get("Consultation")),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget infocards(BuildContext context, String dateOfAppointment,
    String addressOfAppointment, String consultationPurpose) {
  return InkWell(
    onTap: () {},
    child: ListTile(
      leading: Text(addressOfAppointment),
      title: Text(
        dateOfAppointment,
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        consultationPurpose,
        style: TextStyle(
          color: Colors.teal,
          fontSize: 15,
        ),
      ),
      trailing: Icon(
        Icons.more_vert,
        color: Colors.teal,
      ),
    ),
  );
}
