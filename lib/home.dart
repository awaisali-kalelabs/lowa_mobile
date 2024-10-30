import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:order_booker/attendance.dart';
import 'package:order_booker/attendance_sync_report_view.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/main.dart';
import 'package:order_booker/order_report_select_date.dart';
import 'package:order_booker/outlet_registration.dart';
import 'package:order_booker/pre_sell_route.dart';

import 'package:async/async.dart';
import 'package:order_booker/sales_report_select_date.dart';
import 'package:order_booker/sales_report_view.dart';
import 'package:order_booker/stock_report_view.dart';
import 'package:order_booker/order_sync_report_view.dart';

/*import 'package:order_booker/pre_sell_route_offline_deliveries.dart';
import 'package:order_booker/spot_sell_route.dart';
import 'pre_sell_chart.dart';
import 'pre_sell_route.dart';
import 'spot_sell_chart.dart';*/
import 'SelectPJP.dart';
import 'com/pbc/dao/database_export.dart';
import 'daily_reports.dart';
import 'globals.dart' as globals;

// This app is a stateful, it tracks the user's current choice.
class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> {
  /*Repository repo=new Repository();*/
  final GlobalKey<ScaffoldState> _scaffoldKey1 = new GlobalKey<ScaffoldState>();
  List<String> Routes;
  double delivered = 0;
  final newVersionPlus = NewVersionPlus(
    androidId: 'com.pbc.order_booker',
  );

  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> AllOrdersItems;
  Repository repo = new Repository();
  var PreSellData;
  int isUpdated = 0;
  int totalOutlets = 0;
  int totalVisits = 0;
  int totalOrders = 0;
  int totalNoOrders = 0;
  int totalOutletClosed = 0;
  int pendingVisits = 0;
  int ChartSeries = 0;

  // DateTime now = DateTime.now();
  bool isAfterFivePM = false;
  Timer _timer;
  List<charts.Series<GaugeSegment, String>> series = null;
  List<Map<String, dynamic>> PreSellRoutes;

  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  int isUploaded = 1;
  int isAnythingUploaded = 0;

