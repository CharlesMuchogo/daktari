// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:daktari/GlobalComponents/widgets.dart';
import 'package:daktari/theme/app_theme.dart';

import 'package:internationalization/internationalization.dart';
import 'package:daktari/GlobalComponents/restapi.dart';

class BookingsPage extends StatefulWidget {
  @override
  State<BookingsPage> createState() => _BookingsPageState();
  final String address;
  BookingsPage(this.address);
}

String _selectedDate = "";
String formatedTime = "";
String error = "Please fill in the details";
bool formfilled = true;

class _BookingsPageState extends State<BookingsPage> {
  Future<void> _openDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      helpText: "SELECT BOOKING DATE",
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (date != null) {
      setState(
        () {
          _selectedDate = DateFormat.yMMMd("en_US").format(date).toString();
        },
      );
    }
    //return _selectedDate;
  }

  TimeOfDay selectedTime = TimeOfDay.now();

  _selectTime(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null && timeOfDay != selectedTime) {
      setState(() {
        selectedTime = timeOfDay;
        formatedTime = "${selectedTime.hour}:${selectedTime.minute}";
      });
    }
  }

  void book() {
    if ((formatedTime.isEmpty) || (_selectedDate.isEmpty)) {
      setState(
        () {
          formfilled = false;
        },
      );
    } else {
      setState(() {
        formfilled = false;
      });

      RestApi restObject = RestApi();
      restObject.bookAppointment(
          _dropdownValue, formatedTime, _selectedDate, widget.address);

      final snackBar = SnackBar(
        content: const Text('Your Appointment was booked successfully!'),
        action: SnackBarAction(
          label: 'dismiss',
          onPressed: () {},
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  List<String> doctorSpecialties = [
    "Therapy",
    "Cardiology",
    "Gaenacology",
    "Neurology",
    "Dentist"
  ];

  String _dropdownValue = "Therapy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book an appointment")),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          if (!formfilled) ...[
            Text(
              error,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.w600),
            ),
            gap,
          ],
          DropdownButtonFormField<String>(
            initialValue: _dropdownValue,
            decoration: InputDecoration(
              labelText: "Type of appointment",
              prefixIcon: Icon(Icons.medical_services_outlined),
            ),
            onChanged: (value) {
              setState(() {
                _dropdownValue = value.toString();
              });
            },
            items: doctorSpecialties.map((String items) {
              return DropdownMenuItem(
                value: items,
                child: Text(items),
              );
            }).toList(),
          ),
          gap,
          Card(
            child: Column(
              children: [
                ListTile(
                  onTap: () => _openDatePicker(context),
                  leading: Icon(Icons.calendar_today_outlined),
                  title: Text("Date"),
                  trailing: Text(_selectedDate.isEmpty ? "Select" : _selectedDate),
                ),
                ListTile(
                  onTap: () => _selectTime(context),
                  leading: Icon(Icons.schedule_outlined),
                  title: Text("Time"),
                  trailing: Text(selectedTime.format(context)),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: book,
            child: Text("Book appointment"),
          )
        ],
      ),
    );
  }
}
