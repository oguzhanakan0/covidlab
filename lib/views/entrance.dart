// import 'package:digimobile/constants/global_variables.dart';
// import 'package:digimobile/services/post.dart';
import 'package:flutter/material.dart';

class Entrance extends StatefulWidget {
  Entrance({Key? key}) : super(key: key);
  @override
  _EntranceState createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> {
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) => onAfterBuild(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(
            image: AssetImage('assets/img/logo.png'),
            width: 72,
            height: 72,
          ),
          Text(
            'CovidLab',
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }

  onAfterBuild(BuildContext context) async {
    // TODO: IMPLEMENT APP INITIALIZATION HERE
    // appConfig = await getConfig();
    // if (appConfig==null) print('cant retrieve config. somethings wrong');
    // print(appConfig);
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/index', (Route<dynamic> route) => false);
    });
  }
}
