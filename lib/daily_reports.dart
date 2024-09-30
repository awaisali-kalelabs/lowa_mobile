import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'globals.dart' as globals;
import 'home.dart';

class DailyReports extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  bool isLoading = false;
  bool isCreatingFile = false;
  String fileUrl = "";

  Future<void> checkPermissions() async {
    // Check for storage permission
    print("inside permission function");
    await Permission.storage.status;
    await Permission.manageExternalStorage.status;
/*
    var storageStatus = await Permission.storage.status;
*/
/*    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        // Provide feedback to the user about permission denial
        showErrorSnackBar(context, "Storage permission denied. Please enable it in settings==============.");
        throw Exception("Storage permission denied");
      }
    }else{*/
    // Check for manage external storage permission (Android 11+if (Platform.isAndroid) {
/*
      var manageExternalStorageStatus = await Permission.manageExternalStorage.status;
*/
    /* if (!manageExternalStorageStatus.isGranted) {
        manageExternalStorageStatus = await Permission.manageExternalStorage.request();
        if (!manageExternalStorageStatus.isGranted) {
          // Provide feedback to the user about permission denial
          showErrorSnackBar(context, "Manage External Storage permission denied. Please enable it in settings.");
          throw Exception("Manage External Storage permission denied");
        }
      }*/
    //}



  }


  Future<void> dailyReports(BuildContext context) async {
    setState(() {
      isCreatingFile = true;
    });

    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());

    String reportParams = "timestamp=" +
        globals.getCurrentTimestamp() +
        "&psr_id=" +
        globals.UserID.toString() +
        "&pjpid=" +
        globals.selectedPJP.toString();
    print("ReportParams:" + reportParams);

    var queryParameters = <String, String>{
      "SessionID": globals.EncryptSessionID(reportParams),
    };
    print("QueryParameters " + queryParameters.toString());
    var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileDailyPSRReport');
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
        print("Error: An error has occurred: " + response.statusCode.toString());
      }
    } catch (e) {
      print("Inside Catch");
      print("Error: An error has occurred: " + e.toString());
    } finally {
      setState(() {
        isCreatingFile = false;
      });
    }
  }

  Future<void> downloadFile(String fileUrl) async {
    Dio dio = Dio();
    try {
      setState(() {
        isLoading = true;
      });

      // Check for permissions
      await checkPermissions();

      Directory downloadsDir = Directory('/storage/emulated/0/Download');

      String newFileName =
          "psr_daily_sales_report_${globals.UserID}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      String savePath = path.join(downloadsDir.path, newFileName);

      await dio.download(fileUrl, savePath);
      print("File downloaded to $savePath");

      // Reset the isFileReady state after download is complete
      setState(() {
        isFileReady = false;
        isLoading = false;
      });
      showErrorSnackBar(context, "File downloaded to $savePath");
    } catch (e) {
      print("Error: $e");
      showErrorSnackBar(context, "Error: $e");
      setState(() {
        isLoading = false;
      });
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
        title: Text('Daily Sales Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tap on button to ${isFileReady ? 'download' : 'create'} file",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            SizedBox(
              height: 20,
            ),
            isLoading || isCreatingFile
                ? CircularProgressIndicator()
                : isFileReady
                ? ElevatedButton(
              onPressed: () async {
                await downloadFile(
                    globals.fileServerURL + "?file=" + fileUrl);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Home()),
                );
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
