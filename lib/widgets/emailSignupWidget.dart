import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:covidlab/services/loginmethods.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:email_validator/email_validator.dart';

class EmailSignup extends StatefulWidget {
  EmailSignup({Key? key}) : super(key: key);
  @override
  _EmailSignupState createState() => _EmailSignupState();
}

class _EmailSignupState extends State<EmailSignup> {
  final _formKey = GlobalKey<FormState>();
  String? _password;
  String? _email;

  @override
  Widget build(BuildContext context) {
    UserRepository user =
        (ModalRoute.of(context)!.settings.arguments as Map)['user'];
    return Scaffold(
      appBar: CupertinoNavigationBar(
        middle: Text('Sign Up'),
      ),
      body: SafeArea(
          child:
              // Column(children: [
              // StepProgressIndicator(
              //   totalSteps: 2,
              //   currentStep: 1,
              //   selectedColor: Colors.green,
              //   unselectedColor: Colors.grey.shade100,
              // ),
              Form(
                  key: _formKey,
                  child: Container(
                      padding: EdgeInsets.all(24.0),
                      child: ListView(children: [
                        Text(
                          'Sign Up',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        Text(
                          'Quisque dolor lacus, dapibus ut volutpat sodales, pulvinar quis tortor.',
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                        SizedBox(
                          height: 12.0,
                        ),
                        CupertinoFormSection(
                            header: Text("Account Information"),
                            children: [
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
                                      } else if (!EmailValidator.validate(
                                          value)) {
                                        return 'Please enter a valid email address';
                                      }
                                      return null;
                                    },
                                    placeholder: 'oguzhan.akan@gmail.com',
                                  )),
                              CupertinoFormRow(
                                  prefix: SizedBox(
                                      width: 120, child: Text("Password")),
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
                              CupertinoFormRow(
                                  prefix: SizedBox(
                                      width: 120,
                                      child: Text("Confirm Password")),
                                  child: CupertinoTextFormFieldRow(
                                    validator: (value) {
                                      if (value != _password) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                    obscureText: true,
                                    placeholder: 'mySuperHardPassword',
                                  )),
                            ]),
                        // CupertinoFormSection(
                        //     header: Text("Personal Information (Optional)"),
                        //     children: [
                        //       CupertinoFormRow(
                        //           prefix: SizedBox(
                        //               width: 120, child: Text("First Name")),
                        //           child: CupertinoTextFormFieldRow(
                        //             placeholder: 'Oguzhan',
                        //           )),
                        //       CupertinoFormRow(
                        //           prefix: SizedBox(
                        //               width: 120, child: Text("Last Name")),
                        //           child: CupertinoTextFormFieldRow(
                        //             placeholder: 'Akan',
                        //           )),
                        //       CupertinoFormRow(
                        //           prefix: SizedBox(
                        //               width: 120, child: Text("Birth Date")),
                        //           child: Container(
                        //               height: 120,
                        //               child: CupertinoDatePicker(
                        //                 mode: CupertinoDatePickerMode.date,
                        //                 onDateTimeChanged: (DateTime value) {},
                        //               ))),
                        //       Card(
                        //           child: CheckboxListTile(
                        //         title: Text("title text"),
                        //         value: true,
                        //         onChanged: (newValue) {},
                        //         controlAffinity: ListTileControlAffinity
                        //             .leading, //  <-- leading Checkbox
                        //       )),
                        //     ]),
                        SizedBox(
                          height: 12.0,
                        ),
                        CupertinoButton.filled(
                            child: Text("Submit"),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                bool res =
                                    await user.signUp(_email!, _password!);
                                if (res) {
                                  // print("successfully signed in.");
                                  Navigator.of(context).pop();
                                  // Navigator.pushReplacementNamed(
                                  //     context, '/personal-information',
                                  //     arguments: {"user": user});
                                } else
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        new CupertinoAlertDialog(
                                      title: new Text("Cannot Sign Up"),
                                      content: new Text(
                                          "Problem in signing up. Please try again later or try different methods."),
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
                                print(res);
                              }
                            }),
                        SizedBox(
                          height: 12.0,
                        ),
                        Row(children: [
                          Text(
                            'Already have an account? ',
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, '/email-signin',
                                    arguments: {"user": user});
                              },
                              child: Text(
                                'Sign in',
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1!
                                    .copyWith(color: Colors.blue[700]),
                              )),
                        ]),
                      ])))),
    );
  }
}
