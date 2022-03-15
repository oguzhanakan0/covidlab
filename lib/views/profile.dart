import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/widgets/signedInWidget.dart';
import 'package:covidlab/widgets/signinWidget.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(child: SignedInWidget());
  }
}
