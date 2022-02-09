import 'dart:io';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:covidlab/services/loginmethods.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SigninWidget extends StatefulWidget {
  SigninWidget();
  @override
  _SigninWidgetState createState() => _SigninWidgetState();
}

class _SigninWidgetState extends State<SigninWidget> {
  final _formKey = GlobalKey<FormState>();
  String? _password;
  String? _email;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserRepository>(context);
    return SafeArea(
        child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(
                'Sign In',
                style: Theme.of(context).textTheme.headline3,
              ),
              Text(
                'Please choose one of the options to sign in',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              Divider(
                indent: 48.0,
                endIndent: 48.0,
              ),
              SignInButton(
                Buttons.Google,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                text: "Continue with Google",
                onPressed: () async {
                  await user.signinWithGoogle();
                },
              ),
              if (Platform.isIOS)
                SignInButton(
                  Buttons.AppleDark,
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  text: "Continue with Apple",
                  onPressed: () async {
                    bool res = await user.signInWithApple();
                    print(res);
                  },
                ),
              SignInButton(
                Buttons.FacebookNew,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                text: "Continue with Facebook",
                onPressed: () async {
                  bool res = await user.signinWithFacebook();
                  print(res);
                },
              ),
              SignInButton(
                Buttons.Email,
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0)),
                text: "Continue with Email",
                onPressed: () {
                  Navigator.pushNamed(context, '/email-signup',
                      arguments: {'user': user});
                },
              ),
            ])));
  }
}
