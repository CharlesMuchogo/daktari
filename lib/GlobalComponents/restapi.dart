// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RestApi {
  final FirebaseFirestore _fire = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> createData(String firstName, String lastName, String email,
      String phoneNumber, String license, String curentHospital) async {
    final User? user = _auth.currentUser;
    final uid = user?.uid;

    await _fire.collection("Doctor").doc(uid).set(
      {
        "id": uid,
        "First Name": firstName,
        "Last Name": lastName,
        "License Number": license,
        "Current Hospital": curentHospital,
        "Email": email,
        "Phone Number": phoneNumber,
        "Profile Photo":
            "https://firebasestorage.googleapis.com/v0/b/matibabu-1254d.appspot.com/o/images%2Femptyprofile.png?alt=media&token=288629bd-5959-4bf0-8c92-8b2709c4fbb4",
      },
    );
    return "Signup successful";
  }

  Future<void> readData() async {
    final User? user = _auth.currentUser;
    final uid = user?.uid;
    var userDetailsList = [];

    final DocumentSnapshot docs =
        await _fire.collection("Patient").doc(uid).get();

    String name = docs.get("Email");
    String phoneNumber = docs.get("Phone Number");

    userDetailsList.add({"Email": name, "Phone Number": phoneNumber});

    return userDetailsList[0];
  }

  Future<String> cancelAppointments(String appointmentId) async {
    try {
      await _fire.collection("Appointment").doc(appointmentId).delete();
      return "Deleted successfuly";
    } on FirebaseFirestore catch (e) {
      return e.toString();
    }
  }

  Future<String> bookAppointment(
    String specialty,
    String time,
    String date,
    String address,
  ) async {
    final User? user = _auth.currentUser;

    final uid = user?.uid;

    await _fire.collection("Appointments").doc().set(
      {
        "Patient Id": uid,
        "Date": date,
        "Time": time,
        "Consultation": specialty,
        "Address": address,
      },
    );
    return "You have booked successfully";
  }
}
