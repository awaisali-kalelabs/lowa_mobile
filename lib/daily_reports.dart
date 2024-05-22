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

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isFileReady = false;
  String fileUrl = "";

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
    var url =
        Uri.http(globals.ServerURL, '/portal/mobile/MobileDailyPSRReport');
    print("Server url: " + url.toString());

    try {
      var response = await http.post(url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
          },
          body: queryParameters);

      print("Response body: ${response.body}");
      print("Response statusCode: ${response.statusCode}");

      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      print('Decoded response: ' + responseBody.toString());

      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {
          print("trueeeeeee");
          fileUrl = responseBody["fileName"];
          print("fileUrl" + fileUrl);
          if (fileUrl != null && fileUrl.isNotEmpty) {
            setState(() {
              isFileReady = true;
              this.fileUrl = fileUrl;
            });
          } else {
            showErrorSnackBar(context, "Error: No file to download");
          }
        } else {
          print("False Response");
          print("Error:" + responseBody["error_code"]);
        }
      } else {
        print("Status code is not 200");
        print(
            "Error: An error has occurred: " + response.statusCode.toString());
      }
    } catch (e) {
      print("Inside Catch");
      print("Error: An error has occurred: " + e.toString());
    }
  }

  Future<void> fetchReports(BuildContext context) async {
    String ReportParams = "file=" + fileUrl;
    print("ReportParameter:" + ReportParams);

    var queryParameters = <String, String>{
      "SessionID": globals.EncryptSessionID(ReportParams),
    };
    print("QueryParameters " + queryParameters.toString());
    var url = Uri.http(
        globals.ServerURL, '/portal/mobile/MobileFileDownloadCommonFiles');
    print("Servers urlfor File: " + url.toString());

    try {
      var response = await http.post(url,
          headers: {
            HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
          },
          body: queryParameters);

      print("Responsed body File: ${response.body}");
      print("Responsed statusCode File: ${response.statusCode}");

      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      print('Decodeded response File: ' + responseBody.toString());

      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {
          print("trueeeeeee response");
          String downloadUrl = responseBody["file_url"];
          if (downloadUrl != null && downloadUrl.isNotEmpty) {
            downloadFile(downloadUrl);
          } else {
            showErrorSnackBar(context, "Error: No file downloaded");
          }
        } else {
          print("False Responsed");
          print("Errors:" + responseBody["error_code"]);
        }
      } else {
        print("Status codess is not 200");
        print(
            "Error: An error has occurred: " + response.statusCode.toString());
      }
    } catch (e) {
      print("Inside = Catch");
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
      showErrorSnackBar(context, "File downloaded to $savePath");
    } catch (e) {
      print("Error: $e");
      showErrorSnackBar(context, "Error: Failed to download file");
    }
  }

  void showErrorSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter File Download'),
      ),
      body: Center(
//         child: isFileReady
//             ? ElevatedButton(
//           onPressed: () {
//             fetchReports(context);
//           },
//           child: Text('Download File'),
//         )
//             : ElevatedButton(
//           onPressed: () async {
//             await       dailyReports(context);
// await            fetchReports(context);
//
//           },
//           child: Text('Create File'),
//         ),
        child: ElevatedButton(
          onPressed: () async {
            await dailyReports(context);
         await fetchReports(context);
          },
          child: Text('Create File'),
        ),
      ),
    );
  }
}
