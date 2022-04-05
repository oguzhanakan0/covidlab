import 'dart:convert';
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

class MakePayment extends StatefulWidget {
  MakePayment({Key? key, required this.appointment}) : super(key: key);
  final dynamic appointment;

  @override
  _MakePaymentState createState() => _MakePaymentState();
}

class _MakePaymentState extends State<MakePayment> {
  final _formKey = GlobalKey<FormState>();
  final f = DateFormat('EEE, MMM d, yyyy h:mm a');
  DateTime? date;
  dynamic selectedLocation;

  bool _submitting = false;
  bool _initializing = false;
  bool _calendarVisible = false;
  Appointment? _selectedAppointment;
  List<CupertinoActionSheetAction>? locations;
  dynamic appts;
  UserRepository? userRepository;

  void initState() {
    super.initState();
    selectedLocation = widget.appointment["location"];
    _selectedAppointment = Appointment(
        startTime: DateTime.parse(widget.appointment["test_date"]),
        endTime: DateTime.parse(widget.appointment["test_date"])
            .add(Duration(minutes: 15)));
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
    userRepository = Provider.of<UserRepository>(context);
    return ClipRRect(
        borderRadius: BorderRadius.circular(40.0),
        child: Scaffold(
          bottomNavigationBar: Padding(
              padding:
                  EdgeInsets.only(top: 8, left: 24, bottom: 24.0, right: 24),
              child: Row(
                children: [
                  Expanded(
                      child: CupertinoButton(
                          color: Colors.green,
                          disabledColor: Colors.grey.shade600,
                          child: Text("Submit Payment"),
                          onPressed: _submitting
                              ? null
                              : () async {
                                  setState(() {
                                    _submitting = true;
                                  });

                                  Response r = await sendPost(
                                      url: MAKE_PAYMENT_URL,
                                      headers: {
                                        "Content-type": "application/json",
                                        "Authorization":
                                            "Token " + userRepository!.dbToken!
                                      },
                                      body: {
                                        "test_id": widget.appointment["id"]
                                      });
                                  print(r.statusCode);
                                  print(r.body);
                                  dynamic response = json.decode(r.body);

                                  if (r.statusCode != 200) {
                                    Navigator.of(context).restorablePush(
                                        _dialogBuilder,
                                        arguments: {
                                          "title": "Oops",
                                          "content": response["detail"],
                                          "popCount": 1
                                        });
                                  } else {
                                    print(userRepository!.appointments);
                                    Navigator.of(context).restorablePush(
                                        _dialogBuilder,
                                        arguments: {
                                          "title": "Success",
                                          "content": "Payment was successful.",
                                          "popCount": 2,
                                          "result": true
                                        });
                                  }

                                  setState(() {
                                    _submitting = false;
                                  });
                                })),
                  _submitting
                      ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: SizedBox(
                            child: CircularProgressIndicator(),
                            width: 24,
                            height: 24,
                          ))
                      : SizedBox.shrink()
                ],
              )),
          appBar: CupertinoNavigationBar(
            automaticallyImplyLeading: false,
            middle: Text('Make Payment'),
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
                                vertical: 24.0, horizontal: 24.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      child: Text(
                                    'Please enter your card details and tap on Make Payment button.',
                                    style:
                                        Theme.of(context).textTheme.subtitle1,
                                  )),
                                  SizedBox(
                                    height: 12.0,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    child: Column(children: [
                                      TextFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          labelText: 'Name on Card',
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(
                                        height: 12.0,
                                      ),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          labelText: 'Card Number',
                                        ),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                      SizedBox(
                                        height: 12.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 64.0,
                                                height: 56.0,
                                                child: TextFormField(
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    labelText: 'MM',
                                                  ),
                                                  onChanged: (value) {
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              SizedBox(
                                                width: 12.0,
                                                child: Text(
                                                  "/",
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              SizedBox(
                                                  width: 64.0,
                                                  height: 56.0,
                                                  child: TextFormField(
                                                    decoration: InputDecoration(
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.0),
                                                      ),
                                                      labelText: 'YY',
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {});
                                                    },
                                                  ))
                                            ],
                                          ),
                                          SizedBox(
                                              width: 64.0,
                                              height: 56.0,
                                              child: TextFormField(
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  labelText: 'CVV',
                                                ),
                                                onChanged: (value) {
                                                  setState(() {});
                                                },
                                              )),
                                        ],
                                      )
                                    ]),
                                  ),
                                  SizedBox(
                                    height: 36.0,
                                  ),
                                  Text(
                                    "Order Summary",
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  Divider(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "1x COVID-19 Testing Appointment",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        "3.99",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Tax",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        ".39",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    indent: 280,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Total",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                      ),
                                      Text(
                                        "\$4.38",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  Text(
                                    "Cancellations should be made at most 24 hours prior to the appointment. There is no cancellation fee, however, no-show is not refundable. You may change the date of your appointment without extra fee.",
                                    style: Theme.of(context).textTheme.caption,
                                  )
                                ]))),
                  ]),
          ),
        ));
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
                  for (int i = 0; i < (arguments!["popCount"] ?? 1); i++) {
                    Navigator.of(context).pop(arguments!["result"]);
                  }
                })
          ],
        );
      },
    );
  }
}
