import 'dart:convert';

import 'package:http/http.dart' as http;

// const String host = 'http://137.184.216.180:8001';
const String host = 'http://127.0.0.1:8000';
const Map<String, String> headers = {"Content-type": "application/json"};

Future<http.Response> sendPost(
    {required String url, String? body, int timeout = 4}) async {
  print("sending post request to: " + url);
  // void printWrapped(String text) {
  //   final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
  //   pattern.allMatches(text).forEach((match) => print(match.group(0)));
  // }

  //  printWrapped(body!);
  try {
    http.Response response = await http
        .post(Uri.parse(host + url), headers: headers, body: body)
        .timeout(Duration(seconds: timeout));
    return response;
  } catch (err) {
    return http.Response(err.toString(), 200);
  }
}

Future<http.Response> sendGet({required String url, int timeout = 4}) async {
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
