import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/views/notifications.dart';
import 'package:covidlab/widgets/personalInfoWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covidlab/views/home.dart';
import 'package:covidlab/views/profile.dart';
import 'package:covidlab/widgets/emailSigninWidget.dart';
import 'package:covidlab/widgets/emailSignupWidget.dart';
import 'package:provider/provider.dart';

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
        "/": (context) => NotificationsView(),
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

  UserRepository? userRepository;
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onAfterBuild(context));
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notifications,
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
          ),
        ],
      ),
      tabBuilder: (BuildContext context, index) {
        return pages[index];
      },
    );
  }

  onAfterBuild(BuildContext context) async {
    if (!userRepository!.dbUser!["is_info_complete"]) {
      print("User's info not complete!: ");
      print(userRepository!.dbUser!);
      print("pushing complete info page..");
      // Navigator.of(context).pushNamed('/personal-information', arguments: {"user": userRepository});

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                PersonalInformationWidget(userRepository: userRepository!)),
      );
    }
  }
}
