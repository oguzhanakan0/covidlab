// import 'package:digimobile/constants/global_variables.dart';
// import 'package:digimobile/services/post.dart';
import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/views/index.dart';
import 'package:covidlab/widgets/signinWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Entrance extends StatefulWidget {
  Entrance({Key? key}) : super(key: key);
  @override
  _EntranceState createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> {
  bool loading = false;
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (Provider.of<UserRepository>(context).status) {
      case Status.Unauthenticated:
        return SigninWidget();
      case Status.Authenticated:
        print("AUTHENTICATED\n\n");
        return MaterialApp(
          title: 'CovidLab',
          routes: <String, WidgetBuilder>{"/": (context) => Index()},
        );
      case Status.Authenticating:
      case Status.Uninitialized:
      default:
        return Scaffold(
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Image(
                    image: AssetImage('assets/img/logo.gif'),
                    width: 72,
                    height: 72,
                  ),
                  Text(
                    'CovidLab',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ]),
                SizedBox(
                  height: 200,
                ),
                CircularProgressIndicator()
              ])),
        );
    }
  }
}
