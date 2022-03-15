import 'package:covidlab/widgets/add.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        leading: IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {},
        ),
        trailing: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            {
              showModalBottomSheet<void>(
                useRootNavigator: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40))),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor: 0.88, child: AddAppointment());
                },
              );
            }
          },
        ),
        middle: Text('CovidLab'),
      ),
      body: TextButton(
        child: Text('homepage'),
        onPressed: () {},
      ),
    );
  }
}
