/*import 'package:camera/camera.dart';*/
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
/*import 'package:order_booker/delivery.dart';*/
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/home.dart';
import 'package:order_booker/order_cart_view.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/sales_report_select_date.dart';
import 'package:order_booker/shopAction.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class AttendanceSyncReportView extends StatefulWidget {
  int OrderId = 0;

  AttendanceSyncReportView({int OrderId}) {
    this.OrderId = OrderId;
  }

  @override
  _AttendanceSyncReportView createState() => _AttendanceSyncReportView(OrderId);
}

class _AttendanceSyncReportView extends State<AttendanceSyncReportView> {
  bool _isLoading = false;
  int OrderId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> AllOrders;
  List<dynamic> SyncPosition = new List();
  Repository repo = new Repository();
  bool isLocationTimedOut = false;
  ProgressDialog signupProgressDialog;
  final GlobalKey<ScaffoldState> _scaffoldKey2 = new GlobalKey<ScaffoldState>();

  _AttendanceSyncReportView(int OrderId) {
    this.OrderId = OrderId;
  }

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    repo.initdb();
    repo.getAllAttendanceForSyncReport().then((value) => {
          setState(() {
            SyncPosition = value;
          })
        });

//    WidgetsBinding.instance
//        .addPostFrameCallback((_) => getSyncPosition());
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    //work here


    return true;
  }


  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  void getSyncPosition() async {
    //signupProgressDialog.show();
    globals.LoadingDialogs.showLoadingDialog(context, _scaffoldKey2);
    print("syncStockPosition");
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());

    String param = "timestamp=" +
        currDateTime +
        "&UserID=" +
        globals.UserID.toString() +
        "&DeviceID=" +
        globals.DeviceID +
        ""
            "&platform=android&startDate=" +
        globals.salesReportStartDate +
        "&endDate=" +
        globals.salesReportEndDate +
        "";
    var QueryParameters = <String, String>{
      "SessionID": EncryptSessionID(param),
    };
    try {
      var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncReport',
          QueryParameters);
