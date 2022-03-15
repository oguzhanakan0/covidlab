import 'package:covidlab/views/add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covidlab/views/home.dart';
import 'package:covidlab/views/profile.dart';
import 'package:covidlab/widgets/emailSigninWidget.dart';
import 'package:covidlab/widgets/emailSignupWidget.dart';

class Index extends StatefulWidget {
  Index({Key? key}) : super(key: key);

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> {
  final List<Widget> pages = [
    CupertinoTabView(
      routes: {
        "/": (context) => Home(),
      },
    ),
    CupertinoTabView(
      routes: {
        "/": (context) => AddAppointment(),
      },
    ),
    CupertinoTabView(
      routes: {
        "/": (context) => Profile(),
        "/email-signup": (context) => EmailSignup(),
        "/email-signin": (context) => EmailSignin(),
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
              ),
              label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add,
            ),
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: 'Profile'),
        ],
      ),
      tabBuilder: (BuildContext context, index) {
        return pages[index];
      },
    );
  }
}
