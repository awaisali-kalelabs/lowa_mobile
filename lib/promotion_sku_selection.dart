/*import 'package:camera/camera.dart';*/
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
/*import 'package:order_booker/delivery.dart';*/
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/order_cart_view.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';

import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class PromotionSkuSelection extends StatefulWidget {
  int OrderId = 0;

  PromotionSkuSelection({int OrderId}) {
    this.OrderId = OrderId;
  }

  @override
  _PromotionSkuSelection createState() => _PromotionSkuSelection(OrderId);
}

class _PromotionSkuSelection extends State<PromotionSkuSelection> {
  bool _isLoading = false;
  int OrderId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> AllOrdersItemsPromotion;

  List<List<Map<String, dynamic>>> freeProducts;
  List<int> freeProductsSelectedProduct;
  List<String> freeProductsQuantity;
  List items ;
  Repository repo = new Repository();
  bool isLocationTimedOut = false;
  int _value = 0;
  _PromotionSkuSelection(int OrderId) {
    this.OrderId = OrderId;
  }

  @override
  void initState() {
    //globals.isMultipleProductsFree = 0;
    AllOrders = new List();
    items = new List();
    freeProductsSelectedProduct = new List();
    freeProductsQuantity = new List();
    freeProducts = new List();
    repo.getAllOrders(globals.OutletID, 0).then((val) async {
      setState(() {
        AllOrders = val;
      });


      for (int i = 0; i < AllOrders.length; i++) {
        repo
            .getAllAddedItemsOfOrderByIsPromotion(AllOrders[i]['id'], 1)
            .then((val) async {
          setState(() {
            AllOrdersItemsPromotion = val;
          });
          for(int j=0;j<val.length;j++){
            freeProductsSelectedProduct.add(val[j]['product_id']);
            //freeProductsQuantity
            int unitQuantity = val[j]['unit_quantity'];

            freeProductsQuantity.add(unitQuantity.toString());

            repo.getPromotionProductsFree(val[j]['promotion_id']).then((row){
              setState(() {

                freeProducts.add(row);

              });
            });
          }


        });


      }
    });
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    String selected;
    return Scaffold(
        //backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Container(

            child: Text(
              "Promotions",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white),
            ),
            alignment:
            Alignment.centerLeft,
          ),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Orders(
                            outletId: globals.OutletID,
                          )),
                );
              }),
          actions: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    onPrimary: Colors.grey, // Text Color
            ),
                child: Text('Next',
                    style: TextStyle(
                      color: Colors.white,
                    )),
                onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            OrderCartView(OrderId: globals.orderId)),
                  );
                }),
          ],
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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    5.0, 0, 2.0, 0.0),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[

                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                              "Products",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              "Qty",
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.5,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                              textAlign:
                                                                  TextAlign
                                                                      .right,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      color: Colors.blue,
                                                    ),

                                                    Flexible(
                                                        child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemCount:
                                                          AllOrdersItemsPromotion !=
                                                                  null
                                                              ? AllOrdersItemsPromotion
                                                                  .length
                                                              : 0,
                                                      itemBuilder:
                                                          itemsListPromotion,
                                                    ))
                                                  ],
                                                )))
                                      ],
                                    ),
                                  ],
                                ))),
                      ],
                    ),
                  ],
                ),
              ),
            ]));
  }

  Widget itemsListPromotion(BuildContext context, int index) {


    return InkWell(
      splashColor: Colors.blue,
      onDoubleTap: () {
        print("M tapped");
      },
      child: Column(
        children: <Widget>[
          index == 0 ? Container() : Divider(),
          Row(

            children: [
              Expanded(
                flex: 4,
                  child: DropdownButtonHideUnderline(

                child:  DropdownButton(


                    value: freeProductsSelectedProduct[index],
                    isExpanded: true,
                    items: freeProducts[index].map(
                          (val) {
                        return DropdownMenuItem<int>(
                          value: val['product_id'] ,
                          child: Text(val['package_label'], style: TextStyle(fontSize: 14),),
                        );
                      },
                    ).toList(),
                    onChanged: (value) async {

                      List<Map<String, dynamic>> product = await repo.getProductById(value);

                      repo.changePromotionProduct(AllOrdersItemsPromotion[index]['id'], value, product[0]['package_label']);

                      setState(() {
                        freeProductsSelectedProduct[index] = value;
                      });



                    }),
              ))


  ,
              Expanded(
                flex: 1,
                child: Text(
                  //AllOrdersItemsPromotion[index]['unit_quantity'].toString(),
                  freeProductsQuantity[index].toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          )
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

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                  key: key,
                  backgroundColor: Colors.black54,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Please Wait....",
                          style: TextStyle(color: Colors.white),
                        )
                      ]),
                    )
                  ]));
        });
  }
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
