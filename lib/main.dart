import 'package:covidlab/services/loginmethods.dart';
import 'package:covidlab/widgets/emailSigninWidget.dart';
import 'package:covidlab/widgets/emailSignupWidget.dart';
import 'package:covidlab/widgets/signinWidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:covidlab/views/entrance.dart';
import 'package:covidlab/views/index.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CovidLab());
}

class CovidLab extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserRepository.instance(),
      child: Consumer(builder: (context, UserRepository userRepository, _) {
        return MaterialApp(
          title: 'CovidLab',
          home: Entrance(),
          routes: <String, WidgetBuilder>{
            "/email-signup": (context) => EmailSignup(),
            "/email-signin": (context) => EmailSignin(),
          },
        );
      }),
    );
  }
}