  @override
  Future<void> initState() {
    super.initState();
    String DeviceID;
   //checkForNewVersion()
    _getDeviceId().then((val)
    {
      setState(() {
        DeviceID = val;
        globals.DeviceID = DeviceID;
      });
    });
    globals.OutletID = 0;
    globals.OutletAddress = "";
    globals.OutletName ="";
    globals.OutletNumber = 0.toString();
    globals.OutletOwner = "";
    // globals.DeviceID = DeviceID;
    print("Device IDs" + globals.DeviceID.toString());
    globals.stopContinuousLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showPJPDialog(context); // Assuming you're using GetX for context
    });
    print("Inside Init of Home");
    print("PJP : " + globals.selectedPJP.toString());
    var currDate = new DateTime.now();
    int weekDay = currDate.weekday;

    globals.WeekDay = globals.getPBCDayNumber(weekDay);
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _checkTime();
    });
    Repository repo = new Repository();
    fetchPJP();
    saveUser();
    print(globals.WeekDay);
    print("isAlternative :" + globals.isAlternative.toString());
    repo.getTotalOutlets(globals.WeekDay, globals.selectedPJP).then((value) {
      print("getTotalOutlets" + value.toString());
      setState(() {
        totalOutlets = value[0]['totalOutlets'];
        if (totalOutlets != 0) {
          delivered = totalVisits / totalOutlets * 100;
        }
        if (delivered != double.infinity && delivered != double.nan) {
          ChartSeries = delivered.round();
        }
        PreSellData = [
          new GaugeSegment(
              'Low', ChartSeries, charts.MaterialPalette.red.shadeDefault),
          new GaugeSegment('Acceptable', (100 - ChartSeries),
              charts.ColorUtil.fromDartColor(Colors.blue[100])),
        ];
      });
    });
    print("After getTotalOutlets");
    repo.getTotalOrders(globals.selectedPJP).then((value) {
      setState(() {
        totalOrders = value;
        totalVisits = totalOrders + totalNoOrders + totalOutletClosed;
        pendingVisits = totalOutlets - totalVisits;
        if (totalOutlets != 0) {
          delivered = totalVisits / totalOutlets * 100;
        }
        if (delivered != double.infinity && delivered != double.nan) {
          ChartSeries = delivered.round();
        }
        PreSellData = [
          new GaugeSegment(
              'Low', ChartSeries, charts.MaterialPalette.red.shadeDefault),
          new GaugeSegment('Acceptable', (100 - ChartSeries),
              charts.ColorUtil.fromDartColor(Colors.blue[100])),
        ];
      });
    });
    print("After getTotalOrders");

    repo.getTotalNoOrders(globals.selectedPJP).then((value) {
      setState(() {
        totalNoOrders = value;
        totalVisits = totalOrders + totalNoOrders + totalOutletClosed;
        pendingVisits = totalOutlets - totalVisits;
        if (totalOutlets != 0) {
          delivered = totalVisits / totalOutlets * 100;
        }
        if (delivered != double.infinity && delivered != double.nan) {
          ChartSeries = delivered.round();
        }
        PreSellData = [
          new GaugeSegment(
              'Low', ChartSeries, charts.MaterialPalette.red.shadeDefault),
          new GaugeSegment('Acceptable', (100 - ChartSeries),
              charts.ColorUtil.fromDartColor(Colors.blue[100])),
        ];
      });
    });
    print("After getTotalNoOrders");

    repo.getTotalOutletClosed().then((value) {
      setState(() {
        totalOutletClosed = value;
        totalVisits = totalOrders + totalNoOrders + totalOutletClosed;
        pendingVisits = totalOutlets - totalVisits;
        if (totalOutlets != 0) {
          delivered = totalVisits / totalOutlets * 100;
        }
        if (delivered != double.infinity && delivered != double.nan) {
          ChartSeries = delivered.round();
        }
        PreSellData = [
          new GaugeSegment(
              'Low', ChartSeries, charts.MaterialPalette.red.shadeDefault),
          new GaugeSegment('Acceptable', (100 - ChartSeries),
              charts.ColorUtil.fromDartColor(Colors.blue[100])),
        ];
      });
    });
    print("After getTotalOutletClosed");

    AllOrders = new List();
    repo.getAllOrders(globals.OutletID, 0).then((val) async {
      // setState(() {
      AllOrders = val;
      // });

      AllOrdersItems = new List();
      for (int i = 0; i < AllOrders.length; i++) {
        repo.getAllAddedItemsOfOrder(AllOrders[i]['id']).then((val) async {
          setState(() {
            AllOrdersItems = val;
            totalAddedProducts = AllOrdersItems.length;
            for (int i = 0; i < AllOrdersItems.length; i++) {
              totalAmount += AllOrdersItems[i]['amount'];
            }
          });
        });
      }
    });
    print("After getAllOrders");

    PreSellRoutes = new List();
    if (globals.isLocalLoggedIn != 1) {
      if (globals.isFromLoginRoute == 1) {
        globals.isFromLoginRoute = 1;
        syncStockPosition();
      }

      _SyncMarkedAttendancePhoto();
    }
  }

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   super.didChangeDependencies();
  //
  // }

  void checkForNewVersion(BuildContext context) async {
    await newVersionPlus.getVersionStatus().then((value) {
      // print(value!.storeVersion.toString());
      print('value.localVersion ${value.localVersion}');
      print('value.storeVersion ${value.storeVersion}');
      print(' update ${value.canUpdate}');
      if (value.canUpdate) {
        newVersionPlus.showUpdateDialog(
            context: context,

            //   launchModeVersion: LaunchModeVersion.external,
            versionStatus: value,
            allowDismissal: false,
            dialogTitle: 'Update Available',
            dialogText:
                'Please update your app to get latest features and best experience',
            updateButtonText: 'Update',
            dismissButtonText: 'Later',
            dismissAction: () {
              Navigator.pop(context);
            });
      }
    }).catchError((e) {
      print('update error ${e.toString()}');
    });
  }

  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId;
  }

  void showPJPDialog(BuildContext context) {
    // Check if selectedPJP is null or empty
    if (globals.selectedPJP == null || globals.selectedPJP.isEmpty) {
      // Show dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No PJP Selected'),
            content: Text('Please select a PJP to continue.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AreaSelectionScreen()),
                  );
                },
                child: Text('Select PJP'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> fetchPJP() async {
    List<Map<String, dynamic>> fetchedPJPs = await repo.getSelectedPJPs();
    if (fetchedPJPs.isNotEmpty) {
      String fetchedPJP = fetchedPJPs[0]
          ['PJPID']; // Assuming you want the first PJPID from the list
      print("fetchedPJP :" + fetchedPJP.toString());
      globals.selectedPJP = fetchedPJP;
    } else {
      print('No selected PJPs found');
    }
  }

  Future<void> saveUser() async {
    try {
      List<Map<String, dynamic>> fetchedUser = await repo.getUserAgain();

      if (fetchedUser.isNotEmpty) {
        String userName = fetchedUser[0]['display_name'];
        int userID = fetchedUser[0]['user_id'];
        globals.IsOutletLocationUpdate = fetchedUser[0]['IsOutletLocationUpdate'];
        print("UserName: $userName");
        print("IsOutletLocationUpdate: " + globals.IsOutletLocationUpdate.toString());

        globals.DisplayName = userName;
        globals.UserID = userID;
      } else {
        print('No user found');
      }
    } catch (e) {
      print('Error saving user: $e');
    }
  }

  void _checkTime() {
    bool newIsAfterFivePM = false;
    DateTime now = DateTime.now();
    if (globals.UserID == 2762) {
      newIsAfterFivePM = now.hour >= 8 && now.hour < 24;
    } else {
      newIsAfterFivePM = now.hour >= 16 && now.hour < 22;
    }
//

    //bool newIsAfterFivePM = now.hour >= 11 && now.hour < 24;

    if (newIsAfterFivePM != isAfterFivePM) {
      setState(() {
        isAfterFivePM = newIsAfterFivePM;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  Future _UploadDocuments() async {
    print("_UploadDocuments called");
    // List AllDocuments = new List();
    await repo.getAllOutletImages(globals.orderId).then((val) async {
      /*   setState(() {
        AllDocuments = val;
      });*/

      for (int i = 0; i < val.length; i++) {
        int MobileRequestID = int.parse(val[i]['id'].toString());
        String created_on = val[i]['created_on'].toString();
        print("created_on == " + created_on.toString());
        try {
          print("AllDocuments.length" + val.length.toString());
          File photoFile = File(val[i]['file']);
          //  var stream =
          var stream = ByteStream(photoFile.openRead());
          var length = await photoFile.length();
          var url = Uri.http(
              globals.ServerURL, '/portal/mobile/MobileUploadOrdersImage');
          print("================="+url.toString());
          print("===Hello===");
          String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['OrderNo'] = MobileRequestID.toString();
          request.fields['created_on'] = created_on;
          print("===Hello1===");
          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: "Outlet_" + fileName);

          request.files.add(multipartFile);
          print("multipartFile===>" + multipartFile.toString());
          var response = await request.send();
          print("===Hello=="+response.toString());

          print("====="+response.statusCode.toString());

          print("response"+response.statusCode.toString());
          print(response.toString());
          if (response.statusCode == 200) {
            print("MarkImage SUCCESS");
            await repo.markPhotoUploaded(MobileRequestID);
          }else{
            print("False Image");
          }
        } catch (e) {
          print("===Hello3===");
          print("e.toString()  " + e.toString());
        }
      }
    });
  }

  Future _UploadOutletMarkClosed() async {
    String TimeStamp = globals.getCurrentTimestamp();
    print("currDateTime" + TimeStamp);
    int ORDERIDToDelete = 0;
    List<Map<String, dynamic>> AllOutletsMarkedClose = new List();
    await repo.getAllOutletMarkClose(0).then((val) async {
      setState(() {
        AllOutletsMarkedClose = val;

        print("OutletClosed" + AllOutletsMarkedClose.toString());
      });

      for (int i = 0; i < AllOutletsMarkedClose.length; i++) {
        setState(() {
          isAnythingUploaded = 1;
        });
        String orderParam = "timestamp=" +
            TimeStamp +
            "&NoOrderID=" +
            AllOutletsMarkedClose[i]['id'].toString() +
            "&OutletID=" +
            AllOutletsMarkedClose[i]['outlet_id'].toString() +
            "&MobileTimestamp=" +
            AllOutletsMarkedClose[i]['created_on'].toString() +
            "&UserID=" +
            globals.UserID.toString() +
            "&Lat=" +
            AllOutletsMarkedClose[i]['lat'] +
            "&Lng=" +
            AllOutletsMarkedClose[i]['lng'] +
            "&accuracy=" +
            AllOutletsMarkedClose[i]['accuracy'] +
            "";
        ORDERIDToDelete = AllOutletsMarkedClose[i]['id'];
        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(orderParam),
        };

        var url = Uri.http(
            globals.ServerURL, '/portal/mobile/MobileSyncOutletClosed');
        print(url);

        try {
          var response = await http.post(url,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded'
              },
              body: QueryParameters);

          var responseBody = json.decode(utf8.decode(response.bodyBytes));
          print('called4');
          if (response.statusCode == 200) {
            if (responseBody["success"] == "true") {
              await repo.markOutletMarkCloseUploaded(ORDERIDToDelete);
            } else {
              await _showDialog(
                  "Error Uploading Closed Outlets", responseBody["error_code"]);
            }
          } else {
            // If that response was not OK, throw an error.
            setState(() {
              isUploaded = 0;
              isAnythingUploaded = 1;
            });
            _showDialog("Error Uploading Closed Outlets",
                "An error has occured " + responseBody.statusCode);
          }
        } catch (e) {
          setState(() {
            isUploaded = 0;
            isAnythingUploaded = 1;
          });
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          _showDialog("Error Uploading Closed Outlets",
              "Check your internet connection");
          break;
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);
      }
    });
    _UploadOutletMarkClosedPhoto();
  }

  Future _UploadOutletMarkClosedPhoto() async {
    List<Map<String, dynamic>> AllOutletsMarkedClose = new List();
    await repo.getAllOutletMarkClose(1).then((val) async {
      if (!mounted) {
        setState(() {
          AllOutletsMarkedClose = val;
        });
      }
      // else {
      //
      //   setState(() {
      //     AllOutletsMarkedClose = val;
      //
      //   });
      // }
      print("OutletClosed" + AllOutletsMarkedClose.toString());

      for (int i = 0; i < AllOutletsMarkedClose.length; i++) {
        int ORDERIDToDelete = AllOutletsMarkedClose[i]['id'];
        try {
          print(AllOutletsMarkedClose[i]['image_path']);
          File photoFile = File(AllOutletsMarkedClose[i]['image_path']);
          var stream =
              new http.ByteStream(DelegatingStream.typed(photoFile.openRead()));
          var length = await photoFile.length();

          var url = Uri.http(globals.ServerURL,
              '/portal/mobile/MobileUploadOutletClosedImage');
          print(url);

          String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['value1'] = AllOutletsMarkedClose[i]['id'].toString();

          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: fileName);
          // var multipartFile = new http.MultipartFile.fromString("file", photoFile.path);
          request.files.add(multipartFile);
          var response = await request.send();
          print(response.statusCode);
          if (response.statusCode == 200) {
            await repo.markOutletMarkCloseUploadedPhoto(ORDERIDToDelete);
          } else {
            // If that response was not OK, throw an error.
            print("NOT WORKEDd");
            _showDialog("Error", "An error has occured ");
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          print("e.toString()  " + e.toString());
          _showDialog("Error", "Check your internet connection");
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);
      }
    });
  }

  void syncStockPosition() async {
    print("syncStockPosition");
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());

    String param = "timestamp=" +
        currDateTime +
        "&UserID=" +
        globals.UserID.toString() +
        "&DeviceID=" +
        globals.DeviceID +
        "&platform=android";
    var QueryParameters = <String, String>{
      "SessionID": EncryptSessionID(param),
    };
    print("syncStockPosition1");
    try {
      print("Try.........................................");
      var url = Uri.http(globals.ServerURL,
          '/portal/mobile/MobileStockPosition', QueryParameters);
//      Wave/grain/sales/MobileVFSalesContractExecute
      var response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      });
      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      print("responseBody.................................." +
          json.encode(responseBody));
      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {
          print("syncStockPosition2");
          Repository repo = new Repository();
          await repo.initdb();
          await repo.deleteAllStockPosition();
          List stock = responseBody['StockPosition'];
          for (var i = 0; i < stock.length; i++) {
            repo.insertStockPosition(stock[i]['ProductID'],
                stock[i]['ClosingUnits'], stock[i]['ClosingRawCases']);
          }
          // print("responseBody.................................." + json.encode(responseBody));
        } else {
          print(responseBody.toString());
          //_showDialog("Error", responseBody["error_code"]);
          print("syncStockPosition3");
        }
      } else {
        // If that response was not OK, throw an error.
        print("syncStockPosition4");
        //_showDialog("Error","An error has occured " + responseBody.statusCode);
        print(responseBody.statusCode);
      }
    } catch (e) {
      //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
      //_showDialog("Error","An error has occured " + e.toString());
      print("syncStockPosition5");
      print("Error" + e.toString());
    }
  }

  Future _SyncMarkedAttendance() async {
    List<Map<String, dynamic>> AllMarkedAttendances;

    String TimeStamp = globals.getCurrentTimestamp();
    print("currDateTime" + TimeStamp);
    int ORDERIDToDelete = 0;
    AllMarkedAttendances = new List();
    await repo.getAllMarkedAttendances(0).then((val) async {
      setState(() {
        AllMarkedAttendances = val;

        //  print("_UploadMarkAttendance" + AllMarkedAttendances.toString());
      });

      for (int i = 0; i < AllMarkedAttendances.length; i++) {
        setState(() {
          isAnythingUploaded = 1;
        });
        String orderParam = "timestamp=" +
            TimeStamp +
            "&AttendanceID=" +
            AllMarkedAttendances[i]['mobile_request_id'].toString() +
            "&TyepID=" +
            AllMarkedAttendances[i]['attendance_type_id'].toString() +
            "&MobileTimestamp=" +
            AllMarkedAttendances[i]['mobile_timestamp'].toString() +
            "&UserID=" +
            globals.UserID.toString() +
            "&LAT=" +
            AllMarkedAttendances[i]['lat'].toString() +
            "&LNG=" +
            AllMarkedAttendances[i]['lng'].toString() +
            "&Accu=" +
            AllMarkedAttendances[i]['accuracy'].toString() +
            "&UUID=" +
            AllMarkedAttendances[i]['uuid'] +
            "&DevicePlatformVersion=''" +
            "";
        ORDERIDToDelete =
            int.parse(AllMarkedAttendances[i]['mobile_request_id']);

        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(orderParam),
        };
        var url = Uri.http(
            globals.ServerURL, '/portal/mobile/MobileSyncMarkAttendanceV3');
        print(url);

        try {
          var response = await http.post(url,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded'
              },
              body: QueryParameters);

          var responseBody = json.decode(utf8.decode(response.bodyBytes));
          // print('called4');
          if (response.statusCode == 200) {
            if (responseBody["success"] == "true") {
              //   print ("success");
              await repo.markAttendanceUploaded(ORDERIDToDelete);
            } else {
              await _showDialog(
                  "Error Uploading Attendance", responseBody["error_code"]);
            }
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();

          await _showDialog(
              "Error Uploading Attendance", "Check your internet connection");
          break;
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);
      }
    });
  }

  Future<dynamic> _SyncMarkedAttendancePhoto() async {
    List<Map<String, dynamic>> AllMarkedAttendancesPhotos;
    print(" _UploadMarkAttendancePhoto M called");
    AllMarkedAttendancesPhotos = new List();
    repo.getAllMarkedUploadedAttendances(0).then((val) async {
      AllMarkedAttendancesPhotos = val;
      for (int i = 0; i < AllMarkedAttendancesPhotos.length; i++) {
        int ORDERIDToDelete =
            int.parse(AllMarkedAttendancesPhotos[i]['mobile_request_id']);
        try {
          print(AllMarkedAttendancesPhotos[i]['image_path']);
          File photoFile = File(AllMarkedAttendancesPhotos[i]['image_path']);
          var stream =
              new http.ByteStream(DelegatingStream.typed(photoFile.openRead()));
          var length = await photoFile.length();
          //var localUrl = Uri.http(globals.ServerURLLocal,"/nisa_portal/mobile/MobileUploadMarkAttendaceImage");
          var url = Uri.http(globals.ServerURL,
              '/portal/mobile/MobileUploadMarkAttendaceImage');

          String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['value1'] =
              AllMarkedAttendancesPhotos[i]['mobile_request_id'];

          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: fileName);
          // var multipartFile = new http.MultipartFile.fromString("file", photoFile.path);
          request.files.add(multipartFile);
          var response = await request.send();
          print(response.statusCode);

          if (response.statusCode == 200) {
            print("MobileUploadMarkAttendaceImage SUCCESS");
            await repo.markAttendanceUploadedPhoto(ORDERIDToDelete);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          print("e.toString()  " + e.toString());
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);
      }
    });
  }

  Future<dynamic> _SyncMerchandisingPhoto() async {
    List<Map<String, dynamic>> AllMerchandsingPhotos = new List();
    repo.getAllMerchandising(0).then((val) async {
      setState(() {
        AllMerchandsingPhotos = val;
      });

      for (int i = 0; i < AllMerchandsingPhotos.length; i++) {
        int ORDERIDToDelete =
            int.parse(AllMerchandsingPhotos[i]['mobile_request_id']);
        try {
          File photoFile = File(AllMerchandsingPhotos[i]['image']);

          var stream =
              new http.ByteStream(DelegatingStream.typed(photoFile.openRead()));
          var length = await photoFile.length();
          var url = Uri.http(
              globals.ServerURL, '/portal/mobile/MobileUploadOrdersImageV2');

          String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['de'] =
              AllMerchandsingPhotos[i]['mobile_timestamp'].toString();
          request.fields['outletId'] =
              AllMerchandsingPhotos[i]['outlet_id'].toString();
          request.fields['lat'] = AllMerchandsingPhotos[i]['lat'].toString();
          request.fields['lng'] = AllMerchandsingPhotos[i]['lng'].toString();
          request.fields['accuracy'] =
              AllMerchandsingPhotos[i]['accuracy'].toString();
          request.fields['uuid'] = AllMerchandsingPhotos[i]['uuid'].toString();
          request.fields['typeId'] =
              AllMerchandsingPhotos[i]['type_id'].toString();
          request.fields['userId'] =
              AllMerchandsingPhotos[i]['user_id'].toString();

          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: fileName);

          request.files.add(multipartFile);
          var response = await request.send();
          print(response.statusCode);

          if (response.statusCode == 200) {
            print("markMerchandisingPhotoUploaded SUCCESS");
            await repo.markMerchandisingPhotoUploaded(
                ORDERIDToDelete, AllMerchandsingPhotos[i]['type_id']);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          print("e.toString()  " + e.toString());
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);
      }
    });
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to logout?'),
            actions: <Widget>[
              new ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: new Text('No'),
              ),
              new ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                ),
                child: new Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  String EncryptSessionID(String qry) {
    String ret = "";
    print(qry.length);
    for (int i = 0; i < qry.length; i++) {
      int ch = (qry.codeUnitAt(i) * 5) - 21;
      ret += ch.toString() + ",";
    }

    String ret2 = "";
    for (int i = 0; i < ret.length; i++) {
      int ch = (ret.codeUnitAt(i) * 5) - 21;
      ret2 += ch.toString() + "0a";
    }

    return ret2;
  }

  Future _UploadNoOrder(context) async {
    String TimeStamp = globals.getCurrentTimestamp();
    print("currDateTime" + TimeStamp);
    int ORDERIDToDelete = 0;
    List AllNoOrders = new List();
    await repo.getAllNoOrders(0).then((val) async {
      setState(() {
        AllNoOrders = val;

        print("MAIN ORDER" + AllNoOrders.toString());
      });

      for (int i = 0; i < AllNoOrders.length; i++) {
        setState(() {
          isAnythingUploaded = 1;
        });
        String orderParam = "timestamp=" +
            TimeStamp +
            "&NoOrderID=" +
            AllNoOrders[i]['id'].toString() +
            "&OutletID=" +
            AllNoOrders[i]['outlet_id'].toString() +
            "&ReasonID=" +
            AllNoOrders[i]['reason_type_id'].toString() +
            "&MobileTimestamp=" +
            AllNoOrders[i]['created_on'].toString() +
            "&UserID=" +
            globals.UserID.toString() +
            "&uuid=" +
            globals.DeviceID +
            "&platform=android&Lat=" +
            AllNoOrders[i]['lat'] +
            "&Lng=" +
            AllNoOrders[i]['lng'] +
            "&accuracy=" +
            AllNoOrders[i]['accuracy'] +
            "";
        ORDERIDToDelete = AllNoOrders[i]['id'];
        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(orderParam),
        };

        var url =
            Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncNoOrdersV2');
        print(url);

        try {
          var response = await http.post(url,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded'
              },
              body: QueryParameters);

          var responseBody = json.decode(utf8.decode(response.bodyBytes));
          print('called4');
          if (response.statusCode == 200) {
            if (responseBody["success"] == "true") {
              await repo.markNoOrderUploaded(ORDERIDToDelete);
            } else {
              await _showDialog(
                  "Error Uploading No Order", responseBody["error_code"]);
            }
          } else {
            // If that response was not OK, throw an error.
            setState(() {
              isUploaded = 0;
            });
            await _showDialog("Error Uploading No Order",
                "An error has occured " + responseBody.statusCode);
          }
        } catch (e) {
          setState(() {
            isUploaded = 0;
            isAnythingUploaded = 1;
          });
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          await _showDialog(
              "Error Uploading No Order", "Check your internet connection");
          break;
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);
      }
    });
  }
  Future _UploadDocumentNoOrder() async {
    print("_UploadDocuments called");
    List AllDocuments = new List();
    print("================" + globals.orderId.bitLength.toString());
    // for (int i = 0; i < 2; i++) {
    // if (outletImagePath.elementAt(i) != "") {

    await repo.getNoOrderImages(globals.orderId).then((val) async {
      setState(() {
        AllDocuments = val;
      });
      print("===" + val.toString());
      //List AllDocuments = val;

      print("==========" + AllDocuments.length.toString());
      for (int i = 0; i < AllDocuments.length; i++) {
        int MobileRequestID = int.parse(AllDocuments[i]['id'].toString());
        try {
          print("AllDocuments.length" + AllDocuments.length.toString());
          File photoFile = File(AllDocuments[i]['file']);
          //  var stream =
          var stream = ByteStream(photoFile.openRead());
          var length = await photoFile.length();
          var url = Uri.http(
              globals.ServerURL, '/portal/mobile/MobileUploadNoOrdersImage');
          print(url.toString());
          print("===Hello===");
          String fileName = photoFile.path
              .split('/')
              .last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['NoOrderNo'] = MobileRequestID.toString();
          print("===Hello1===");
          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: "Outlet_" + fileName);

          request.files.add(multipartFile);
          print("multipartFile===>" + multipartFile.toString());
          var response = await request.send();
          print("===Hello==" + response.toString());

          print("=====" + response.statusCode.toString());

          print("response" + response.statusCode.toString());
          print(response.toString());
          if (response.statusCode == 200) {
            print("MarkImage SUCCESS");
            await repo.markNoOrderPhotoUploaded(MobileRequestID, i + 1);
            //
          } else {
            print("False");
          }
        } catch (e) {
          print("===Hello3===");
          print("e.toString()  " + e.toString());
        }
      }
    });


