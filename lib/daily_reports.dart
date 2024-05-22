import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'globals.dart' as globals;

void main() {
  runApp(DailyReports());
}

class DailyReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Download',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  Future<void> dailyReports(BuildContext context) async {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());

    String ReportParams = "timestamp=" +
        globals.getCurrentTimestamp() +
        "&psr_id=" +
        globals.UserID.toString();
    print("ReportParams:" + ReportParams);

    var queryParameters = <String, String>{
      "SessionID": globals.EncryptSessionID(ReportParams),
    };
    print("QueryParameters " + queryParameters.toString());
    var url = Uri.http(
        globals.ServerURL, '/portal/mobile/MobileDailyPSRReport');
    print("Server url: " + url.toString());

    try {
      var response = await http.post(url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
          },
          body: queryParameters);

      // Log the raw response body
      print("Response body: ${response.body}");
      print("Response statusCode: ${response.statusCode}");

      // Decode the response body
      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      print('Decoded response: ' + responseBody.toString());

      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {
          print("trueeeeeee");
          String fileUrl = responseBody["file_url"];
          await downloadFile(fileUrl);
        } else {
          print("False Response");
          print("Error:" + responseBody["error_code"]);
        }
      } else {
        print("Status code is not 200");
        print("Error: An error has occurred: " + response.statusCode.toString());
      }
    } catch (e) {
      print("Inside Catch");
      print("Error: An error has occurred: " + e.toString());
    }
  }

  Future<void> downloadFile(String fileUrl) async {
    Dio dio = Dio();
    try {
      var dir = await getApplicationDocumentsDirectory();
      String savePath = "${dir.path}/downloaded_file.xlsx";
      await dio.download(fileUrl, savePath);
      print("File downloaded to $savePath");

    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter File Download'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            dailyReports(context);
          },
          child: Text('Download File'),
        ),
      ),
    );
  }
}
