// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:daktari/GlobalComponents/restapi.dart';

class profile extends StatefulWidget {
  @override
  State<profile> createState() => _profileState();
}

class _profileState extends State<profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RestApi info = RestApi();

  bool isSwitched = false;

  var textValue = 'Switch is OFF';

  var imageFile;

  var imageUrl;

  _pickfromGallery(String imagename) async {
    var pictureFile = await ImagePicker.platform
        .getImageFromSource(source: ImageSource.gallery);

    setState(() {
      imageFile = File(pictureFile!.path);
    });
    final _firebasestorage = FirebaseStorage.instance;

    if (imageFile != null) {
      //Upload to Firebase
      var snapshot = await _firebasestorage
          .ref()
          .child('images/{$imagename}')
          .putFile(imageFile);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });
      FirebaseFirestore.instance
          .collection("Doctor")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"Profile Photo": imageUrl});
    } else {
      print('No Image Path Received');
    }
  }

  _pickfromCamera(String imagename) async {
    var pictureFile = await ImagePicker.platform
        .getImageFromSource(source: ImageSource.camera);

    setState(() {
      imageFile = File(pictureFile!.path);
    });

    final _firebasestorage = FirebaseStorage.instance;
    if (imageFile != null) {
      //Upload to Firebase
      var snapshot = await _firebasestorage
          .ref()
          .child('images/$imagename')
          .putFile(imageFile);
      var downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
      });

      FirebaseFirestore.instance
          .collection("Doctor")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .update({"Profile Photo": imageUrl});
    } else {
      print('No Image Path Received');
    }
  }

  Widget displayImage(String profileUrl) {
    if (profileUrl == "") {
      return CircleAvatar(
        backgroundImage: AssetImage("assets/images/emptyprofile.png"),
        radius: 70,
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(profileUrl),
        radius: 70,
      );
    }
  }

  Future imagepickerdialogue(BuildContext context, String imageName) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose the image source"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                InkWell(
                  
                  onTap: () {
                    Navigator.of(context).pop(_pickfromGallery(imageName));
                  },
                  child: Text("Gallery"),
                ),
                Padding(padding: EdgeInsets.all(8)),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(_pickfromCamera(imageName));
                  },
                  child: Text("Camera"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  canceldialogue(BuildContext context) async {
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Do you want to Logout?"),
            actions: [
              MaterialButton(
                onPressed: null,
                child: Text("cancel"),
              )
            ],
          );
        });
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
      });
    } else {
      setState(() {
        isSwitched = false;
      });
    }
  }

  signOut() async {
    try {
      _auth.signOut();
    } on FirebaseAuth catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("Doctor")
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                SizedBox(
                  width: 25,
                ),
                displayImage(snapshot.data?.get("Profile Photo")),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: () {
                    imagepickerdialogue(context, snapshot.data?.get("Email"));
                  },
                  child: Icon(
                    Icons.camera_alt_outlined,
                    size: 30,
                    color: Colors.grey[700],
                  ),
                ),
              ]),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.data?.get("First Name"),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.02,
                  ),
                  Text(
                    snapshot.data?.get("Last Name"),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "User Information",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              SizedBox(
                height: 28,
              ),
              UserInfo(
                  "Email", snapshot.data?.get("Email"), Icons.email_outlined),
              UserInfo("Address", "Maasai Lodge", Icons.location_on_outlined),
              UserInfo(
                "Phone Number",
                snapshot.data?.get("Phone Number"),
                Icons.phone,
              ),
              Text(
                "User Settings",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal,
                    fontWeight: FontWeight.bold),
              ),
              Divider(
                color: Colors.black,
                thickness: 1,
              ),
              ListTile(
                leading: Icon(
                  Icons.dark_mode,
                  size: 30,
                ),
                title: Text('Dark Mode'),
                trailing: Switch(
                  onChanged: toggleSwitch,
                  value: isSwitched,
                  activeColor: Colors.black,
                  activeTrackColor: Colors.black54,
                  inactiveThumbColor: Colors.white54,
                  inactiveTrackColor: Colors.white,
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text("Do you want to Logout?"),
                        actions: [
                          MaterialButton(
                            elevation: 5,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "No",
                              style:
                                  TextStyle(color: Colors.teal, fontSize: 18),
                            ),
                          ),
                          MaterialButton(
                            elevation: 5,
                            onPressed: () {
                              Navigator.of(context).pop(signOut());
                            },
                            child: Text(
                              "Yes",
                              style: TextStyle(color: Colors.red, fontSize: 18),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
                child: ListTile(
                  title: Text('Logout'),
                  leading: Icon(
                    Icons.logout_outlined,
                    color: Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ],
          );
        });
  }
}

Widget UserInfo(String title, String subTitle, IconData icondata) {
  return Material(
    color: Colors.transparent,
    child: ListTile(
      leading: Icon(icondata),
      title: Text(title),
      subtitle: Text(subTitle),
    ),
  );
}
