import 'dart:ui';

import 'package:covidlab/services/requests.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AddAppointment extends StatefulWidget {
  AddAppointment({Key? key}) : super(key: key);

  @override
  _AddAppointmentState createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  final _formKey = GlobalKey<FormState>();
  DateTime? date;
  DateTime? _appt_date;
  DateTime? _appt_time;
  final f = DateFormat('yyyy-MM-dd');
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: Text('Make Appointment'),
      ),
      body: SafeArea(
        child: ListView(children: [
          // StepProgressIndicator(
          //   totalSteps: 2,
          //   currentStep: 2,
          //   selectedColor: Colors.green,
          //   unselectedColor: Colors.grey.shade100,
          // ),
          Form(
              key: _formKey,
              child: Container(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width * .75,
                            child: Text(
                              'Please fill the form below to make an appointment.',
                              style: Theme.of(context).textTheme.subtitle1,
                            )),
                        SizedBox(
                          height: 12.0,
                        ),
                        CupertinoFormSection(
                            header: Text(
                                "1. Select the date and time for your appointment"),
                            children: [
                              SfCalendar(
                                minDate: DateTime.now(),
                                showDatePickerButton: true,
                                view: CalendarView.timelineMonth,
                                dataSource: _getDataSource(),
                                timeSlotViewSettings: TimeSlotViewSettings(
                                  timeIntervalHeight: 20,
                                  timeInterval: Duration(minutes: 15),
                                ),
                              ),
                            ]),
                        CupertinoFormSection(
                            header: Text(
                                "2. Select a location for your appointment"),
                            children: [
                              TextButton(
                                  onPressed: () {
                                    showCupertinoModalPopup<void>(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            CupertinoActionSheet(
                                              title: const Text(
                                                  'Select Testing Location'),
                                              message: const Text(
                                                  'Please select one of our locations from the list below.'),
                                              actions: <
                                                  CupertinoActionSheetAction>[
                                                CupertinoActionSheetAction(
                                                  child:
                                                      const Text('Action One'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                                CupertinoActionSheetAction(
                                                  child:
                                                      const Text('Action Two'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                )
                                              ],
                                            ));
                                  },
                                  child: Text("Pick location"))
                            ]),
                        CupertinoFormSection(
                            header: Text("3. Payment (Optional)"),
                            children: [
                              TextButton(
                                  child: Text("Make Payment"), onPressed: () {})
                            ]),
                        SizedBox(
                          height: 12.0,
                        ),
                        CupertinoButton.filled(
                            child: Text("Submit"),
                            onPressed: _loading
                                ? () {}
                                : () async {
                                    setState(() {
                                      _loading = true;
                                    });
                                    if (_formKey.currentState!.validate()) {
                                      print("form is valid!");
                                    }
                                    setState(() {
                                      _loading = false;
                                    });
                                  }),
                      ])))
        ]),
      ),
    );
  }

  _DataSource _getDataSource() {
    final List<Appointment> appointments = <Appointment>[];
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(hours: 4)),
      endTime: DateTime.now().add(Duration(hours: 5)),
      subject: 'Meeting',
      color: Colors.red,
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: -2, hours: 4)),
      endTime: DateTime.now().add(Duration(days: -2, hours: 5)),
      subject: 'Development Meeting   New York, U.S.A',
      color: Color(0xFFf527318),
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: -2, hours: 3)),
      endTime: DateTime.now().add(Duration(days: -2, hours: 4)),
      subject: 'Project Plan Meeting   Kuala Lumpur, Malaysia',
      color: Color(0xFFfb21f66),
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: -2, hours: 2)),
      endTime: DateTime.now().add(Duration(days: -2, hours: 3)),
      subject: 'Support - Web Meeting   Dubai, UAE',
      color: Color(0xFFf3282b8),
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(Duration(days: -2, hours: 1)),
      endTime: DateTime.now().add(Duration(days: -2, hours: 2)),
      subject: 'Project Release Meeting   Istanbul, Turkey',
      color: Color(0xFFf2a7886),
    ));
    appointments.add(Appointment(
        startTime: DateTime.now().add(const Duration(hours: 4, days: -1)),
        endTime: DateTime.now().add(const Duration(hours: 5, days: -1)),
        subject: 'Release Meeting',
        color: Colors.lightBlueAccent,
        isAllDay: true));
    appointments.add(Appointment(
      startTime: DateTime.now().add(const Duration(hours: 2, days: -4)),
      endTime: DateTime.now().add(const Duration(hours: 4, days: -4)),
      subject: 'Performance check',
      color: Colors.amber,
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(const Duration(hours: 11, days: -2)),
      endTime: DateTime.now().add(const Duration(hours: 12, days: -2)),
      subject: 'Customer Meeting   Tokyo, Japan',
      color: Color(0xFFffb8d62),
    ));
    appointments.add(Appointment(
      startTime: DateTime.now().add(const Duration(hours: 6, days: 2)),
      endTime: DateTime.now().add(const Duration(hours: 7, days: 2)),
      subject: 'Retrospective',
      color: Colors.purple,
    ));

    return _DataSource(appointments);
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
