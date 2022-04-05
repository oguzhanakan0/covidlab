import 'dart:convert';
import 'package:covidlab/widgets/makePayment.dart';
import 'package:url_launcher/link.dart';
import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/locationListTile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageAppointment extends StatefulWidget {
  ManageAppointment({Key? key, required this.appointment}) : super(key: key);
  final dynamic appointment;

  @override
  _ManageAppointmentState createState() => _ManageAppointmentState();
}

class _ManageAppointmentState extends State<ManageAppointment> {
  final _formKey = GlobalKey<FormState>();
  final f = DateFormat('EEE, MMM d, yyyy h:mm a');
  DateTime? _paymentDate;
  dynamic selectedLocation;

  bool _submitting = false;
  bool _initializing = true;
  bool _calendarLoading = false;
  bool _calendarVisible = false;
  bool _submittingCancel = false;
  Appointment? _selectedAppointment;
  List<CupertinoActionSheetAction>? locations;
  dynamic appts;
  UserRepository? userRepository;

  void initState() {
    super.initState();
    selectedLocation = widget.appointment["location"];
    _paymentDate = widget.appointment["payment_date"] == null
        ? null
        : DateTime.parse(widget.appointment["payment_date"]).toLocal();
    _selectedAppointment = Appointment(
        startTime: DateTime.parse(widget.appointment["test_date"]).toLocal(),
        endTime: DateTime.parse(widget.appointment["test_date"])
            .add(Duration(minutes: 15))
            .toLocal());

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
      // setState(() {
      //   _selectedAppointment = null;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    return ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
        child: _initializing
            ? Center(child: CircularProgressIndicator())
            : Scaffold(
                bottomNavigationBar: Padding(
                  padding: EdgeInsets.only(
                      top: 8, left: 24, bottom: 24.0, right: 24),
                  child: Container(
                      height: 120.0,
                      child: Column(children: [
                        Row(
                          children: [
                            Expanded(
                                child: CupertinoButton(
                                    color: Colors.green,
                                    disabledColor: Colors.grey.shade600,
                                    child: Text("Update Appointment"),
                                    onPressed: (_submitting ||
                                            (selectedLocation == null ||
                                                _selectedAppointment == null) ||
                                            (selectedLocation ==
                                                    widget.appointment[
                                                        "location"] &&
                                                (_selectedAppointment != null &&
                                                    _selectedAppointment!
                                                        .startTime
                                                        .isAtSameMomentAs(
                                                            DateTime.parse(widget
                                                                    .appointment[
                                                                "test_date"])))))
                                        ? null
                                        : () async {
                                            setState(() {
                                              _submitting = true;
                                            });
                                            if (_formKey.currentState!
                                                .validate()) {
                                              String testDate =
                                                  _selectedAppointment!
                                                      .startTime
                                                      .toUtc()
                                                      .toString();
                                              print("form is valid!");
                                              print(userRepository!.dbToken);
                                              Map<String, String> _appointment =
                                                  {
                                                "test_id":
                                                    widget.appointment["id"],
                                                "test_date": testDate,
                                                "location":
                                                    selectedLocation!["slug"],
                                              };
                                              Response r = await sendPost(
                                                  url: UPDATE_APPOINTMENT_URL,
                                                  headers: {
                                                    "Content-type":
                                                        "application/json",
                                                    "Authorization": "Token " +
                                                        userRepository!.dbToken!
                                                  },
                                                  body: _appointment);
                                              print(r.statusCode);
                                              print(r.body);
                                              dynamic response =
                                                  json.decode(r.body);

                                              setState(() {
                                                _submitting = false;
                                              });
                                              if (r.statusCode != 200) {
                                                Navigator.of(context)
                                                    .restorablePush(
                                                        _dialogBuilder,
                                                        arguments: {
                                                      "title": "Oops",
                                                      "content":
                                                          response["detail"]
                                                    });
                                              } else {
                                                userRepository!.appointments[
                                                            widget.appointment[
                                                                "index"]]
                                                        ["location"] =
                                                    selectedLocation;

                                                userRepository!.appointments[
                                                        widget.appointment[
                                                            "index"]]
                                                    ["test_date"] = testDate;

                                                print(userRepository!
                                                    .appointments);
                                                Navigator.of(context)
                                                    .restorablePush(
                                                        _dialogBuilder,
                                                        arguments: {
                                                      "title": "Success",
                                                      "content":
                                                          "Your appointment has been updated.",
                                                    });
                                              }
                                            }

                                            setState(() {
                                              _submitting = false;
                                            });
                                          })),
                            _submitting
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: SizedBox(
                                      child: CircularProgressIndicator(),
                                      width: 24,
                                      height: 24,
                                    ))
                                : SizedBox.shrink()
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 24.0),
                                    child: TextButton(
                                      child: Text("Cancel Appointment"),
                                      onPressed: _submittingCancel
                                          ? null
                                          : () async {
                                              setState(() {
                                                _submittingCancel = true;
                                              });

                                              Response r = await sendPost(
                                                  url: CANCEL_APPOINTMENT_URL,
                                                  headers: {
                                                    "Content-type":
                                                        "application/json",
                                                    "Authorization": "Token " +
                                                        userRepository!.dbToken!
                                                  },
                                                  body: {
                                                    "test_id":
                                                        widget.appointment["id"]
                                                  });
                                              print(r.statusCode);
                                              print(r.body);
                                              dynamic response =
                                                  json.decode(r.body);

                                              if (r.statusCode != 200) {
                                                Navigator.of(context)
                                                    .restorablePush(
                                                        _dialogBuilder,
                                                        arguments: {
                                                      "title": "Oops",
                                                      "content":
                                                          response["detail"],
                                                      "popCount": 1
                                                    });
                                              } else {
                                                print(userRepository!
                                                    .appointments);
                                                userRepository!.appointments[
                                                        widget.appointment[
                                                            "index"]]
                                                    ["canceled"] = true;
                                                print(userRepository!
                                                    .appointments);

                                                Navigator.of(context)
                                                    .restorablePush(
                                                        _dialogBuilder,
                                                        arguments: {
                                                      "title": "Success",
                                                      "content":
                                                          "Appointment was canceled.",
                                                      "popCount": 1,
                                                      "result": true
                                                    });
                                              }

                                              setState(() {
                                                _submittingCancel = false;
                                              });
                                            },
                                    ))),
                            _submittingCancel
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 6),
                                    child: SizedBox(
                                      child: CircularProgressIndicator(),
                                      width: 12,
                                      height: 12,
                                    ))
                                : SizedBox.shrink()
                          ],
                        )
                      ])),
                ),
                appBar: CupertinoNavigationBar(
                  automaticallyImplyLeading: false,
                  middle: Text('Appointment Details'),
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
                                  padding: EdgeInsets.symmetric(
                                      vertical: 24.0,
                                      horizontal:
                                          _calendarVisible ? 24.0 : 72.0),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Please find your appointment details below. To make a change, tap on the related buttons.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .subtitle1,
                                        ),
                                        SizedBox(
                                          height: 12.0,
                                        ),
                                        CupertinoFormSection(
                                            header: Text("Appointment Details"),
                                            children: [
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextButton(
                                                      onPressed: () async {
                                                        final s = await showCupertinoModalPopup(
                                                            barrierDismissible: false,
                                                            context: context,
                                                            builder: (BuildContext context) => CupertinoActionSheet(
                                                                cancelButton: CupertinoButton.filled(
                                                                    child: Text("Cancel"),
                                                                    onPressed: () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    }),
                                                                title: Text('Select Testing Location'),
                                                                message: const Text('Please select one of our locations from the list below.'),
                                                                actions: locations ?? []));
                                                        if (s != null) {
                                                          setState(() {
                                                            _calendarLoading =
                                                                true;
                                                            _selectedAppointment =
                                                                null;
                                                          });
                                                          appts =
                                                              await _getDataSource(
                                                                  s);
                                                          setState(() {
                                                            _calendarLoading =
                                                                false;
                                                            _calendarVisible =
                                                                true;
                                                          });
                                                        }
                                                        if (s != null ||
                                                            (s == null &&
                                                                selectedLocation ==
                                                                    null))
                                                          setState(() {
                                                            selectedLocation =
                                                                s;
                                                          });
                                                      },
                                                      child: Row(children: [
                                                        Icon(CupertinoIcons
                                                            .map_pin_ellipse),
                                                        SizedBox(
                                                          width: 12,
                                                        ),
                                                        Text(selectedLocation ==
                                                                null
                                                            ? "Pick location"
                                                            : selectedLocation![
                                                                "name"])
                                                      ]),
                                                    ),
                                                    Link(
                                                      uri: Uri.parse(
                                                          selectedLocation![
                                                              "url"]),
                                                      builder: (BuildContext
                                                              context,
                                                          Future<void>
                                                                  Function()?
                                                              followLink) {
                                                        return TextButton(
                                                          onPressed: followLink,
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                  CupertinoIcons
                                                                      .map),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              Flexible(
                                                                  child: Text(
                                                                selectedLocation![
                                                                    "address"],
                                                              ))
                                                            ],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          launch("tel://" +
                                                              selectedLocation![
                                                                  "contact_no"]);
                                                        },
                                                        child: Row(children: [
                                                          Icon(CupertinoIcons
                                                              .phone_circle),
                                                          SizedBox(
                                                            width: 12,
                                                          ),
                                                          Text(
                                                              selectedLocation![
                                                                  "contact_no"])
                                                        ])),
                                                    _calendarLoading
                                                        ? Padding(
                                                            padding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            24),
                                                            child: Center(
                                                                child:
                                                                    CircularProgressIndicator()))
                                                        : selectedLocation ==
                                                                null
                                                            ? Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            24),
                                                                child: Text(
                                                                    "Please select a testing location first."))
                                                            : Visibility(
                                                                visible:
                                                                    _calendarVisible,
                                                                child:
                                                                    SfCalendarTheme(
                                                                  data:
                                                                      SfCalendarThemeData(
                                                                    selectionBorderColor:
                                                                        Colors
                                                                            .blue
                                                                            .shade800,
                                                                  ),
                                                                  child:
                                                                      SfCalendar(
                                                                    specialRegions: [],
                                                                    firstDayOfWeek:
                                                                        DateTime.now()
                                                                            .weekday,
                                                                    maxDate: DateTime
                                                                            .now()
                                                                        .add(Duration(
                                                                            days:
                                                                                14)),
                                                                    onTap:
                                                                        calendarTapped,
                                                                    minDate:
                                                                        DateTime
                                                                            .now(),
                                                                    showDatePickerButton:
                                                                        true,
                                                                    view: CalendarView
                                                                        .week,
                                                                    dataSource:
                                                                        appts,
                                                                    initialDisplayDate:
                                                                        DateTime
                                                                            .now(),
                                                                    timeSlotViewSettings: TimeSlotViewSettings(
                                                                        timeIntervalHeight:
                                                                            120,
                                                                        timeIntervalWidth:
                                                                            100,
                                                                        timelineAppointmentHeight:
                                                                            300,
                                                                        startHour:
                                                                            8,
                                                                        endHour:
                                                                            17),
                                                                  ),
                                                                )),
                                                    Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical:
                                                                    _calendarVisible
                                                                        ? 8
                                                                        : 0),
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
                                                                : TextButton(
                                                                    child: Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Icon(CupertinoIcons
                                                                              .calendar_today),
                                                                          SizedBox(
                                                                            width:
                                                                                12,
                                                                          ),
                                                                          Flexible(
                                                                              child: Text(f.format(_selectedAppointment!.startTime)))
                                                                        ]),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        _calendarVisible =
                                                                            !_calendarVisible;
                                                                      });
                                                                    },
                                                                  )),
                                                    _paymentDate != null
                                                        ? TextButton(
                                                            onPressed: () {},
                                                            child: Row(
                                                              children: [
                                                                Icon(
                                                                  CupertinoIcons
                                                                      .check_mark_circled_solid,
                                                                  color: Colors
                                                                      .green
                                                                      .shade400,
                                                                ),
                                                                SizedBox(
                                                                  width: 12,
                                                                ),
                                                                Flexible(
                                                                    child: Text(
                                                                        "Payment made\n" +
                                                                            f.format(_paymentDate!)))
                                                              ],
                                                            ))
                                                        : TextButton(
                                                            onPressed:
                                                                () async {
                                                              {
                                                                await showModalBottomSheet<
                                                                    bool>(
                                                                  useRootNavigator:
                                                                      true,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.vertical(
                                                                              top: Radius.circular(40))),
                                                                  isScrollControlled:
                                                                      true,
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
                                                                          context) {
                                                                    return FractionallySizedBox(
                                                                        heightFactor:
                                                                            0.77,
                                                                        child: MakePayment(
                                                                            appointment:
                                                                                widget.appointment));
                                                                  },
                                                                ).then(
                                                                    (value) async {
                                                                  setState(() {
                                                                    if (value ??
                                                                        false) {
                                                                      _paymentDate =
                                                                          DateTime
                                                                              .now();
                                                                      userRepository
                                                                              ?.appointments![
                                                                          widget
                                                                              .appointment["index"]]["payment_date"] = _paymentDate!
                                                                          .toUtc()
                                                                          .toString();
                                                                    }
                                                                  });
                                                                });
                                                              }
                                                            },
                                                            child:
                                                                Row(children: [
                                                              Icon(
                                                                  CupertinoIcons
                                                                      .creditcard,
                                                                  color: Colors
                                                                      .amber
                                                                      .shade800),
                                                              SizedBox(
                                                                width: 12,
                                                              ),
                                                              Text(
                                                                "Payment Awaiting",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .amber
                                                                        .shade800),
                                                              )
                                                            ]))
                                                  ])
                                            ]),
                                        SizedBox(
                                          height: 48,
                                        ),
                                      ]))),
                        ]),
                ),
              ));
  }

  Future<_DataSource?> _getDataSource(dynamic location) async {
    Response r = await sendGet(url: GET_BLACKOUT_SLOTS_URL + location["slug"]);
    dynamic response = json.decode(r.body);
    if (r.statusCode != 200) {
      Navigator.of(context).restorablePushAndRemoveUntil(
          _dialogBuilder, ModalRoute.withName('/'),
          arguments: {"message": response["message"]});
      return null;
    } else {
      dynamic blockoutSlots = response[0]["blackout_slots"];

      response[0]["blackout_slots"]..sort();
      // print(response[0]["blackout_slots"]);
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
      locations = [];
      response.forEach((element) => locations?.add(CupertinoActionSheetAction(
            child: LocationListTile(element),
            onPressed: () {
              Navigator.pop(context, element);
            },
          )));
      appts = await _getDataSource(selectedLocation);
      setState(() {
        _initializing = false;
      });
      print("locations are loaded");
    }
    setState(() {
      _initializing = false;
    });
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
      BuildContext context, dynamic arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(arguments!["title"] ?? 'Error'),
          content: Text(arguments!["content"] ??
              'Could not fetch the appointment data. Please try again.'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  // Navigator.of(context).pop(); // TODO: DISABLE LATER

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/')); // TODO: ENABLE LATER
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
