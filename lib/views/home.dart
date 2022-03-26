import 'dart:convert';
import 'dart:ui';

import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool? _loading = true;
  bool? _loadingError = false;
  UserRepository? userRepository;
  List<dynamic> upcomingAppointments = [];
  List<dynamic> pastAppointments = [];

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onAfterBuild(context));
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    return Scaffold(
        appBar: CupertinoNavigationBar(
          leading: IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {},
          ),
          trailing: IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              {
                bool? refresh = await showModalBottomSheet<bool>(
                  useRootNavigator: true,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(40))),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return FractionallySizedBox(
                        heightFactor: 0.88, child: AddAppointment());
                  },
                );
                if (refresh!)
                  setState(() {
                    _loading = true;
                  });
              }
            },
          ),
          middle: Text('CovidLab'),
        ),
        body: _loading!
            ? _loadingError!
                ? Center(
                    child: TextButton(
                      child: Text("Reload"),
                      onPressed: () async {
                        setState(() {
                          _loading = true;
                        });
                        await loadHomePageData();
                      },
                    ),
                  )
                : CircularProgressIndicator()
            : SafeArea(
                child: ListView(children: [
                Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Column(children: [
                      Column(
                          children: List.generate(
                        upcomingAppointments.length,
                        (index) {
                          return upcomingAppointmentWidget(
                              upcomingAppointments[index]);
                        },
                      )),
                      Divider(
                        height: 50,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: CupertinoColors.systemGrey2,
                      ),
                      Column(
                          children: List.generate(
                        pastAppointments.length,
                        (index) {
                          return upcomingAppointmentWidget(
                              upcomingAppointments[index]);
                        },
                      ))
                    ])),
                // child: ListView(children: [
                //   Container(
                //       padding: EdgeInsets.all(24.0),
                //       child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             const Divider(
                //               height: 50,
                //               thickness: 1,
                //               indent: 0,
                //               endIndent: 0,
                //               color: CupertinoColors.systemGrey2,
                //             ),
                //             Container(
                //               width: MediaQuery.of(context).size.width,
                //               child: Card(
                //                 child: InkWell(
                //                   onTap: () {
                //                     print('Card tapped.');
                //                   },
                //                   // mainAxisSize: MainAxisSize.min,
                //                   child: Column(
                //                     children: [
                //                       ListTile(
                //                         leading: Icon(
                //                             Icons.access_time_filled_rounded),
                //                         title: Text('Past Test'),
                //                         subtitle: Text(
                //                           '10/02/2022 09:30 AM',
                //                           style: TextStyle(
                //                               color: Colors.black
                //                                   .withOpacity(0.6)),
                //                         ),
                //                       ),
                //                       // Row(
                //                       //   mainAxisAlignment: MainAxisAlignment.end,
                //                       //   children: <Widget>[
                //                       //     IconButton(
                //                       //         icon: const Icon(
                //                       //           CupertinoIcons.arrow_right_circle,
                //                       //           color: Colors.black,
                //                       //           size: 30,
                //                       //         ),
                //                       //         padding: const EdgeInsets.all(0),
                //                       //         onPressed: () {}
                //                       //     ),
                //                       //     const SizedBox(width: 8),
                //                       //   ],
                //                       // ),
                //                     ],
                //                   ),
                //                 ),
                //               ),
                //             ),
                //             SizedBox(
                //               height: 12.0,
                //             ),
                //           ]))
                // ]),
              ])
                // Text('homepage'),
                // onPressed: () {},
                ));
  }

  Widget upcomingAppointmentWidget(dynamic appointment) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(50),
            onTap: () {
              print('Card tapped.');
            },
            // shadowColor:Colors.grey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.access_time_rounded),
                  title: Text(appointment["location"]),
                  subtitle: Text(
                    appointment["test_date"],
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget pastAppointmentWidget(dynamic appointment) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Card(
          child: InkWell(
            splashColor: Colors.blue.withAlpha(50),
            onTap: () {
              print('Card tapped.');
            },
            // shadowColor:Colors.grey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.access_time_rounded),
                  title: Text('Upcoming Appointment'),
                  subtitle: Text(
                    '12/23/2023 10:30 AM',
                    style: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  onAfterBuild(BuildContext context) async {
    await loadHomePageData();
  }

  loadHomePageData() async {
    Response r = await sendGet(
        url: GET_APPOINTMENTS_URL,
        headers: {"Authorization": "Token " + userRepository!.dbToken!});

    print(r.statusCode);
    print(r.body);

    if (r.statusCode != 200) {
      setState(() {
        _loadingError = true;
      });
    } else {
      dynamic allAppointments = json.decode(r.body);

      print("appointments:");
      print(allAppointments);
      allAppointments.forEach((appointment) {
        if (DateTime.parse(appointment["test_date"]).isAfter(DateTime.now())) {
          upcomingAppointments.add(appointment);
        } else {
          pastAppointments.add(appointment);
        }
      });

      upcomingAppointments
          .sort((a, b) => a["test_date"].compareTo(b["test_date"]));
      pastAppointments.sort((a, b) => a["test_date"].compareTo(b["test_date"]));

      print("upcomingAppointments:");
      print(upcomingAppointments);

      print("pastAppointments:");
      print(pastAppointments);

      setState(() {
        _loadingError = false;
      });
    }

    setState(() {
      _loading = false;
    });
  }
}
