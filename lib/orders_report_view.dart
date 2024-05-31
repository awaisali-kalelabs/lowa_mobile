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
import 'package:order_booker/order_report_select_date.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/sales_report_select_date.dart';
import 'package:order_booker/shopAction.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class OrdersReportView extends StatefulWidget {
  int OrderId = 0;

  OrdersReportView({int OrderId}) {
    this.OrderId = OrderId;
  }

  @override
  _OrdersReportView createState() => _OrdersReportView(OrderId);
}

class _OrdersReportView extends State<OrdersReportView> {
  bool _isLoading = false;
  int OrderId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> AllOrders;
  List<dynamic> OrdersPosition = new List();
  Repository repo = new Repository();
  bool isLocationTimedOut = false;
  ProgressDialog signupProgressDialog;
  final GlobalKey<ScaffoldState> _scaffoldKey2 = new GlobalKey<ScaffoldState>();

  _OrdersReportView(int OrderId) {
    this.OrderId = OrderId;
  }

  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getOrdersPosition());




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
  void getOrdersPosition() async {
    //signupProgressDialog.show();
    globals.LoadingDialogs.showLoadingDialog(context, _scaffoldKey2);
    print("syncStockPosition");
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());


    String param="timestamp="+ currDateTime +"&UserID="+ globals.UserID.toString() +"&DeviceID="+ globals.DeviceID +""
        "&platform=android&startDate="+ globals.ordersReportStartDate +"&endDate="+ globals.ordersReportEndDate +"";
    print(EncryptSessionID(param));
    var QueryParameters =<String, String> {
      "SessionID":EncryptSessionID(param) ,
    };
    try{
      var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileOrdersReportV2', QueryParameters);
//      Wave/grain/sales/MobileVFOrdersContractExecute
      var response = await http.get(url, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'});
      var responseBody = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (responseBody["success"] == "true") {

            print(responseBody['OrdersSummary']);
           setState(() {
             OrdersPosition = responseBody['OrdersSummary'];
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
            "Orders Report",
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
                            OrdersReportSelectDate()),
                    ModalRoute.withName("/sales_report_select_date"));
              }),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Date: ${OrdersPosition.isNotEmpty ? OrdersPosition[0]["Date"].toString() : ""}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'So Name: ${OrdersPosition.isNotEmpty ? OrdersPosition[0]["SoName"].toString() : ""}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blue),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Zone: ${OrdersPosition.isNotEmpty ? OrdersPosition[0]["Zone"].toString() : ""}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blue // Change this color to whatever you prefer
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Area: ${OrdersPosition.isNotEmpty ? OrdersPosition[0]["Area"].toString() : ""}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blue // Change this color to whatever you prefer
                  ),
                ),
              ),
            ),



            Expanded(
              child: ListView(
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
                          0: FlexColumnWidth(6),
                          1: FlexColumnWidth(5),

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
                          0: FlexColumnWidth(6),
                          1: FlexColumnWidth(2.5),
                          2: FlexColumnWidth(2.5),
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
                          ])
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      child: Table(
                        children: OrdersPosition.map((e) => TableRow(children: [
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
                                  columnWidths:  {
                                    0: FlexColumnWidth(6),
                                    1: FlexColumnWidth(2.5),
                                    2: FlexColumnWidth(2.5),
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
                                    ])
                                  ],
                                ),
                              ),
                            ])).toList(),
                      ),
                    ),
                  ]),
            ),
          ],
        ));
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
                    OrdersPosition[index]['ProductLabel'],
                    style: OrdersPosition[index]['IsSubcategory'] == 1
                        ? TextStyle(fontSize: 13, fontWeight: FontWeight.bold)
                        : TextStyle(fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
                    OrdersPosition[index]['IsSubcategory'] != 1
                        ? globals.getDisplayCurrencyFormat(double.tryParse(
                            OrdersPosition[index]['Orders'].toString()))
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
                OrdersPosition = new List();
                totalAmount = 0.0;
                for (int i = 0; i < AllOrders.length; i++) {
                  repo
                      .getAllAddedItemsOfOrder(AllOrders[i]['id'])
                      .then((val) async {
                    setState(() {
                      OrdersPosition = val;
                      totalAddedProducts = OrdersPosition.length;
                      for (int i = 0; i < OrdersPosition.length; i++) {
                        totalAmount += OrdersPosition[i]['amount'];
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
  //globals.ServerURL = "192.168.30.125:8080";f
  var url = Uri.http(globals.ServerURL,
      '/portal/mobile/MobileSyncOrdersV9', QueryParameters);
//      Wave/grain/sales/MobileVFOrdersContractExecute
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
