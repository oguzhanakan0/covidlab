import 'dart:convert';
import 'dart:ui';

import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/locationListTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class AddAppointment extends StatefulWidget {
  AddAppointment({Key? key}) : super(key: key);

  @override
  _AddAppointmentState createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  final _formKey = GlobalKey<FormState>();
  final f = DateFormat('EEE, MMM d, yyyy h:mm a');
  DateTime? date;
  dynamic selectedLocation;
  DateTime? _appt_date;
  DateTime? _appt_time;
  bool _loading = false;
  bool _initializing = true;
  bool _calendarLoading = false;
  Appointment? _selectedAppointment;
  List<CupertinoActionSheetAction>? locations;
  dynamic appts;

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onAfterBuild(context));
    // appts = _getDataSource(selectedLocation);
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails) {
    if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      final Appointment appointment = calendarTapDetails.appointments![0];
      setState(() {
        _selectedAppointment = appointment;
      });

      print(_selectedAppointment!.startTime);
    } else if (calendarTapDetails.targetElement ==
        CalendarElement.calendarCell) {
      setState(() {
        _selectedAppointment = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
        child: Scaffold(
          appBar: CupertinoNavigationBar(
            automaticallyImplyLeading: false,
            middle: Text('Make an Appointment'),
            trailing: IconButton(
                icon: Icon(Icons.cancel_outlined),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
          body: SafeArea(
            child: _initializing
                ? Center(child: CircularProgressIndicator())
                : ListView(children: [
                    Form(
                        key: _formKey,
                        child: Container(
                            padding: EdgeInsets.all(24.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          .75,
                                      child: Text(
                                        'Please fill the form below to make an appointment.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      )),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  CupertinoFormSection(
                                      header: Text(
                                          "1. Select a location for your appointment: "),
                                      children: [
                                        TextButton(
                                            onPressed: () async {
                                              final s =
                                                  await showCupertinoModalPopup(
                                                      barrierDismissible: false,
                                                      context: context,
                                                      builder: (BuildContext context) =>
                                                          CupertinoActionSheet(
                                                              cancelButton: CupertinoButton
                                                                  .filled(
                                                                      child: Text(
                                                                          "cancel"),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      }),
                                                              title: Text(
                                                                  'Select Testing Location'),
                                                              message: const Text(
                                                                  'Please select one of our locations from the list below.'),
                                                              actions:
                                                                  locations ??
                                                                      []));
                                              if (s != null) {
                                                setState(() {
                                                  _calendarLoading = true;
                                                  _selectedAppointment = null;
                                                });
                                                appts = await _getDataSource(s);
                                                setState(() {
                                                  _calendarLoading = false;
                                                });
                                              }
                                              if (s != null ||
                                                  (s == null &&
                                                      selectedLocation == null))
                                                setState(() {
                                                  selectedLocation = s;
                                                });
                                            },
                                            child: Text(selectedLocation != null
                                                ? selectedLocation!["name"]
                                                : "Pick location"))
                                      ]),
                                  CupertinoFormSection(
                                      header: Text(
                                          "2. Select the date and time for your appointment"),
                                      children: _calendarLoading
                                          ? [
                                              Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 24),
                                                  child:
                                                      CircularProgressIndicator())
                                            ]
                                          : selectedLocation == null
                                              ? [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 24),
                                                      child: Text(
                                                          "Please select a testing location first."))
                                                ]
                                              : [
                                                  SfCalendarTheme(
                                                    data: SfCalendarThemeData(
                                                      selectionBorderColor:
                                                          Colors.blue.shade800,
                                                    ),
                                                    child: SfCalendar(
                                                      specialRegions: [],
                                                      firstDayOfWeek:
                                                          DateTime.now()
                                                              .weekday,
                                                      maxDate: DateTime.now()
                                                          .add(Duration(
                                                              days: 14)),
                                                      onTap: calendarTapped,
                                                      minDate: DateTime.now(),
                                                      showDatePickerButton:
                                                          true,
                                                      view: CalendarView.week,
                                                      dataSource: appts,
                                                      initialDisplayDate:
                                                          DateTime.now(),
                                                      timeSlotViewSettings:
                                                          TimeSlotViewSettings(
                                                              timeIntervalHeight:
                                                                  120,
                                                              timeIntervalWidth:
                                                                  100,
                                                              timelineAppointmentHeight:
                                                                  300,
                                                              startHour: 8,
                                                              endHour: 17),
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8),
                                                      child:
                                                          _selectedAppointment ==
                                                                  null
                                                              ? Text(
                                                                  "No Selection",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .caption,
                                                                )
                                                              : Column(
                                                                  children: [
                                                                      Text(
                                                                        "You selected",
                                                                        style: Theme.of(context)
                                                                            .textTheme
                                                                            .caption,
                                                                      ),
                                                                      Text(f.format(
                                                                          _selectedAppointment!
                                                                              .startTime))
                                                                    ]))
                                                ]),
                                  // CupertinoFormSection(
                                  //     header: Text("3. Payment (Optional)"),
                                  //     children: [
                                  //       TextButton(
                                  //           child: Text("Make Payment"),
                                  //           onPressed: () {})
                                  //     ]),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  CupertinoButton(
                                      color: Colors.green,
                                      disabledColor: Colors.grey.shade600,
                                      child: Text("Submit"),
                                      onPressed: (_loading ||
                                              (selectedLocation == null ||
                                                  _selectedAppointment == null))
                                          ? null
                                          : () async {
                                              setState(() {
                                                _loading = true;
                                              });
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                print("form is valid!");
                                              }
                                              setState(() {
                                                _loading = false;
                                              });
                                            }),
                                ])))
                  ]),
          ),
        ));
  }

  Future<_DataSource?> _getDataSource(dynamic location) async {
    Response r = await sendGet(url: GET_BLACKOUT_SLOTS_URL + location["slug"]);
    dynamic response = json.decode(r.body);
    if (r.statusCode != 200) {
      Navigator.of(context).restorablePush(_dialogBuilder,
          arguments: {"message": response["message"]});
      return null;
    } else {
      dynamic blockoutSlots = response[0]["blackout_slots"];
      print(response[0]["blackout_slots"]);
      final List<Appointment> appointments = <Appointment>[];
      DateTime today = DateTime.now();
      for (int i = 0; i < 14; i++) {
        for (int j = 0; j < 32; j++) {
          int startHour = (8 + j / 4).toInt() + (j >= 16 ? 1 : 0);
          int startMinute = j % 4 * 15;
          if (i == 0 &&
              (startHour < today.hour ||
                  (startHour == today.hour && startMinute < today.minute))) {
            continue;
          }
          DateTime startTime = DateTime(
              today.year, today.month, today.day + i, startHour, startMinute);
          DateTime endTime = DateTime(today.year, today.month, today.day + i,
              startHour, startMinute + 14);
          if (blockoutSlots.length > 0 &&
              startTime
                  .toUtc()
                  .isAtSameMomentAs(DateTime.parse(blockoutSlots[0]))) {
            blockoutSlots.removeAt(0);
            continue;
          }
          appointments.add(Appointment(
            startTime: startTime,
            endTime: endTime,
            subject: startHour.toString() +
                ":" +
                (startMinute == 0 ? "00" : startMinute.toString()),
            color: Colors.blue.shade300,
          ));
        }
      }
      return _DataSource(appointments);
    }
  }

  onAfterBuild(BuildContext context) async {
    Response r = await sendGet(url: GET_LOCATIONS_URL);
    dynamic response = json.decode(r.body);
    if (r.statusCode != 200) {
      Navigator.of(context).restorablePush(_dialogBuilder,
          arguments: {"message": response["message"]});
    } else {
      dynamic devicePosition = await _determinePosition();
      if (devicePosition != null) {
        response.forEach((element) =>
            element["distance"] = getDistanceToDevice(devicePosition, element));
        response.sort((a, b) => getDistance(a).compareTo(getDistance(b)));
      }
      setState(() {
        locations = [];
        response.forEach((element) => locations?.add(CupertinoActionSheetAction(
              child: LocationListTile(element),
              onPressed: () {
                Navigator.pop(context, element);
              },
            )));
        _initializing = false;
      });
      print("locations are loaded");
    }
  }

  double getDistanceToDevice(Position devicePosition, location) {
    return Geolocator.distanceBetween(
            location["latitude"],
            location["longitude"],
            devicePosition.latitude,
            devicePosition.longitude) *
        0.000621371192;
  }

  double getDistance(dynamic location) {
    return location["distance"];
  }

  static Route<Object?> _dialogBuilder(
      BuildContext context, Object? arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Error'),
          content:
              Text('Could not fetch the appointment data. Please try again.'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).popUntil(ModalRoute.withName('/'));
                })
          ],
        );
      },
    );
  }

  Future<dynamic> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }
    return await Geolocator.getCurrentPosition();
  }
}

class _DataSource extends CalendarDataSource {
  _DataSource(List<Appointment> source) {
    appointments = source;
  }
}
