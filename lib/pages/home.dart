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
                      upcomingAppointments(_uid!),
                      SizedBox(
                        height: 33,
                      ),
                      textInfo('My favorite doctors'),
                      SizedBox(
                        height: 10,
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DoctorInfo()),
                            );
                          },
                          child: info()),
                      SizedBox(
                        height: 33,
                      ),
                      textInfo('Top ratted specialist'),
                      SizedBox(
                        height: 10,
                      ),
                      info(),
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

Widget info() {
  return Container(
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: 10,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => Container(
                height: 200,
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
                  child: infocards("Charles Muchogo",
                      'assets/images/profile.jpg', "Gaenacologist"),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget infocards(String name, String displayPhoto, String doctorSpecialty) {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: AssetImage(displayPhoto),
      radius: 32.0,
    ),
    title: Text(
      name,
      style: TextStyle(
        color: Colors.black,
        fontSize: 18,
      ),
    ),
    subtitle: Text(
      doctorSpecialty,
      style: TextStyle(
        color: Color.fromARGB(255, 21, 121, 91),
        fontSize: 15,
      ),
    ),
    trailing: Icon(
      Icons.more_vert,
      color: Color.fromARGB(255, 21, 121, 91),
    ),
  );
}

Widget upcomingAppointments(String _uid) {
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Appointments")
          .orderBy("Date")
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 200,
            width: 300,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text("Oops. An error occured. Try again later");
        }
        if (snapshot.data!.size <= 0) {
          return SizedBox(
            height: 150,
            width: 300,
            child: Center(
              child: Text(
                "You have no upcomming appointments",
                style: TextStyle(fontSize: 17),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                child: ListView.builder(
                  itemCount: snapshot.data?.size,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Container(
                    height: 200,
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
                          offset: Offset(0.0, 1.0),
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: appointmentcards(
                        context,
                        snapshot.data!.docs[index]["Time"],
                        snapshot.data!.docs[index]["Address"],
                        snapshot.data!.docs[index].id,
                        snapshot.data!.docs[index]["Date"],
                        snapshot.data!.docs[index]["Consultation"],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

Widget appointmentcards(
  BuildContext context,
  String time,
  String address,
  String patientId,
  String dateOfAppointment,
  String consultation,
) {
  return ListTile(
    leading: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dateOfAppointment,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    ),

    title: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          time,
          style: TextStyle(
            color: Colors.teal,
            fontSize: 18,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Text(
          address,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
          ),
        ),
      ],
    ),
    // subtitle: ,
    trailing: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AppointmentPage(
                    patientId,
                    dateOfAppointment,
                    consultation,
                  )),
        ); // navigate to Appointments page
      },
      child: Icon(
        Icons.more_vert,
        color: Color.fromARGB(255, 21, 121, 91),
      ),
    ),
  );
}
