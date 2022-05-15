import 'dart:convert';

import 'package:covidlab/services/requests.dart';
import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/personalInfoWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:covidlab/services/loginmethods.dart';

class SignedInWidget extends StatefulWidget {
  // SignedInWidget({Key? key}) : super(key: key);
  SignedInWidget({Key? key}) : super(key: key);

  @override
  _SignedInWidgetState createState() => _SignedInWidgetState();
}

class _SignedInWidgetState extends State<SignedInWidget> {
  UserRepository? userRepository;
  void initState() {
    super.initState();
    // WidgetsBinding.instance!.addPostFrameCallback((_) => onAfterBuild(context));
  }

  @override
  Widget build(BuildContext context) {
    userRepository = Provider.of<UserRepository>(context);
    print("dbUser");
    print(userRepository!.dbUser!);
    String displayName = (userRepository!.dbUser!["first_name"] +
            " " +
            userRepository!.dbUser!["last_name"]) ??
        "No Name";

    String birthDate = userRepository!.dbUser!["birth_date"] ?? "none";
    String? photoUrl = userRepository!.user!.photoURL;
    String? providerId;
    FaIcon? icon;
    print(userRepository!.user!.providerData);
    switch (userRepository!.user!.providerData[0].providerId) {
      case "facebook.com":
        providerId = 'Facebook';
        icon = FaIcon(
          FontAwesomeIcons.facebookF,
          color: Color(0xff4267B2),
        );
        break;
      case "apple.com":
        providerId = "Apple";
        icon = FaIcon(
          FontAwesomeIcons.apple,
          color: Color(0xff666666),
        );
        break;
      case "google.com":
        providerId = "Google";
        icon = FaIcon(
          FontAwesomeIcons.google,
          color: Color(0xff4285F4),
        );
        break;
      case "password":
        providerId = "Email";
        icon = FaIcon(
          FontAwesomeIcons.envelope,
          color: Color(0xff4285F4),
        );
        break;
      default:
        providerId = "";
        break;
    }
    // print(userRepository!.user!.providerData);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (photoUrl != null)
          Container(
              margin: EdgeInsets.only(bottom: 12.0),
              width: 72,
              height: 72,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    blurRadius: 12.0,
                    spreadRadius: -12.0,
                    color: Colors.grey[300]!)
              ]),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(photoUrl))),
        Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  displayName,
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 12,
                ),
                GestureDetector(
                    onTap: () async {
                      await showDialog(
                              context: context, builder: _dialogBuilder)
                          .then((value) {
                        setState(() {});
                      });
                    },
                    child: Icon(
                      CupertinoIcons.pencil,
                      size: 16,
                      color: Colors.blue,
                    ))
              ]),
        ),
        Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Text(
              birthDate,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontWeight: FontWeight.bold),
            )),
        Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon == null ? Text('icon') : icon,
                Text(
                  '  Signed in via ' + providerId,
                  style: Theme.of(context)
                      .textTheme
                      .headline6!
                      .copyWith(fontStyle: FontStyle.italic),
                )
              ],
            )),
        GestureDetector(
          child: Text(
            "Logout",
            style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Theme.of(context).primaryColorDark),
          ),
          onTap: () async {
            await Provider.of<UserRepository>(context, listen: false).signOut();
          },
        )
      ],
    );
  }

  Widget _dialogBuilder(BuildContext context) {
    bool _submitting = false;
    final _formKey = GlobalKey<FormState>();
    String? _firstName = userRepository!.dbUser!["first_name"];
    String? _lastName = userRepository!.dbUser!["last_name"];
    return StatefulBuilder(builder: (context, setState) {
      return Form(
          key: _formKey,
          child: CupertinoAlertDialog(
            title: Text("Change Your Name"),
            content: Column(
              children: [
                CupertinoTextFormFieldRow(
                  prefix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        "First\nName",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      )),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.0)),
                  initialValue: userRepository!.dbUser!["first_name"],
                  onChanged: (value) {
                    _firstName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                CupertinoTextFormFieldRow(
                  prefix: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.0),
                      child: Text(
                        "Last\nName",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      )),
                  decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.0)),
                  initialValue: userRepository!.dbUser!["last_name"],
                  onChanged: (value) {
                    _lastName = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ],
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              CupertinoDialogAction(
                child: _submitting
                    ? Container(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator())
                    : Text('Submit'),
                onPressed: _submitting
                    ? () {}
                    : () async {
                        setState(() {
                          _submitting = true;
                        });
                        if (_formKey.currentState!.validate()) {
                          Response r =
                              await sendPost(url: CHANGE_NAME_URL, headers: {
                            "Content-type": "application/json",
                            "Authorization": "Token " + userRepository!.dbToken!
                          }, body: {
                            "first_name": _firstName!,
                            "last_name": _lastName!
                          });
                          print(r.statusCode);
                          print(r.body);
                          dynamic response = json.decode(r.body);

                          if (r.statusCode != 200) {
                            Navigator.of(context).restorablePush(
                                _messageDialogBuilder,
                                arguments: {
                                  "title": "Oops",
                                  "content": response["detail"],
                                  "popCount": 1
                                });
                          } else {
                            userRepository!.dbUser!["first_name"] = _firstName;
                            userRepository!.dbUser!["last_name"] = _lastName;
                            Navigator.of(context).restorablePush(
                                _messageDialogBuilder,
                                arguments: {
                                  "title": "Success",
                                  "content": "Your name has been changed.",
                                  "popCount": 2,
                                  "result": true
                                });
                          }
                        }

                        setState(() {
                          _submitting = false;
                        });
                      },
              ),
            ],
          ));
    });
  }

  static Route<Object?> _messageDialogBuilder(
      BuildContext context, dynamic arguments) {
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(arguments!["title"] ?? 'Error'),
          content: Text(arguments!["content"] ??
              'Could not fetch the appointment data. Please try again.'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  // Navigator.of(context).pop(); // TODO: DISABLE LATER

                  Navigator.of(context)
                      .popUntil(ModalRoute.withName('/')); // TODO: ENABLE LATER
                })
          ],
        );
      },
    );
  }
}
