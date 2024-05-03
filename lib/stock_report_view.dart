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
import 'package:order_booker/shopAction.dart';

import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class StockReportView extends StatefulWidget {
  int OrderId = 0;

  StockReportView({int OrderId}) {
    this.OrderId = OrderId;
  }

  @override
  _StockReportView createState() => _StockReportView(OrderId);
}

class _StockReportView extends State<StockReportView> {
  bool _isLoading = false;
  int OrderId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> StockPosition;
  Repository repo = new Repository();
  bool isLocationTimedOut = false;

  _StockReportView(int OrderId) {
    this.OrderId = OrderId;
  }



  @override
  void initState() {
    BackButtonInterceptor.add(myInterceptor);
    repo.getStockData().then((val) async {
      setState(() {
        StockPosition = val;

      });
    });

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
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    String selected;
    return Scaffold(
        //backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("Stock Position", style: TextStyle(fontSize: 15),),
          backgroundColor: Colors.blue[800],
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {

                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                Home()),
                        ModalRoute.withName("/home"));

              }),

        ),
        body: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    /* Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SpinKitFadingGrid(color: Colors.green),

                            ],
                          ),LinearProgressIndicator(),
                  CircularProgressIndicator(),*/

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                            child: Container(
                                width: 180,
                                // height: 235,
                                child: Column(
                                  children: <Widget>[

                                    Container(
                                        margin: EdgeInsets.fromLTRB(
                                            5.0, 10.0, 2.0, 0.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Container(
                                              padding: EdgeInsets.all(10.0),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      "Products",
                                                      style: TextStyle(
                                                          fontSize: 12.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                    ),
                                                  ),

                                                  Expanded(
                                                    flex: 2,
                                                    child: Text(
                                                      "Available Stock",
                                                      style: TextStyle(
                                                          fontSize: 12.5,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white),
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              color: Colors.blue,
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Flexible(
                                                child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: StockPosition != null
                                                  ? StockPosition.length
                                                  : 0,
                                              itemBuilder: itemsList,
                                            ))
                                          ],
                                        )),
                                  ],
                                ))),
                      ],
                    ),
                  ],
                ),
              ),
            ]));
  }

  Widget itemsList(BuildContext context, int index) {
    var lastBrand=StockPosition[index]['brand_label'].toString();
    int isBrandVisible = 1;
    var productName = lastBrand;
    if(index!=0){
      lastBrand = StockPosition[index-1]['brand_label'].toString();
      if(lastBrand != StockPosition[index]['brand_label'].toString()){
        productName = StockPosition[index]['brand_label'].toString();
        isBrandVisible = 1;

      }else{
        isBrandVisible = 0;
        productName = StockPosition[index]['package_label'].toString();
      }
    }

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
                    productName,
                    style: isBrandVisible==1 ?  TextStyle(fontSize: 13, fontWeight: FontWeight.bold):TextStyle(fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
    isBrandVisible!=1? globals.getDisplayCurrencyFormat(double.tryParse(StockPosition[index]['stock'].toString())):"" ,
                    //"1",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

            ],
          ),
          isBrandVisible==1 ? Divider():Container(),
          isBrandVisible==1? Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: Text(
                    StockPosition[index]['package_label'].toString(),
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  child: Text(
                    globals.getDisplayCurrencyFormat(double.tryParse(StockPosition[index]['stock'].toString())),
                    //"1",
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),

            ],
          ):Container()
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
                StockPosition = new List();
                totalAmount = 0.0;
                for (int i = 0; i < AllOrders.length; i++) {
                  repo
                      .getAllAddedItemsOfOrder(AllOrders[i]['id'])
                      .then((val) async {
                    setState(() {
                      StockPosition = val;
                      totalAddedProducts = StockPosition.length;
                      for (int i = 0; i < StockPosition.length; i++) {
                        totalAmount += StockPosition[i]['amount'];
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
 // globals.ServerURL = "192.168.30.125:8080";
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
