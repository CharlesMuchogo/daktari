// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MySchedule extends StatefulWidget {
  const MySchedule({super.key});

  @override
  State<MySchedule> createState() => _MyScheduleState();
}

class _MyScheduleState extends State<MySchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("My Schedule"),
          centerTitle: true,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Container(
                color: Colors.teal,
                height: MediaQuery.of(context).size.height * 0.5,
                child: getschedule(),
              ),
            ),
            FloatingActionButton(onPressed: null, child: Icon(Icons.add)),
          ],
        ));
  }
}

Widget getschedule() {
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("My appointments")
          .orderBy("Date", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) => Container(
                  child: Text(snapshot.data!.docs[index].toString()),
                ));
      });
}
