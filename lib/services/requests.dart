import 'dart:convert';

import 'package:http/http.dart' as http;

const String host = 'http://127.0.0.1:8000'; // FOR IOS
// const String host = 'http://10.0.2.2:8000'; // FOR ANDROID

Future<http.Response> sendPost(
    {required String url,
    required Map<String, String> body,
    Map<String, String> headers = const {"Content-type": "application/json"},
    int timeout = 4}) async {
  print("sending post request to: " + url);
  // void printWrapped(String text) {
  //   final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  //   pattern.allMatches(text).forEach((match) => print(match.group(0)));
  // }

  //  printWrapped(body!);
  try {
    http.Response response = await http
        .post(Uri.parse(host + url), headers: headers, body: json.encode(body))
        .timeout(Duration(seconds: timeout));
    return response;
  } catch (err) {
    return http.Response(err.toString(), 200);
  }
}

Future<http.Response> sendGet(
    {required String url,
    Map<String, String>? headers,
    int timeout = 4}) async {
  print("sending get request to: " + url);
  try {
    http.Response response = await http
        .get(Uri.parse(host + url), headers: headers)
        .timeout(Duration(seconds: timeout));
    return response;
  } catch (err) {
    return http.Response(
        json.encode({"success": false, "message": err.toString()}), 404);
  }
}