//      Wave/grain/sales/MobileVFSyncContractExecute
      var response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      });
      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {
          print(responseBody['SyncSummary']);
          setState(() {
            SyncPosition = responseBody['SyncSummary'];
          });
        } else {
          print(responseBody.toString());
          _showDialog("Error", responseBody["error_code"], 0);
        }
      } else {
        // If that response was not OK, throw an error.

        //_showDialog("Error","An error has occured " + responseBody.statusCode);
        print(responseBody.statusCode);
      }
      Navigator.of(context, rootNavigator: true).pop('dialog');
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      _showDialog("Error", "An error has occured " + e.toString(), 0);
      print(e.toString());
    }
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    signupProgressDialog = new ProgressDialog(context, isDismissible: false);

    String selected;
    return Scaffold(
        //backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Attendance Sync Report",
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.red[800],
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    ModalRoute.withName("/home"));
              }),
        ),
        body: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 10, 5, 0),
                child: Table(
                  border: TableBorder(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                      top: BorderSide(color: Colors.grey, width: 0.5),
                      left: BorderSide(color: Colors.grey, width: 1),
                      right: BorderSide(color: Colors.grey, width: 1),
                      horizontalInside:
                          BorderSide(color: Colors.grey, width: 1),
                      verticalInside: BorderSide(color: Colors.grey, width: 1)),
                  columnWidths: {
                    0: FlexColumnWidth(1.50),
                    1: FlexColumnWidth(1.50),
                    2: FlexColumnWidth(2),
                    3: FlexColumnWidth(1),
                    4: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 14, 5, 5),
                            child: Text(
                              "ID",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,), textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 14, 5, 5),
                            child: Text(
                              "Type",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 14, 5, 5),
                            child: Text(
                              "Timestamp",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 14, 5, 5),
                            child: Text(
                              "Sync",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ), TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 12, 5, 5),
                            child: Text(
                              "Photo Sync",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),

                    ])
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Table(
                  children: SyncPosition.mapIndexed((e, index) =>
                      TableRow(children: [
                        TableCell(
                          child: Table(
                            //border: TableBorder.all,
                            border:
                                TableBorder.all(width: 0.5, color: Colors.grey),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: {
                              0: FlexColumnWidth(1.50),
                              1: FlexColumnWidth(1.50),
                              2: FlexColumnWidth(2),
                              3: FlexColumnWidth(1),
                              4: FlexColumnWidth(1),
                            },
                            children: [
                              TableRow(children: [

                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        e['mobile_request_id'].toString(),
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.left,
                                      )),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        e['attendance_type_id']==1 ? "Check In":"Check Out" ,
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.left,
                                      )),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        globals.getDisplayDateFormat(DateTime.parse(e['mobile_timestamp'].toString()))
                                         ,
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.left,
                                      )),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.all( e['is_uploaded']==1 ? 15:17),
                                      child: Image.asset(
                                        e['is_uploaded']==1 ?  "assets/images/tick.png" : "assets/images/cross.png",
                                        width: 5,
                                      )),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.all( e['is_photo_uploaded']==1 ? 15:17),
                                      child: Image.asset(
                                        e['is_photo_uploaded']==1 ?  "assets/images/tick.png" : "assets/images/cross.png",
                                        width: 5,
                                      )),
                                ),
                              ])
                            ],
                          ),
                        ),
                      ])).toList(),
                ),
              ),
            ]));
  }

  Widget itemsList(BuildContext context, int index) {
    return InkWell(
      splashColor: Colors.red,
      onDoubleTap: null,
      child: Column(
        children: <Widget>[
          index == 0 ? Container() : Divider(),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: Text(
                    SyncPosition[index]['ProductLabel'],
                    style: SyncPosition[index]['IsSubcategory'] == 1
                        ? TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                        : TextStyle(fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
                    SyncPosition[index]['IsSubcategory'] != 1
                        ? globals.getDisplayCurrencyFormat(double.tryParse(
                            SyncPosition[index]['Sync'].toString()))
                        : "",
                    //"1",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double dp(double val, int places) {
    double mod = pow(10.0, places);
    return ((val * mod).round().toDouble() / mod);
  }

  void _showDialog(String Title, String Message, int isSuccess) {
    // flutter defined function
    if (globals.isLocalLoggedIn == 1) {
      return;
    }
    showDialog(
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
                if (isSuccess == 1) {
                  Navigator.push(
                    context,
                    //

                    MaterialPageRoute(builder: (context) => ShopAction()
                        //  MaterialPageRoute(builder: (context) =>ShopAction_test()

                        ),
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmItemDelete(
      String Title, String Message, int itemId, int orderId) {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm"),
          content: new Text(Title, style: new TextStyle(fontSize: 16)),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new ElevatedButton(
              child: new Text("Delete"),
              onPressed: () {
                repo.deleteOrderItem(orderId, itemId);
                SyncPosition = new List();
                totalAmount = 0.0;
                for (int i = 0; i < AllOrders.length; i++) {
                  repo
                      .getAllAddedItemsOfOrder(AllOrders[i]['id'])
                      .then((val) async {
                    setState(() {
                      SyncPosition = val;
                      totalAddedProducts = SyncPosition.length;
                      for (int i = 0; i < SyncPosition.length; i++) {
                        totalAmount += SyncPosition[i]['amount'];
                      }
                    });
                  });
                }
                Navigator.of(context).pop();
              },
            ),
            new ElevatedButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showIndicator() {
    // flutter defined function

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.transparent,
          title: new Text("Title"),
          content: new Text("Message"),
          actions: <Widget>[],
        );
      },
    );
  }
}

//old working function
Future<void> uploadOrder222(String orderParam) async {
  print("orderParam:" + orderParam);
  var QueryParameters = <String, String>{
    "SessionID": EncryptSessionID(orderParam),
  };
  //globals.ServerURL = "192.168.30.125:8080";
  var url = Uri.http(globals.ServerURL,
      '/portal/mobile/MobileSyncOrdersV9', QueryParameters);
//      Wave/grain/sales/MobileVFSyncContractExecute
  print(url);
  var response = await http.get(url, headers: {
    HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
  });
  print(response);
  var responseBody = json.decode(utf8.decode(response.bodyBytes));
  print('called4');
  //  print(responseBody);
  if (responseBody["success"] == "true") {}
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

List<charts.Series<GaugeSegment, String>> _createSampleData(data) {
  return [
    new charts.Series<GaugeSegment, String>(
      id: 'Segments',
      domainFn: (GaugeSegment segment, _) => segment.segment,
      measureFn: (GaugeSegment segment, _) => segment.size,
      data: data,
    )
  ];
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