/* }else {
        if(i < 1) {
          Flushbar(
            messageText: Column(
              children: <Widget>[
                Text(
                  "Please provide at least 1 outlet image",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            backgroundGradient:
            LinearGradient(colors: [Colors.black, Colors.black]),
            icon: Icon(
              Icons.notifications_active,
              size: 30.0,
              color: Colors.blue[800],
            ),
            duration: Duration(seconds: 2),
            leftBarIndicatorColor: Colors.blue[800],
          )
            ..show(context);
        }
      }*/

    // }
  }

  Future _OutletRegisterationUpload(context) async {
    int ORDERIDToDelete = 0;
    List AllRegisteredOutlets = new List();
    await repo.getAllRegisteredOutletsByIsUploaded(0, 1).then((val) async {
      setState(() {
        AllRegisteredOutlets = val;
        print("All Registered Outlets===>> " + AllRegisteredOutlets.toString());
      });

      for (int i = 0; i < AllRegisteredOutlets.length; i++) {
        setState(() {
          isAnythingUploaded = 1;
        });
        String outletRegisterationsParams = "timestamp=" +
            globals.getCurrentTimestamp() +
            "&outlet_name=" +
            AllRegisteredOutlets[i]['outlet_name'] +
            "&mobile_request_id=" +
            (AllRegisteredOutlets[i]['mobile_request_id']).toString() +
            "&mobile_timestamp=" +
            AllRegisteredOutlets[i]['mobile_timestamp'] +
            "&channel_id=" +
            AllRegisteredOutlets[i]['channel_id'].toString() +
            "&area_label=" +
            AllRegisteredOutlets[i]['area_label'].toString() +
            "&sub_area_label=" +
            AllRegisteredOutlets[i]['sub_area_label'].toString() +
            "&address=" +
            AllRegisteredOutlets[i]['address'] +
            "&owner_name=" +
            AllRegisteredOutlets[i]['owner_name'] +
            "&owner_cnic=" +
            AllRegisteredOutlets[i]['owner_cnic'] +
            "&owner_mobile_no=" +
            AllRegisteredOutlets[i]['owner_mobile_no'] +
            "&purchaser_name=" +
            AllRegisteredOutlets[i]['purchaser_name'] +
            "&purchaser_mobile_no=" +
            AllRegisteredOutlets[i]['purchaser_mobile_no'] +
            "&is_owner_purchaser=" +
            AllRegisteredOutlets[i]['is_owner_purchaser'].toString() +
            "&lat=" +
            AllRegisteredOutlets[i]['lat'].toString() +
            "&lng=" +
            AllRegisteredOutlets[i]['lng'].toString() +
            "&accuracy=" +
            (AllRegisteredOutlets[i]['accuracy'])
                .toStringAsFixed(3)
                .toString() +
            "&created_on=" +
            AllRegisteredOutlets[i]['created_on'] +
            "&created_by=" +
            AllRegisteredOutlets[i]['created_by'].toString() +
            "&uuid=" +
            globals.DeviceID +
            "&platform=android";
        print("outletRegisterationsParams:" + outletRegisterationsParams);

        /* String orderParam="timestamp="+globa+"&order_no="+AllOrders[i]['id'].toString()+"&outlet_id="+ globals.OutletID.toString()+"&created_on="+AllOrders[i]['created_on'].toString()+"&created_by=100450&uuid=656d30b8182fea88&platform=android&lat="+_currentPosition.latitude.toString()+"&lng="+_currentPosition.longitude.toString()+"&accuracy=21";
        print("AllOrders[i]['id']"+AllOrders[i]['id'].toString());*/

        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(outletRegisterationsParams),
        };
        //var localUrl="http://192.168.10.37:8080/nisa_portal/mobile/MobileSyncOutletRegistration";
        // var localUrl="http://192.168.30.125:8080/nisa_portal/mobile/MobileSyncOutletRegistration";
        var url = Uri.http(
            globals.ServerURL, '/portal/mobile/MobileSyncOutletRegistration');

        try {
          var response = await http.post(url,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded'
              },
              body: QueryParameters);

          var responseBody = json.decode(utf8.decode(response.bodyBytes));
          print('called4');
          if (response.statusCode == 200) {
            if (responseBody["success"] == "true") {
              print("Saved");
              repo.markOutletUploaded(
                  int.tryParse(AllRegisteredOutlets[i]['mobile_request_id']));
              //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
            } else {
              // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
              setState(() {
                isUploaded = 0;
              });
              await _showDialog(
                  "Error Uploading Outlet", responseBody["error_code"]);
              print("Error:" + responseBody["error_code"]);
            }
          } else {
            //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
            setState(() {
              isUploaded = 0;
            });
            await _showDialog("Error Uploading Outlet",
                "An error has occured: " + responseBody.statusCode);
            print("Error: An error has occured: " + responseBody.statusCode);
          }
        } catch (e) {
          // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          setState(() {
            isUploaded = 0;
            isAnythingUploaded = 1;
          });
          await _showDialog(
              "Error Uploading Outlet", "Check your internet connection");
          break;
        }
      }
    });
  }

  Future _OutletRegisterationUpload2(context) async {
    int ORDERIDToDelete = 0;
    List AllRegisteredOutlets = new List();
    await repo.getAllRegisteredOutletsByIsUploaded(0, 0).then((val) async {
      setState(() {
        AllRegisteredOutlets = val;
        print("All Registered Outlets===>> " + AllRegisteredOutlets.toString());
      });

      for (int i = 0; i < AllRegisteredOutlets.length; i++) {
        setState(() {
          isAnythingUploaded = 1;
        });
        String outletRegisterationsParams = "timestamp=" +
            globals.getCurrentTimestamp() +
            "&id_for_update=" +
            (AllRegisteredOutlets[i]['id_for_update']).toString() +
            "&outlet_name=" +
            AllRegisteredOutlets[i]['outlet_name'] +
            "&mobile_request_id=" +
            (AllRegisteredOutlets[i]['mobile_request_id']).toString() +
            "&mobile_timestamp=" +
            AllRegisteredOutlets[i]['mobile_timestamp'] +
            "&channel_id=" +
            AllRegisteredOutlets[i]['channel_id'].toString() +
            "&area_label=" +
            AllRegisteredOutlets[i]['area_label'].toString() +
            "&sub_area_label=" +
            AllRegisteredOutlets[i]['sub_area_label'].toString() +
            "&address=" +
            AllRegisteredOutlets[i]['address'] +
            "&owner_name=" +
            AllRegisteredOutlets[i]['owner_name'] +
            "&owner_cnic=" +
            AllRegisteredOutlets[i]['owner_cnic'] +
            "&owner_mobile_no=" +
            AllRegisteredOutlets[i]['owner_mobile_no'] +
            "&purchaser_name=" +
            AllRegisteredOutlets[i]['purchaser_name'] +
            "&purchaser_mobile_no=" +
            AllRegisteredOutlets[i]['purchaser_mobile_no'] +
            "&is_owner_purchaser=" +
            AllRegisteredOutlets[i]['is_owner_purchaser'].toString() +
            "&lat=" +
            AllRegisteredOutlets[i]['lat'].toString() +
            "&lng=" +
            AllRegisteredOutlets[i]['lng'].toString() +
            "&accuracy=" +
            (AllRegisteredOutlets[i]['accuracy'])
                .toStringAsFixed(3)
                .toString() +
            "&created_on=" +
            AllRegisteredOutlets[i]['created_on'] +
            "&created_by=" +
            AllRegisteredOutlets[i]['created_by'].toString() +
            "&uuid=" +
            globals.DeviceID +
            "&platform=android";
        print("outletRegisterationsParams:" + outletRegisterationsParams);

        /* String orderParam="timestamp="+globa+"&order_no="+AllOrders[i]['id'].toString()+"&outlet_id="+ globals.OutletID.toString()+"&created_on="+AllOrders[i]['created_on'].toString()+"&created_by=100450&uuid=656d30b8182fea88&platform=android&lat="+_currentPosition.latitude.toString()+"&lng="+_currentPosition.longitude.toString()+"&accuracy=21";
        print("AllOrders[i]['id']"+AllOrders[i]['id'].toString());*/

        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(outletRegisterationsParams),
        };
        //var localUrl="http://192.168.10.37:8080/nisa_portal/mobile/MobileSyncOutletRegistration";
        // var localUrl="http://192.168.30.125:8080/nisa_portal/mobile/MobileSyncOutletRegistration";
        var url = Uri.http(
            globals.ServerURL, '/portal/mobile/MobileSyncOutletUpdate');

        try {
          var response = await http.post(url,
              headers: {
                HttpHeaders.contentTypeHeader:
                    'application/x-www-form-urlencoded'
              },
              body: QueryParameters);

          var responseBody = json.decode(utf8.decode(response.bodyBytes));
          print('called4');
          if (response.statusCode == 200) {
            if (responseBody["success"] == "true") {
              print("Saved");
              repo.markOutletUploaded(
                  int.tryParse(AllRegisteredOutlets[i]['mobile_request_id']));
              //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
            } else {
              // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
              setState(() {
                isUploaded = 0;
              });
              await _showDialog(
                  "Error Uploading Outlet", responseBody["error_code"]);
              print("Error:" + responseBody["error_code"]);
            }
          } else {
            //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
            setState(() {
              isUploaded = 0;
            });
            await _showDialog("Error Uploading Outlet",
                "An error has occured: " + responseBody.statusCode);
            print("Error: An error has occured: " + responseBody.statusCode);
          }
        } catch (e) {
          // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          setState(() {
            isUploaded = 0;
            isAnythingUploaded = 1;
          });
          await _showDialog(
              "Error Uploading Outlet", "Check your internet connection");
          break;
        }
      }
    });
  }

  Future _UploadOrder(context) async {
    // Fetch current date and time
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());
    var str = currDateTime.split(".");
    String TimeStamp = str[0];

    // Get current location
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    AllOrders = [];
    await repo.getAllOrdersByIsUploaded(0).then((val) async {
      AllOrders = val;
      AllOrdersItems = [];
int ORDERIDToDelete =0;
      for (int i = 0; i < AllOrders.length; i++) {
        String orderParam = "timestamp=" +
            TimeStamp +
            "&order_no=" +
            AllOrders[i]['id'].toString() +
            "&outlet_id=" +
            AllOrders[i]['outlet_id'].toString() +
            "&created_on=" +
            AllOrders[i]['created_on'].toString() +
            "&created_by=" +
            globals.UserID.toString() +
            "&uuid=" +
            globals.DeviceID +
            "&platform=android&lat=" +
            position.latitude.toString() +
            "&lng=" +
            position.longitude.toString() +
            "&accuracy=" +
            position.accuracy.toString() +
            "&PJP=" +
            AllOrders[i]['PJP'].toString() +
            "&version=" +
            globals.appVersion +
            "&Spot_Discount=" +
            "";

        ORDERIDToDelete = AllOrders[i]['id'];
        await repo.getAllAddedItemsOfOrder(AllOrders[i]['id']).then((val) async {
          AllOrdersItems = val;
          for (int j = 0; j < AllOrdersItems.length; j++) {
            orderParam += "&product_id=" +
                AllOrdersItems[j]['product_id'].toString() +
                "&quantity=" +
                AllOrdersItems[j]['quantity'].toString() +
                "&discount=" +
                AllOrdersItems[j]['discount'].toString() +
                "&unit_quantity=" +
                AllOrdersItems[j]['unit_quantity'].toString() +
                "&is_promotion=" +
                AllOrdersItems[j]['is_promotion'].toString() +
                "&promotion_id=" +
                AllOrdersItems[j]['promotion_id'].toString() +
                "&Spot_Discount_ID=" +
                AllOrdersItems[j]['DiscountID'].toString() +
                "&defaultDiscount=" +
                AllOrdersItems[j]['defaultDiscount'].toString() +
                "&maximumDiscount=" +
                AllOrdersItems[j]['maximumDiscount'].toString() +
                "";
          }
        });

        var QueryParameters = <String, String>{
          "SessionID": EncryptSessionID(orderParam),
        };

        var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncOrdersV13');

        try {
          var response = await http.post(
            url,
            headers: {
              HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
            },
            body: QueryParameters,
          );

          var responseBody = json.decode(utf8.decode(response.bodyBytes));
          if (response.statusCode == 200 && responseBody["success"] == "true") {
            await repo.markOrderUploaded(ORDERIDToDelete);
          } else {
            _showDialog("Error", responseBody["error_code"]);
          }
        } catch (e) {
          _showDialog("Error", "An error has occurred " + e.toString());
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    checkForNewVersion(context);
    return new WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: _scaffoldKey1,
          drawer: Drawer(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            height: 91.0,
                            child: new DrawerHeader(
                              decoration: BoxDecoration(
                                color: Colors.blue[800],
                              ),
                              child: Text(
                                'Theia',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ))),
                  ],
                ),
                ListTile(
                  leading: Icon(
                    Icons.file_upload,
                    color: Colors.blue,
                  ),
                  title: Text('Upload Data'),
                  onTap: () async {
                    if (globals.isImageUploading == 0) {
                      print("uploading file");
                      globals.asyncFileUpload();
                    } else {
                      print("waiting......");
                    }
                    //Dialogs.showLoadingDialog(context, _scaffoldKey2);
                    _UploadOrder(context).whenComplete(() => _UploadDocuments().whenComplete(() =>
                        _UploadNoOrder(context) .whenComplete(() => _UploadDocumentNoOrder()
                        .whenComplete(() => _OutletRegisterationUpload(context)
                            .whenComplete(() => _OutletRegisterationUpload2(context)
                                .whenComplete(() => _SyncMarkedAttendance()
                                    .whenComplete(() => _UploadOutletMarkClosed()
                                        .whenComplete(() => isUploaded == 1 && isAnythingUploaded == 1 ? _showDialogFinalMessage("Success", "Data Uploaded") : "")
                                        .whenComplete(() => isAnythingUploaded == 0 ? _showDialog("Warning", "There is nothing to upload") : "")
                                        .whenComplete(() => () {
                                              _SyncMarkedAttendancePhoto();
                                              _SyncMerchandisingPhoto();
                                            }))))))));
                  },
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                ListTile(
                  leading: Icon(Icons.data_exploration, color: Colors.blue),
                  title: Text('Export DB'),
                  onTap: () {
                   /* globals.Reset();*/
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DatabaseExport()),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: Colors.blue),
                  title: Text('Logout'),
                  onTap: () {
                    globals.Reset();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                Expanded(
                    child: Align(
                        alignment: FractionalOffset.bottomRight,
                        child: Container(
                            height: 57,
                            //  color: Colors.blue,
                            child: Container(
                                padding: EdgeInsets.all(10),
                                height: 100,
                                child: Text(
                                  globals.appVersion,
                                  textAlign: TextAlign.right,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ))))),
              ],
            ),
          ),
          appBar: AppBar(
            backgroundColor: Colors.blue[800],
            actions: <Widget>[
              TextButton.icon(
                icon: Icon(Icons.published_with_changes_sharp,
                    color: Colors.white),
                // Ensure the icon color matches the AppBar
                label: Text(
                  'Change PJP',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.white), // Adjust font size and color
                ),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AreaSelectionScreen()),
                  );
                },
              ),
            ],
            title: Text(
              globals.DisplayName ?? "",
              style: TextStyle(fontSize: 16),
            ),
          ),
          body: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 0, 10),
                                child: Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      "Today",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ))),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                  child: Container(
                                      width: 180,
                                      height: 235,
                                      child: Card(
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15.0),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            ListTile(
                                              trailing: Text(
                                                  totalOutlets.toString(),
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                              title: Text(
                                                'Total\nOutlets',
                                                style: new TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.blue),
                                              ),
                                              //leading: Text('Sussan Road',
                                              //    style: new TextStyle( fontSize: 16)),
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.grey,
                                            ),
                                            ListTile(
                                              trailing: Text(
                                                  totalVisits.toString(),
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                              title: Text('Total\nVisits',
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue)),
                                              //leading: Text('Sussan Road',
                                              //    style: new TextStyle( fontSize: 16)),
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.grey,
                                            ),
                                            ListTile(
                                              trailing: Text(
                                                  pendingVisits.toString(),
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                              title: Text('Pending\nVisits',
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue)),
                                              //leading: Text('Sussan Road',
                                              //    style: new TextStyle( fontSize: 16)),
                                            ),
                                            Divider(
                                              height: 1,
                                              color: Colors.grey,
                                            ),
                                            ListTile(
                                              trailing: Text(
                                                  totalOrders.toString(),
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black)),
                                              title: Text('Total\nOrders',
                                                  style: new TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.blue)),
                                              //leading: Text('Sussan Road',
                                              //    style: new TextStyle( fontSize: 16)),
                                            ),
                                          ],
                                        ),
                                      ))),
                              Expanded(
                                  child:
                                      Container(height: 180, child: chart())),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 12.0,
                              ),
                              Container(
                                  child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 10),
                                      child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Activities",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          )),
                                    ),
                                    Container(
                                      child: Divider(
                                        height: 1,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Attendance()),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/calendar.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.0,
                                                                5.0,
                                                                0.0,
                                                                0.0),
                                                        child: Text(
                                                          'Attendance',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () => Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PreSellRoute(2222)),
                                                  ),
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/place.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.0,
                                                                5.0,
                                                                0.0,
                                                                0.0),
                                                        child: Text(
                                                          'Visit',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: Column(
                                            children: <Widget>[
                                              Image.asset(
                                                "assets/images/complain.png",
                                                width: 55,
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.0, 5.0, 0.0, 0.0),
                                                  child: Text(
                                                    'Complaint',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      OutletRegisteration()),
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: <Widget>[
                                                Image.asset(
                                                  "assets/images/building.png",
                                                  width: 55,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.fromLTRB(
                                                      0.0, 5.0, 0.0, 0.0),
                                                  child: Text(
                                                    'Outlet Registeration',
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ),
                              SizedBox(
                                height: 12.0,
                              ),
                              Container(
                                  child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 10, 0, 10),
                                      child: Align(
                                          alignment: Alignment.topLeft,
                                          child: Text(
                                            "Reports",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold),
                                          ),
                                      ),
                                    ),
                                    Container(
                                      child: Divider(
                                        height: 1,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: <Widget>[
                                                Image.asset(
                                                  "assets/images/performance.png",
                                                  width: 55,
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0.0, 5.0, 0.0, 0.0),
                                                    child: Text(
                                                      'Performance',
                                                      style: TextStyle(
                                                          color: Colors.black),
                                                    ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              StockReportView()),
                                                      ModalRoute.withName(
                                                          "/stock_report"));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/stock.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0.0,
                                                                  5.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Stock',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                            ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushAndRemoveUntil(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            OrdersReportSelectDate()),
                                                    ModalRoute.withName(
                                                        "/order_report_select_date"));
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: <Widget>[
                                                    Image.asset(
                                                      "assets/images/order.png",
                                                      width: 55,
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.0,
                                                                5.0,
                                                                0.0,
                                                                0.0),
                                                        child: Text(
                                                          'Orders',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              SalesReportSelectDate()),
                                                      ModalRoute.withName(
                                                          "/sales_report_select_date"));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/sales.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                0.0,
                                                                5.0,
                                                                0.0,
                                                                0.0),
                                                        child: Text(
                                                          'Sales',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ))),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              OrdersSyncReportView()),
                                                      ModalRoute.withName(
                                                          "/sync_report"));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/sync.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0.0,
                                                                  5.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Orders Sync',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              AttendanceSyncReportView()),
                                                      ModalRoute.withName(
                                                          "/attendance_sync_report"));
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/sync.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                                  0.0,
                                                                  5.0,
                                                                  0.0,
                                                                  0.0),
                                                          child: Text(
                                                            'Attendance Sync',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black),
                                                          )),
                                                    ],
                                                  ),
                                                ))),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      // crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: isAfterFivePM != null &&
                                                    isAfterFivePM
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DailyReports(),
                                                      ),
                                                    );
                                                  }
                                                : null,
                                            // Disable the onTap function before
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              child: Row(
                                                children: <Widget>[
                                                  // Adding space to the left of the icon
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 38),
                                                    // Adjust the value as needed
                                                    child: Column(
                                                      children: <Widget>[
                                                        Image.asset(
                                                          "assets/images/sync.png",
                                                          width: 55,
                                                          color: isAfterFivePM
                                                              ? null
                                                              : Colors
                                                                  .grey, // Optionally, change the icon color to indicate it's disabled
                                                        ),
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 5.0),
                                                          // Adjust the top padding to add space between the icon and the text
                                                          child: Text(
                                                            'Daily reports',
                                                            style: TextStyle(
                                                              color: isAfterFivePM
                                                                  ? Colors.black
                                                                  : Colors
                                                                      .grey, // Change text color to indicate it's disabled
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ])),
    );
  }

  _showDialog(String Title, String Message) async {
    Navigator.of(context, rootNavigator: true).pop('dialog');

    if (Title == null) {
      Title = " ";
    }
    if (Message == null) {
      Message = " ";
    }

    setState(() {
      //isAnythingUploaded = 0;
      isUploaded = 0;
    });

    // flutter defined function

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(Title),
          content: new Text(Message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new ElevatedButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    ModalRoute.withName("/home"));
              },
            ),
          ],
        );
      },
    );
  }

  _showDialogFinalMessage(String Title, String Message) async {
    Navigator.of(context, rootNavigator: true).pop('dialog');

    if (Title == null) {
      Title = " ";
    }
    if (Message == null) {
      Message = " ";
    }

    setState(() {
      //isAnythingUploaded = 0;
      isUploaded = 0;
    });

    // flutter defined function

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(Title),
          content: new Text(Message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new ElevatedButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop('dialog');
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    ModalRoute.withName("/home"));
              },
            ),
          ],
        );
      },
    );
  }

  Widget chart() {
    if (PreSellData != null) {
      return new charts.PieChart(
          [
            new charts.Series<GaugeSegment, String>(
              id: 'Segments',
              domainFn: (GaugeSegment segment, _) => segment.segment,
              measureFn: (GaugeSegment segment, _) => segment.size,
              colorFn: (GaugeSegment segment, _) => segment.color,
              data: PreSellData,
            )
          ],
          animate: true,
          behaviors: [
            new charts.ChartTitle('Call Completion (%)',
                //subTitle: 'Sales (%)',
                titleStyleSpec: new charts.TextStyleSpec(
                  fontSize: 10,
                ),
                behaviorPosition: charts.BehaviorPosition.bottom,
                titleOutsideJustification:
                    charts.OutsideJustification.middleDrawArea)
          ],
          // Configure the width of the pie slices to 30px. The remaining space in
          // the chart will be left as a hole in the center. Adjust the start
          // angle and the arc length of the pie so it resembles a gauge.
          defaultRenderer: new charts.ArcRendererConfig(
              arcWidth: 30,
              startAngle: 4 / 5 * 3.1415926535897932,
              arcLength: 7 / 5 * 3.1415926535897932));
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    ),
  );
}
