/*import 'package:camera/camera.dart';*/
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
class SalesReportView extends StatefulWidget {
  int OrderId = 0;

  SalesReportView({int OrderId}) {
    this.OrderId = OrderId;
  }

  @override
  _SalesReportView createState() => _SalesReportView(OrderId);
}

class _SalesReportView extends State<SalesReportView> {
  bool _isLoading = false;
  int OrderId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> AllOrders;
  List<dynamic> SalesPosition = new List();
  Repository repo = new Repository();
  bool isLocationTimedOut = false;
  ProgressDialog signupProgressDialog;
  final GlobalKey<ScaffoldState> _scaffoldKey2 = new GlobalKey<ScaffoldState>();

  _SalesReportView(int OrderId) {
    this.OrderId = OrderId;
  }

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getSalesPosition());
  }
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    //work here


    return true;
  }

  void getSalesPosition() async {
    //signupProgressDialog.show();
    globals.LoadingDialogs.showLoadingDialog(context, _scaffoldKey2);
    print("syncStockPosition");
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());


    String param="timestamp="+ currDateTime +"&UserID="+ globals.UserID.toString() +"&DeviceID="+ globals.DeviceID +""
        "&platform=android&startDate="+ globals.salesReportStartDate +"&endDate="+ globals.salesReportEndDate +"";

    var QueryParameters =<String, String> {
      "SessionID":EncryptSessionID(param) ,
    };
    try{
      var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileSalesReportV2', QueryParameters);
      //var url = Uri.http("192.168.30.125:8080", '/nisa_portal/mobile/MobileSalesReport', QueryParameters);
//      Wave/grain/sales/MobileVFSalesContractExecute
      var response = await http.get(url, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'});
      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {

            print(responseBody['SalesSummary']);
           setState(() {
             SalesPosition = responseBody['SalesSummary'];
           });

        } else {
          print(responseBody.toString());
          _showDialog("Error", responseBody["error_code"],0);

        }
      }else {
        // If that response was not OK, throw an error.

        //_showDialog("Error","An error has occured " + responseBody.statusCode);
        print(responseBody.statusCode);
      }
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }catch(e){
      Navigator.of(context, rootNavigator: true).pop('dialog');
      _showDialog("Error","An error has occured " + e.toString(),0);
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
            "Sales Report",
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.blue[800],
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SalesReportSelectDate()),
                    ModalRoute.withName("/sales_report_select_date"));
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
                      verticalInside:
                      BorderSide(color: Colors.grey, width: 1)),
                  columnWidths: {
                    0: FlexColumnWidth(3.76),
                    1: FlexColumnWidth(3.5),
                    2: FlexColumnWidth(3.5),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Products",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Order",
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Sale",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      )
                    ])
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Table(
                  border: TableBorder(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                      left: BorderSide(color: Colors.grey, width: 1),
                      right: BorderSide(color: Colors.grey, width: 1),
                      horizontalInside:
                          BorderSide(color: Colors.grey, width: 1),
                      verticalInside:
                          BorderSide(color: Colors.grey, width: 1)),
                  columnWidths: {
                    0: FlexColumnWidth(3.5),
                    1: FlexColumnWidth(1.50),
                    2: FlexColumnWidth(1.75),
                    3: FlexColumnWidth(1.50),
                    4: FlexColumnWidth(1.75),
                  },
                  children: [
                    TableRow(children: [
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Qty",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Rs",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),

                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Qty",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      ),
                      TableCell(
                        child: Container(
                            padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                            child: Text(
                              "Rs",
                              style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            )),
                      )
                    ])
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                child: Table(
                  children: SalesPosition.map((e) => TableRow(children: [
                        TableCell(
                          child: Table(
                            border: TableBorder(
                              horizontalInside: e['IsSubcategory'] == 0
                                  ? BorderSide(width: 0.5, color: Colors.grey)
                                  : BorderSide(color: Colors.white10),
                              verticalInside: e['IsSubcategory'] == 0
                                  ? BorderSide(width: 0.5, color: Colors.grey)
                                  : BorderSide(color: Colors.white10),
                              left: BorderSide(width: 1, color: Colors.grey),
                              right: BorderSide(width: 1, color: Colors.grey),
                              bottom: BorderSide(width: 0.5, color: Colors.grey),
                              top: BorderSide(width: 0.5, color: Colors.grey),
                            ),
                            //border: TableBorder.all(width: 0.5),
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            columnWidths: e['IsSubcategory'] == 0 || e['IsTotal'] == 1 ? {
                              0: FlexColumnWidth(3.5),
                              1: FlexColumnWidth(1.50),
                              2: FlexColumnWidth(1.75),
                              3: FlexColumnWidth(1.50),
                              4: FlexColumnWidth(1.75),
                            } : {
                              0: FlexColumnWidth(10),
                              1: FlexColumnWidth(1.50),
                              2: FlexColumnWidth(1.75),
                              3: FlexColumnWidth(1.50),
                              4: FlexColumnWidth(1.75),
                            },
                            children: [
                              TableRow(children: [
                                TableCell(
                                    child: Container(
                                        padding:
                                            EdgeInsets.fromLTRB(5, 5, 5, 5),
                                        child: Text(
                                          e['ProductLabel'],
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.black,
                                              fontWeight:
                                                  e['IsSubcategory'] == 1
                                                      ? FontWeight.bold
                                                      : FontWeight.normal),
                                        ))),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        e['OrderQuantity'],
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        e['OrderAmount'],
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.right,
                                      )),
                                ),

                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        e['SalesQuantity'],
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.center,
                                      )),
                                ),
                                TableCell(
                                  child: Container(
                                      padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: Text(
                                        e['SalesAmount'],
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.black),
                                        textAlign: TextAlign.right,
                                      )),
                                )
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
      splashColor: Colors.blue,
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
                    SalesPosition[index]['ProductLabel'],
                    style: SalesPosition[index]['IsSubcategory'] == 1
                        ? TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                        : TextStyle(fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
                    SalesPosition[index]['IsSubcategory'] != 1
                        ? globals.getDisplayCurrencyFormat(double.tryParse(
                            SalesPosition[index]['Sales'].toString()))
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
                SalesPosition = new List();
                totalAmount = 0.0;
                for (int i = 0; i < AllOrders.length; i++) {
                  repo
                      .getAllAddedItemsOfOrder(AllOrders[i]['id'])
                      .then((val) async {
                    setState(() {
                      SalesPosition = val;
                      totalAddedProducts = SalesPosition.length;
                      for (int i = 0; i < SalesPosition.length; i++) {
                        totalAmount += SalesPosition[i]['amount'];
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
//      Wave/grain/sales/MobileVFSalesContractExecute
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
