import 'package:http/http.dart';

const String host = 'http://127.0.0.1:8000';
const Map<String, String> headers = {"Content-type": "application/json"};

Future<Response> sendPost({String? url, String? body, int timeout = 4}) async {
  print("body:");
  void printWrapped(String text) {
    final pattern = new RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  printWrapped(body!);
  try {
    Response response =
        await post(Uri.parse(host + url!), headers: headers, body: body)
            .timeout(Duration(seconds: timeout));
    return response;
  } catch (err) {
    return Response(err.toString(), 200);
  }
}
