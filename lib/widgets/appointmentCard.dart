import 'dart:io';
import 'dart:typed_data';

import 'package:covidlab/variables/urls.dart';
import 'package:covidlab/widgets/manage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AppointmentCard extends StatefulWidget {
  AppointmentCard(
      {Key? key, required this.appointment, required this.dummyFunc})
      : super(key: key);
  final dynamic appointment;
  final dummyFunc;

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  dynamic appointment;

  @override
  void initState() {
    appointment = widget.appointment;
    super.initState();
  }

  final f = DateFormat('EEE, MMM d, yyyy');
  final m = DateFormat('MMM');
  final d = DateFormat('d');
  final h = DateFormat('h:mm a');
  final g = DateFormat('EEE, MMM d, yyyy h:mm a');

  @override
  Widget build(BuildContext context) {
    // print(appointment);
    if (appointment["canceled"])
      return SizedBox.shrink();
    else if (DateTime.parse(appointment["test_date"]).isAfter(DateTime.now())) {
      return Card(
        elevation: 0,
        color: Colors.blue.shade600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          splashColor: Colors.blue.withAlpha(50),
          onTap: () async {
            {
              await showModalBottomSheet<bool>(
                useRootNavigator: true,
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40))),
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor: 0.88,
                      child: ManageAppointment(appointment: appointment));
                },
              ).then((value) => setState(() {
                    print("setstate works");
                    widget.dummyFunc();
                  }));
            }
          },
          child: ListTile(
            contentPadding: EdgeInsets.all(36.0),
            leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(CupertinoIcons.lab_flask_solid)),
            title: Container(
                height: 96,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Upcoming Appointment",
                        style: Theme.of(context).primaryTextTheme.caption,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "on ",
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Text(
                              f.format(DateTime.parse(appointment["test_date"])
                                  .toLocal()),
                              style: Theme.of(context)
                                  .primaryTextTheme
                                  .caption!
                                  .copyWith(fontWeight: FontWeight.bold),
                            )
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "at ",
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Text(
                              h.format(DateTime.parse(appointment["test_date"])
                                  .toLocal()),
                              style:
                                  Theme.of(context).primaryTextTheme.headline5,
                            )
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "at ",
                              style: Theme.of(context).primaryTextTheme.caption,
                            ),
                            Text(
                              appointment["location"]["name"],
                              style:
                                  Theme.of(context).primaryTextTheme.subtitle1,
                            )
                          ])
                    ])),
          ),
        ),
      );
    } else {
      appointment["result_text"] = appointment["result"] == null
          ? "PENDING"
          : appointment["result"]
              ? "POSITIVE"
              : "NEGATIVE";

      Color _resultColor = appointment["result_text"] == "PENDING"
          ? Colors.amber.shade700
          : appointment["result"]
              ? Colors.red.shade700
              : Colors.green.shade700;
      return Stack(children: [
        Card(
          elevation: 0,
          color: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.all(36.0),
            leading: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  appointment["result"] == null
                      ? CupertinoIcons.clock_fill
                      : appointment["result"]
                          ? CupertinoIcons.exclamationmark_circle_fill
                          : CupertinoIcons.check_mark_circled_solid,
                  color: _resultColor,
                )),
            title: Container(
                height: 96,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Past Appointment",
                        style: Theme.of(context).textTheme.caption,
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "on ",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              g.format(DateTime.parse(appointment["test_date"])
                                  .toLocal()),
                              style:
                                  Theme.of(context).textTheme.caption!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            )
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "at ",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Text(
                              appointment["location"]["name"],
                              style:
                                  Theme.of(context).textTheme.caption!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                            )
                          ]),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Result ",
                              style: Theme.of(context).textTheme.caption,
                            ),
                            Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                    color: _resultColor,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Text(
                                  appointment["result_text"],
                                  style: Theme.of(context)
                                      .primaryTextTheme
                                      .bodyMedium!
                                      .copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                )),
                          ]),
                    ])),
          ),
        ),
        appointment["result"] == null
            ? SizedBox.shrink()
            : Positioned(
                top: 12.0,
                right: 24.0,
                child: SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: IconButton(
                        padding: EdgeInsets.all(2),
                        iconSize: 24,
                        onPressed: () async {
                          await _createPdf(appointment);
                        },
                        icon: Icon(
                          Icons.picture_as_pdf_rounded,
                          color: Colors.grey.shade700,
                        ))),
              ),
        appointment["result"] == null
            ? SizedBox.shrink()
            : Positioned(
                top: 12.0,
                right: 56.0,
                child: SizedBox(
                    height: 24.0,
                    width: 24.0,
                    child: IconButton(
                        padding: EdgeInsets.all(2),
                        iconSize: 24,
                        onPressed: () {
                          Navigator.of(context).restorablePush(
                              _testResultShareBuilder,
                              arguments: {
                                "appointment": appointment,
                              });
                        },
                        icon: Icon(
                          Icons.share,
                          color: Colors.grey.shade700,
                        ))),
              ),
      ]);
    }
  }

  Future<void> _createPdf(dynamic arguments) async {
    final font = await PdfGoogleFonts.nunitoExtraLight();
    final pdf = pw.Document();
    final q = DateFormat('d-M-yyyy h:mm a');

    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text('CovidLab',
                    style: pw.TextStyle(font: font, fontSize: 24)),
                pw.Text('Test Result',
                    style: pw.TextStyle(font: font, fontSize: 40)),
                pw.SizedBox(height: 120),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Test Type',
                          style: pw.TextStyle(font: font, fontSize: 18)),
                      pw.Text('Sampling Date',
                          style: pw.TextStyle(font: font, fontSize: 18)),
                      pw.Text('Result Date',
                          style: pw.TextStyle(font: font, fontSize: 18)),
                      pw.Text('Result',
                          style: pw.TextStyle(font: font, fontSize: 18)),
                    ]),
                pw.Divider(),
                pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('COVID-19 PCR\nAntigen Test',
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text(
                          q.format(DateTime.parse(appointment["test_date"])
                              .toLocal()),
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text(
                          q.format(DateTime.parse(appointment["result_date"])
                              .toLocal()),
                          style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text(appointment["result_text"],
                          style: pw.TextStyle(font: font, fontSize: 12)),
                    ]),
                pw.SizedBox(height: 120),
                pw.Text(
                    "To verify this test result, please scan the QR code below.",
                    style: pw.TextStyle(font: font, fontSize: 14)),
                pw.SizedBox(height: 12),
                pw.Container(
                    // color: PdfColor.fromHex("#FF0000"),
                    child: pw.BarcodeWidget(
                  width: 120,
                  height: 120,
                  barcode: pw.Barcode.qrCode(),
                  data: HOST + VERIFY_RESULT_URL + appointment["verify_id"],
                )),
              ],
            ),
          ); // Center
        })); // Page

    String dateText = q.format(DateTime.parse(appointment['test_date']));
    final directory = await getApplicationDocumentsDirectory();
    final file = await File('${directory.path}/$dateText.pdf').create();
    // final file = await File('example.pdf').create();
    await file.writeAsBytes(await pdf.save());
    print("done");

    await Share.shareFiles([file.path], subject: "Covid-19 Testing");
  }

  static Route<Object?> _testResultShareBuilder(
      BuildContext context, dynamic arguments) {
    final q = DateFormat('d-M-yyyy h:mm a');
    final h = DateFormat('d-M-yyyy');

    final _screenshotController = ScreenshotController();

    void _shareResult(BuildContext context) async {
      await _screenshotController
          .capture(delay: const Duration(milliseconds: 10))
          .then((dynamic image) async {
        if (image != null) {
          String dateText =
              h.format(DateTime.parse(arguments['appointment']['test_date']));
          final directory = await getApplicationDocumentsDirectory();
          final imagePath =
              await File('${directory.path}/Covid-19 Testing on $dateText.png')
                  .create();
          await imagePath.writeAsBytes(image);

          /// Share Plugin
          ///
          print(imagePath.path);

          await Share.shareFiles([imagePath.path],
              subject: "Covid-19 Testing on $dateText");
        }
      });
    }

    Color _resultColor = arguments["appointment"]["result_text"] == "PENDING"
        ? Colors.amber.shade700
        : arguments["appointment"]["result"]
            ? Colors.red.shade700
            : Colors.green.shade700;
    return CupertinoDialogRoute<void>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Test Result"),
          content: Screenshot(
              controller: _screenshotController,
              child: Container(
                  width: 240,
                  height: 420,
                  child: Column(
                    children: [
                      QRImage(HOST +
                          VERIFY_RESULT_URL +
                          arguments["appointment"]["verify_id"]),
                      Text(
                        arguments["appointment"]["location"]["name"],
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Test Result"),
                      Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: _resultColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                            arguments["appointment"]["result_text"],
                            style: Theme.of(context)
                                .primaryTextTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          )),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Tested on"),
                      Text(
                        q.format(DateTime.parse(
                                arguments["appointment"]["test_date"])
                            .toLocal()),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Text("Test Result Logged on"),
                      Text(
                        q.format(DateTime.parse(
                                arguments["appointment"]["result_date"])
                            .toLocal()),
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 36,
                      ),
                      Container(
                          height: 24.0,
                          width: 24.0,
                          child: CupertinoButton(
                              padding: EdgeInsets.all(2),
                              onPressed: () => _shareResult(context),
                              child: Icon(
                                CupertinoIcons.share,
                                color: Colors.grey.shade700,
                              ))),
                    ],
                  ))),
          actions: <Widget>[
            CupertinoDialogAction(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
    );
  }
}

class QRImage extends StatelessWidget {
  QRImage(this.data);
  final String data;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Flexible(
        child: QrImage(
      data: data,
      version: QrVersions.auto,
      size: 200.0,
    ));
  }
}
