// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daktari/pages/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

TextEditingController searchdoctorcontroler = TextEditingController();

class _SearchState extends State<Search> {
  @override
  void initState() {
    super.initState();
  }

  onSearch(String search) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Search Appointments"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Container(
                  height: 39,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(30),
                    ),
                    color: Color.fromARGB(246, 208, 203, 203),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: 300,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 30, right: 30),
                      child: TextField(
                        onChanged: (val) => onSearch(val),
                        controller: searchdoctorcontroler,
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            //labelText: 'Enter Name',
                            hintText: 'Search for a appointment'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: searchinfo(searchdoctorcontroler.text))
          ],
        ),
      ),
    );
  }
}

Widget searchinfo(String controler) {
  return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Doctor")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("My appointments")
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Oops, an error occured. please try again"),
          );
        }
        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text("No results found for your search"),
          );
        }

        return ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: Column(
                children: [
                  ...(snapshot.data!.docs
                      .where(
                    (QueryDocumentSnapshot<Object?> element) => element
                        .data()
                        .toString()
                        .toLowerCase()
                        .contains(controler.toLowerCase()),
                  )
                      .map(
                    (QueryDocumentSnapshot<Object?> data) {
                      return Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: 150,
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
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
                        child: infocards(
                            context,
                            data["Date"],
                            data["Patient Id"],
                            data["Time"],
                            data["Status"],
                            data["Time"],
                            data["Consultation"],
                            data.id),
                      );
                    },
                  )),
                ],
              ),
            ),
          ],
        );
      });
}
