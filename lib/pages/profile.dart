// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously, avoid_print, prefer_typing_uninitialized_variables, camel_case_types, invalid_use_of_visible_for_testing_member, use_key_in_widget_constructors, non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:daktari/pages/updatedetails.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
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

  _pickImage(String imagename, ImageSource source, String specialty) async {
    var pictureFile =
        await ImagePicker.platform.getImageFromSource(source: source);

    final firebasestorage = FirebaseStorage.instance;

    if (pictureFile!.path.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          });
      var croppedImage = await ImageCropper.platform.cropImage(
        sourcePath: pictureFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
              toolbarColor: Colors.teal,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false)
        ],
        compressQuality: 100,
        maxHeight: 700,
        maxWidth: 700,
        compressFormat: ImageCompressFormat.jpg,
      );
      setState(() {
        imageFile = File(croppedImage!.path);
      });
      //Upload to Firebase
      var snapshot = await firebasestorage
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

      FirebaseFirestore.instance
          .collection("Doctor Cartegories")
          .doc(specialty)
          .collection("Doctors")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({"Profile Photo": imageUrl});

      Navigator.pop(context);
    } else {
      print('No Image Path Received');
    }
  }

  Widget displayImage(String profileUrl) {
    return CircleAvatar(
      backgroundImage: NetworkImage(profileUrl),
      radius: 85,
    );
  }

  Future imagepickerdialogue(
      BuildContext context, String imageName, String specialty) {
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
                    Navigator.of(context).pop(
                        _pickImage(imageName, ImageSource.gallery, specialty));
                  },
                  child: Text("Gallery"),
                ),
                Padding(padding: EdgeInsets.all(8)),
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop(
                        _pickImage(imageName, ImageSource.camera, specialty));
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
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Error!"),
              content: Text(
                e.toString(),
              ),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        centerTitle: true,
      ),
      body: StreamBuilder(
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

            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Stack(
                    children: [
                      displayImage(snapshot.data?.get("Profile Photo")),
                      Container(
                        margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.28,
                            top: MediaQuery.of(context).size.height * 0.125),
                        child: CircleAvatar(
                          backgroundColor: Colors.teal,
                          radius: 25,
                          child: InkWell(
                            onTap: () {
                              imagepickerdialogue(
                                  context,
                                  snapshot.data?.get("Email"),
                                  snapshot.data?.get("Email"));
                            },
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 25,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        snapshot.data?.get("First Name"),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.02,
                      ),
                      Text(
                        snapshot.data?.get("Last Name"),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
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
                    height: 20,
                  ),
                  Center(
                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(primary: Colors.grey[200]),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateDetails(
                                FirebaseAuth.instance.currentUser!.uid,
                                snapshot.data?.get("First Name"),
                                snapshot.data?.get("Last Name"),
                                snapshot.data?.get("Phone Number"),
                                snapshot.data?.get("Current Hospital"),
                                snapshot.data?.get("Description")),
                          ),
                        ); // navigate t
                      },
                      child: Text("Update your details",
                          style: TextStyle(color: Colors.black)),
                    ),
                  ),
                  UserInfo("Email", snapshot.data?.get("Email"),
                      Icons.email_outlined),
                  UserInfo(
                      "Current Hospital",
                      snapshot.data?.get("Current Hospital"),
                      Icons.location_on_outlined),
                  UserInfo(
                    "Phone Number",
                    snapshot.data?.get("Phone Number"),
                    Icons.phone,
                  ),
                  UserInfo("Description", snapshot.data?.get("Description"),
                      Icons.description_outlined),
                  // InkWell(
                  //   onTap: () {
                  //     Navigator.push(
                  //       context,
                  //       MaterialPageRoute(builder: (context) => MySchedule()),
                  //     );
                  //   },
                  //   child: UserInfo("Schedule", "click to edit your schedule",
                  //       Icons.schedule_outlined),
                  // ),

                  Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),

                  // ListTile(
                  //   leading: Icon(
                  //     Icons.dark_mode,
                  //     size: 30,
                  //   ),
                  //   title: Text('Dark Mode'),
                  //   trailing: Switch(
                  //     onChanged: toggleSwitch,
                  //     value: isSwitched,
                  //     activeColor: Colors.black,
                  //     activeTrackColor: Colors.black54,
                  //     inactiveThumbColor: Colors.white54,
                  //     inactiveTrackColor: Colors.white,
                  //   ),
                  // ),
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
                                  style: TextStyle(
                                      color: Colors.teal, fontSize: 18),
                                ),
                              ),
                              MaterialButton(
                                elevation: 5,
                                onPressed: () {
                                  Navigator.of(context).pop(signOut());
                                },
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 18),
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
              ),
            );
          }),
    );
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
