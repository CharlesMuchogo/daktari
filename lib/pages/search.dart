// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController searchdoctorcontroler = TextEditingController();

  void _printLatestValue() {
    print("$searchdoctorcontroler.text");
  }

  @override
  void initState() {
    super.initState();

    searchdoctorcontroler.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    searchdoctorcontroler.dispose();
    super.dispose();
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
        padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: 39,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                      color: Color.fromRGBO(245, 242, 242, 10),
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
                          controller: searchdoctorcontroler,
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              //labelText: 'Enter Name',
                              hintText: 'Search for a appointment'),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      searchdoctorcontroler.text =
                          searchdoctorcontroler.text.trim();
                    });
                  },
                  icon: Icon(Icons.search),
                )
              ],
            ),
            searchinfo(searchdoctorcontroler.text)
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

        return SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                ...(snapshot.data!.docs
                    .where(
                  (QueryDocumentSnapshot<Object?> element) => element["Date"]
                      .toString()
                      .toLowerCase()
                      .contains(controler.toLowerCase()),
                )
                    .map(
                  (QueryDocumentSnapshot<Object?> data) {
                    return Container(
                      width: MediaQuery.of(context).size.width * 0.9,
                      height: MediaQuery.of(context).size.height * 0.1,
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
                      child: InkWell(
                        // onTap: () {
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) =>
                        //     ),
                        //   );
                        // },
                        child: ListTile(
                          title: Text(data["Date"]),
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        );
      });
}
