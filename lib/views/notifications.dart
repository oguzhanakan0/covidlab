import 'dart:convert';

import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/notifCard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';

class NotificationsView extends StatefulWidget {
  NotificationsView({Key? key}) : super(key: key);

  @override
  _NotificationsViewState createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  UserRepository? userRepository;

  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onAfterBuild(context));
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    return Scaffold(
        appBar: CupertinoNavigationBar(
          middle: Text('Notifications'),
        ),
        body: SafeArea(
            child: ListView(children: [
          Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(children: [
                Column(
                    children: List.generate(
                  userRepository!.notifs.length,
                  (index) {
                    return NotifCard(notif: userRepository!.notifs[index]);
                  },
                )),
              ])),
        ])));
  }

  onAfterBuild(BuildContext context) async {
    for (dynamic notif in userRepository?.notifs) {
      if (notif['date_read'] == null) {
        print("There are unread notifications. Reading them...");
        await readNotifs();
        break;
      }
    }
  }

  readNotifs() async {
    // setState(() {
    //   _loadingNotifs = true;
    // });
    Response r = await sendPost(
        url: READ_NOTIFS_URL,
        headers: {"Authorization": "Token " + userRepository!.dbToken!},
        body: {});

    print(r.statusCode);
    print(r.body);

    if (r.statusCode != 200) {
      // setState(() {
      //   _loadingNotifsError = true;
      // });
    } else {
      // setState(() {
      //   _loadingNotifsError = false;
      // });
    }

    // setState(() {
    //   _loadingNotifs = false;
    // });
  }
}
