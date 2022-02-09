import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:covidlab/services/loginmethods.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:email_validator/email_validator.dart';

class EmailSignin extends StatefulWidget {
  EmailSignin({Key? key}) : super(key: key);
  @override
  _EmailSigninState createState() => _EmailSigninState();
}

class _EmailSigninState extends State<EmailSignin> {
  final _formKey = GlobalKey<FormState>();
  String? _password;
  String? _email;

  @override
  Widget build(BuildContext context) {
    UserRepository user =
        (ModalRoute.of(context)!.settings.arguments as Map)['user'];
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Sign In'),
      ),
      body: SafeArea(
        child: Form(
            key: _formKey,
            child: Container(
                padding: EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                      Text(
                        'Please enter your account information to sign in',
                        style: Theme.of(context).textTheme.subtitle1,
                      ),
                      SizedBox(
                        height: 12.0,
                      ),
                      CupertinoFormSection(children: [
                        CupertinoFormRow(
                            prefix: SizedBox(
                                width: 120, child: Text("Email address")),
                            child: CupertinoTextFormFieldRow(
                              onChanged: (value) {
                                setState(() {
                                  _email = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                } else if (!EmailValidator.validate(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              placeholder: 'oguzhan.akan@covidlab.com',
                            )),
                        CupertinoFormRow(
                            prefix:
                                SizedBox(width: 120, child: Text("Password")),
                            child: CupertinoTextFormFieldRow(
                              onChanged: (value) {
                                setState(() {
                                  _password = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                } else if (value.length < 6 ||
                                    value.length > 15) {
                                  return 'Password should be between 6-15 character';
                                }
                                return null;
                              },
                              obscureText: true,
                              placeholder: 'mySuperHardPassword',
                            )),
                      ]),
                      SizedBox(
                        height: 12.0,
                      ),
                      CupertinoButton.filled(
                          child: Text("Submit"),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              print('valid');
                              bool res = await user.signIn(_email!, _password!);
                              print(res);
                              if (res)
                                Navigator.pop(context);
                              else
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      new CupertinoAlertDialog(
                                    title: new Text("Cannot Sign In"),
                                    content: new Text(
                                        "Problem in signing in. Please re-enter your email and password, and try again."),
                                    actions: [
                                      CupertinoDialogAction(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          isDefaultAction: true,
                                          child: new Text("Close"))
                                    ],
                                  ),
                                );
                            }
                          }),
                      SizedBox(
                        height: 12.0,
                      ),
                      Row(children: [
                        Text(
                          'Having troubles signing in? ',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, '/email-signin',
                                  arguments: {"user": user});
                            },
                            child: Text(
                              'Reset your password',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle1!
                                  .copyWith(color: Colors.blue[700]),
                            )),
                      ]),
                    ]))),
      ),
    );
  }
}
