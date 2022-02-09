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
    return CupertinoPageScaffold(
        child: ChangeNotifierProvider(
      create: (_) => UserRepository.instance(),
      child: Consumer(
        builder: (context, UserRepository userRepository, _) {
          switch (userRepository.status) {
            case Status.Uninitialized:
              return Center(child: CircularProgressIndicator());
            case Status.Unauthenticated:
              return SigninWidget();
            case Status.Authenticating:
              return Center(child: CircularProgressIndicator());
            case Status.Authenticated:
              print(userRepository.dbUser!);
              return SignedInWidget(
                  userRepository: userRepository); // user.user
            default:
              return Center(child: Text('uninitalized'));
          }
        },
      ),
    ));
  }
}
