import 'dart:convert';
import 'dart:ui';

import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/add.dart';
import 'package:covidlab/widgets/appointmentCard.dart';
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
  // List<dynamic> upcomingAppointments = [];
  // List<dynamic> pastAppointments = [];

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
                await showModalBottomSheet<bool>(
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
                ).then((value) => setState(() {}));
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
                        userRepository!.appointments.length,
                        (index) {
                          return AppointmentCard(
                              userRepository!.appointments[index]);
                        },
                      )),
                    ])),
              ])));
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
      print("userRepository!.appointments");
      print(userRepository!.appointments);

      allAppointments.sort((a, b) => DateTime.parse(a["test_date"])
              .isBefore(DateTime.parse(b["test_date"]))
          ? 1
          : 0);
      userRepository!.appointments = allAppointments;
      print("userRepository!.appointments:");
      print(userRepository!.appointments);

      setState(() {
        _loadingError = false;
      });
    }

    setState(() {
      _loading = false;
    });
  }
}
