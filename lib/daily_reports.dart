import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'globals.dart' as globals;
import 'home.dart';

class DailyReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter File Download',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(fontSize: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF013220),
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
          behavior: SnackBarBehavior.floating,
        ),
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

    String reportParams = "timestamp=" +
        globals.getCurrentTimestamp() +
        "&psr_id=" +
        globals.UserID.toString();
    print("ReportParams:" + reportParams);

    var queryParameters = <String, String>{
      "SessionID": globals.EncryptSessionID(reportParams),
    };
    print("QueryParameters " + queryParameters.toString());
    var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileDailyPSRReport');
    print("Server url: " + url.toString());

    try {
      var response = await http.post(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      }, body: queryParameters);

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
        print("Error: An error has occurred: " +
            response.statusCode.toString());
      }
    } catch (e) {
      print("Inside Catch");
      print("Error: An error has occurred: " + e.toString());
    }
  }

  Future<void> downloadFile(String fileUrl) async {
    Dio dio = Dio();
    try {
      Directory downloadsDir;

      // Get the downloads directory path
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory(); // iOS does not have a standard Downloads directory, so using the Documents directory
      }

      String savePath = path.join(downloadsDir.path, "downloaded_file.xlsx");

      String newFileName = "downloaded_file_${DateTime.now().millisecondsSinceEpoch}.xlsx";
       savePath = path.join(downloadsDir.path, newFileName);


      await dio.download(fileUrl, savePath);
      print("File downloaded to $savePath");

      // Reset the isFileReady state after download is complete
      setState(() {
        isFileReady = false;
      });
    } catch (e) {
      print("Error: $e");
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
        title: Text('Daily Report file'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Home()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Tap on button to download orders file",style: TextStyle(fontSize: 16,color: Colors.black87),),
            SizedBox(height: 20,),
            isFileReady
                ? ElevatedButton(
              onPressed: () async {
                await downloadFile(
                    globals.fileServerURL + "?file=" + fileUrl);
                showErrorSnackBar(context, "File downloaded");
              },
              child: Text('Download File'),
            )
                : ElevatedButton(
              onPressed: () async {
                await dailyReports(context);
              },
              child: Text('Create File'),
            ),
          ],
        ),
      ),
    );
  }
}
