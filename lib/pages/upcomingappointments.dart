// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/pages/appointment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpcomingAppointments extends StatelessWidget {
  const UpcomingAppointments({super.key});

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Doctor")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("My appointments")
            .orderBy("Date", descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Text("An error occured. please try again later");
          }
          if (snapshot.data!.docs.isEmpty) {
            Center(
              child: Text("You do not have any upcoming appointments"),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 700,
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) => Container(
                    height: height * 0.15,
                    margin: EdgeInsets.only(
                        top: 15, bottom: 15, left: 25, right: 25),
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
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentPage(
                                snapshot.data!.docs[index].id,
                                snapshot.data!.docs[index]["Patient Id"],
                                snapshot.data!.docs[index]["Date"],
                                snapshot.data!.docs[index]["Consultation"],
                                snapshot.data!.docs[index]["Time"],
                                snapshot.data!.docs[index]["Address"],
                                snapshot.data!.docs[index]["Doctor Name"],
                                snapshot.data!.docs[index]["Status"],
                              ),
                            ),
                          ); // navigate to Appointments page
                        },
                        child: infocards(
                          context,
                          snapshot.data!.docs[index].get("Date"),
                          snapshot.data!.docs[index].get("Patient Id"),
                          snapshot.data!.docs[index].get("Time"),
                          snapshot.data!.docs[index].get("Status"),
                          snapshot.data!.docs[index]["Address"],
                          snapshot.data!.docs[index]["Consultation"],
                          snapshot.data!.docs[index].id,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  Widget infocards(
      BuildContext context,
      String dateOfAppointment,
      String patientId,
      String timeOfappointment,
      String statusOfAppointment,
      String adressOfAppointment,
      String consultation,
      String appointmentId) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Patient")
            .doc(patientId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                height: 200,
                width: 300,
              ),
            );
          }
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentPage(
                    appointmentId,
                    patientId,
                    dateOfAppointment,
                    consultation,
                    timeOfappointment,
                    adressOfAppointment,
                    (snapshot.data!.get("First Name") +
                        " " +
                        snapshot.data!.get("Last Name")),
                    statusOfAppointment,
                  ),
                ),
              ); // navigate to Appointments page
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text(
                    (snapshot.data!.get("First Name") +
                        " " +
                        snapshot.data!.get("Last Name")),
                    style: TextStyle(fontSize: 18),
                  ),
                  trailing: CircleAvatar(
                    backgroundImage:
                        NetworkImage(snapshot.data?.get("Profile Photo")),
                    radius: 32,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(dateOfAppointment)
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.watch_later_outlined,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(timeOfappointment),
                      ],
                    ),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: statusOfAppointment == "Confirmed"
                              ? Colors.green
                              : statusOfAppointment == "Pending"
                                  ? Colors.amber
                                  : Colors.red,
                          radius: 6,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text(statusOfAppointment)
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
