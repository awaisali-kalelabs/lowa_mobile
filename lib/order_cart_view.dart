/*import 'package:camera/camera.dart';*/
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
/*import 'package:order_booker/delivery.dart';*/
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/globals.dart';
import 'package:order_booker/no_order.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';
import 'package:another_flushbar/flushbar.dart';

import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class OrderCartView extends StatefulWidget {
  int OrderId = 0;

  OrderCartView({int OrderId}) {
    this.OrderId = OrderId;
  }

  @override
  _OrderCartView createState() => _OrderCartView(OrderId);
}

class _OrderCartView extends State<OrderCartView> {
  bool _isLoading = false;
  int OrderId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> AllOrdersItems;
  List<Map<String, dynamic>> AllOrdersItemsPromotion;
  List<String> freeProductsQuantity;
  Repository repo = new Repository();
  bool isLocationTimedOut = false;
  bool isDiscountAllowed = false;
  TextEditingController discountController = TextEditingController();
  double priceRateAfterDiscount = 0.0;
  double priceRate = 0.0;
  double maximumDiscount = 0;
  double defaultDiscount = 0;
  int DiscountIDmain = 0;
  bool isLoading = false;

  _OrderCartView(int OrderId) {
    this.OrderId = OrderId;
  }



  @override
  void initState() {

    AllOrders = new List();
    freeProductsQuantity = new List();
    repo.getAllOrders(globals.OutletID, 0).then((val) async {
      setState(() {
        AllOrders = val;
      });

      AllOrdersItems = new List();
      for (int i = 0; i < AllOrders.length; i++) {
        repo.getAllAddedItemsOfOrderByIsPromotion(AllOrders[i]['id'], 0).then((val) async {
          setState(() {
            AllOrdersItems = val;
            totalAddedProducts = AllOrdersItems.length;
            for (int i = 0; i < AllOrdersItems.length; i++) {
              totalAmount += AllOrdersItems[i]['amount'];
            }
          });
        });

        repo.getAllAddedItemsOfOrderByIsPromotion(AllOrders[i]['id'], 1).then((val) async {
          setState(()   {
            AllOrdersItemsPromotion = val;
            for(int i=0;i<val.length;i++){



              int unitQuantity = val[i]['unit_quantity'];
              freeProductsQuantity.add(unitQuantity.toString());


              /*
              int unitQuantity = val[i]['unit_quantity'];
              repo.getProductById(val[i]['product_id']).then((product) {
                //List<Map<String, dynamic>> product = await repo.getProductById(val[i]['product_id']);
                int unitPerCase = product[0]['unit_per_case'];
                int units = unitQuantity%unitPerCase;
                int rawCase = 0;
                if(units!=unitQuantity){
                  rawCase =  ((unitQuantity-units)/unitPerCase).toInt();
                }
                freeProductsQuantity.add(rawCase.toString()+"/"+units.toString());
              });*/


            }


          });

        });

      }
    });
    globals.isFeatureAllowed(411).then((value)  {
      setState(() {
        isDiscountAllowed = value;
      });
    });
   /* repo.getSpotDiscount(globals.productId).then((value) => {
      setState(() {
        if(value==null){

          DiscountID = 0;
          maximumDiscount = 0;
          discountController.text = defaultDiscount==null ? "0": defaultDiscount.toString();

        }else{

          DiscountID = value['product_id'];
          defaultDiscount = value['default_discount'];
          maximumDiscount = value['maximum_discount'];
          discountController.text = defaultDiscount==null ? "0": defaultDiscount.toString();

        }

        print("defaultDiscount : " + defaultDiscount.toString());
        print("maximumDiscount : " + maximumDiscount.toString());
      })
    });*/
    _getLocation();
  }
  double _latitude = 0.0;
  double _longitude = 0.0;
  double Accuracy = 0.0;
  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        Accuracy = position.accuracy;

      });
    } catch (e) {
      print("Error: $e");
    }
  }
  void setStateGeo() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    globals.channellat = position.latitude;
    globals.channellng = position.longitude;
    globals.channelacc = position.accuracy;
  }
  double _calculateDistance() {
    double latDouble = double.parse(globals.IsGeoFenceLat);
    double lngDouble = double.parse(globals.IsGeoFenceLng);
    double distanceInMeters = Geolocator.distanceBetween(
      _latitude,
      _longitude,
      latDouble,
      lngDouble,
    );

    // Convert the distance to other units if needed
    // For example, to kilometers: distanceInKm = distanceInMeters / 1000;

    return distanceInMeters;
  }
/*
  onDiscountChange(val){

    if(val==null){
      val="0";
    }
    priceRateAfterDiscount = priceRate;

    String errorMessage = "Discount cannot be greater than rate";
    if(double.parse(discountController.text)>maximumDiscount){
      errorMessage = "Discount cannot be greater than " + maximumDiscount.toString() + "";
    }
    if(double.parse(discountController.text)<defaultDiscount){
      errorMessage = "Discount cannot be less than " + defaultDiscount.toString() + "";
    }
   // print("check......................................");
   // print("maximumDiscount==> " + maximumDiscount.toString());
  //  print("discountController 1==> " + discountController.text.toString());

    if (double.parse(discountController.text) < priceRate && double.parse(discountController.text)<=maximumDiscount) {
      priceRateAfterDiscount = priceRate - double.parse(discountController.text);
      print("discountController==> " + discountController.text.toString());
      print("priceRateAfterDiscount==> " + priceRateAfterDiscount.toString());

    } else {
      Flushbar(
        messageText: Column(
          children: <Widget>[
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundGradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black
            ]),
        icon: Icon(
          Icons.notifications_active,
          size: 30.0,
          color: Colors.blue,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Colors.blue,
      )..show(context);
    }
  }
*/
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    String selected;
    return Scaffold(
      //backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
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
         /*   ElevatedButton(
              style: ElevatedButton.styleFrom(
                  onPrimary: Colors.grey, // Text Color
              ),
              child: Text('Save',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              onPressed: AllOrdersItems==null || AllOrdersItems.isEmpty
                  ? null
                  : () {
                *//* _UploadOrder();*//*
                //  _showIndicator();
                completeOrder(context);
                //_UploadDocuments();

              },
            ),*/
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.grey, // Text Color
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                color: Colors.white, // Loader color
              )
                  : Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: AllOrdersItems == null || AllOrdersItems.isEmpty
                  ? null
                  : () async {
                setState(() {
                  isLoading = true; // Show loader
                });

                await completeOrder(context); // Execute your function

                setState(() {
                  isLoading = false; // Hide loader
                });
              },
            )
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
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 80,
                                            alignment: Alignment.center,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(0.0),
                                              ),
                                              color: HexColor("0000FF"),
                                              elevation: 2,
                                              child: Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        totalAddedProducts
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color:
                                                            Colors.white),
                                                        textAlign:
                                                        TextAlign.center,
                                                      ),
                                                      Text(
                                                        "Total Items",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                            Colors.white),
                                                        textAlign:
                                                        TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        Expanded(
                                          child: Container(
                                            // width: cardWidth,
                                            height: 80,
                                            alignment: Alignment.center,
                                            child: Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(0.0),
                                              ),
                                              color: HexColor("0000FF"),
                                              elevation: 2,
                                              child: Center(
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      Text(
                                                        globals
                                                            .getDisplayCurrencyFormat(
                                                            dp(totalAmount,
                                                                0))
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                            FontWeight.bold,
                                                            color:
                                                            Colors.white),
                                                        textAlign:
                                                        TextAlign.center,
                                                      ),
                                                      Text(
                                                        'Total Amount',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            color:
                                                            Colors.white),
                                                        textAlign:
                                                        TextAlign.center,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )

                                      ],
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(child:
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
                                                          flex: 3,
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
                                                          flex: 1,
                                                          child: Text(
                                                            "Rate",
                                                            style: TextStyle(
                                                                fontSize: 12.5,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: Colors.white),
                                                            textAlign:
                                                            TextAlign.center,
                                                          ),
                                                        ),
                                                      /*  Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            "Disc",
                                                            style: TextStyle(
                                                                fontSize: 12.5,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: Colors.white),
                                                            textAlign:
                                                            TextAlign.center,
                                                          ),
                                                        ),*/
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            "Qty",
                                                            style: TextStyle(
                                                                fontSize: 12.5,
                                                                fontWeight:
                                                                FontWeight.bold,
                                                                color: Colors.white),
                                                            textAlign:
                                                            TextAlign.center,
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            "Amount",
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
                                                        itemCount: AllOrdersItems != null
                                                            ? AllOrdersItems.length
                                                            : 0,
                                                        itemBuilder: itemsList,
                                                      ))
                                                ],
                                              )),)]),



                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child:
                                        Container(

                                            margin: EdgeInsets.fromLTRB(
                                                5.0, 10.0, 2.0, 0.0),

                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                              children: <Widget>[
                                                SizedBox(height: 30,),
                                                Container(
                                                  padding: EdgeInsets.all(10), child: Text("Promotions", style:
                                                TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Colors.white),), alignment: Alignment.centerLeft,
                                                  color: Colors.blue,
                                                ),
                                                SizedBox(height: 10,),
                                                Container(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          "Products",
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Colors.black),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          "Qty",
                                                          style: TextStyle(
                                                              fontSize: 12.5,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Colors.black),
                                                          textAlign:
                                                          TextAlign.right,
                                                        ),
                                                      ),

                                                    ],
                                                  ),
                                                  color: Colors.black12,
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Flexible(
                                                    child: ListView.builder(
                                                      shrinkWrap: true,
                                                      physics:
                                                      const NeverScrollableScrollPhysics(),
                                                      itemCount: AllOrdersItemsPromotion != null
                                                          ? AllOrdersItemsPromotion.length
                                                          : 0,
                                                      itemBuilder: itemsListPromotion,
                                                    ))
                                              ],
                                            ))),

                                      ],),
                                   /* Row(
                                      children :[
                                        Expanded(
                                            child: Container(
                                              // width: cardWidth,
                                              padding: EdgeInsets.all(5.0),
                                              child: TextFormField(
                                                // Your existing properties...
                                                enabled: isDiscountAllowed,
                                                enableInteractiveSelection: isDiscountAllowed,
                                                controller: discountController,
                                                keyboardType: TextInputType.number,
                                                autofocus: false,
                                                onChanged: (val) {
                                                  //ToReset Value to initial
                                              //    onDiscountChange(val);
                                                },
                                                decoration: InputDecoration(
                                                  enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Colors.black12, width: 1.0),
                                                  ),
                                                  labelText: 'Discount',
                                                ),
                                              )

                                            )),
                                      ]
                                    )*/

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
        _confirmItemDelete(
            AllOrdersItemsPromotion[index]['product_label'].toString(),
            "Do you want to delete this product?",
            AllOrdersItemsPromotion[index]['product_id'],
            AllOrdersItemsPromotion[index]['order_id'],-1);
      },
      child: Column(
        children: <Widget>[
          index == 0 ? Container() : Divider(),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  //padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    AllOrdersItemsPromotion[index]['product_label'].toString(),

                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),


              Expanded(
                flex: 1,
                child: Text(
                  //AllOrdersItemsPromotion[index]['unit_quantity'].toString(),
                  freeProductsQuantity[index],
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
                ),
              ),

            ],
          )
        ],
      ),
    );
  }
  Widget itemsList(BuildContext context, int index) {
    return InkWell(
      splashColor: Colors.blue,
      onDoubleTap: () {
        print("M tapped");
        _confirmItemDelete(
            AllOrdersItems[index]['product_label'].toString(),
            "Do you want to delete this product?",
            AllOrdersItems[index]['product_id'],
            AllOrdersItems[index]['order_id'],AllOrdersItems[index]['id']);
      },
      child: Column(
        children: <Widget>[
          index == 0 ? Container() : Divider(),
          Row(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  child: Text(
                    AllOrdersItems[index]['product_label'].toString(),
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text(
                    globals
                        .getDisplayCurrencyFormatTwoDecimal(
                        AllOrdersItems[index]['rate'])
                        .toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            /*  Expanded(
                flex: 1,
                child: Text(
                    globals
                        .getDisplayCurrencyFormatTwoDecimal(
                        AllOrdersItems[index]['discount'])
                        .toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 12)),
              ),*/
              Expanded(
                flex: 1,
                child: Text(
                  AllOrdersItems[index]['quantity'].toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  globals
                      .getDisplayCurrencyFormat(AllOrdersItems[index]['amount'])
                      .toString(),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 12),
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

  Future completeOrder(context) async {
    print("IsGeoFenceLat=="+globals.IsGeoFenceLat);
    print("IsGeoFvenceLng=="+globals.IsGeoFenceLng);
    List OutletData = new List();
    OutletData = await repo.SelectOutletByID(globals.OutletID);
    globals.IsGeoFence = OutletData[0]["IsGeoFence"];
    globals.IsGeoFenceLat = OutletData[0]["lat"];
    globals.IsGeoFenceLng = OutletData[0]["lng"];
    globals.Radius = OutletData[0]["Radius"];
//31.6089111000000000000
    //71.0783096000000000000
    print("_latitude===>"+_latitude.toString());
    print("lng===>"+_longitude.toString());
    print("IsGeoFence"+globals.IsGeoFence.toString());
    print("IsGeoFenceLat"+globals.IsGeoFenceLat);
    print("IsGeoFvenceLng"+globals.IsGeoFenceLng);
    Dialogs.showLoadingDialog(context, _keyLoader);
    double distance = _calculateDistance();
    print("Distance==>"+distance.toString());
    int Distance2 = globals.Radius;
    Position position=globals.currentPosition;
    if ( globals.IsGeoFence == 0 ||  globals.IsGeoFence == null || globals.IsGeoFence == "0") {
      if(position==null){
        globals.getCurrentLocation(context).then((position1) {
          position = position1;
          print(position1);
        })
            .timeout(Duration(seconds: 7), onTimeout: ((){
          print("i am here timedout");

          setState(() {
            isLocationTimedOut = true;

          });

        }))
            .whenComplete(() async {
          print("inside if");
          if (position != null || isLocationTimedOut) {
            // Only set position to (0,0,0) if necessary
            if (isLocationTimedOut && position == null) {
              position = Position(accuracy: 0, latitude: 0, longitude: 0);
            }

            print("position: ${position.toString()}");

            // Only proceed if position is valid
            if (position.latitude != 0 && position.longitude != 0) {
              await repo.completeOrder(position.latitude, position.longitude, position.accuracy, globals.OutletID);
            } else {
              print("Position is invalid or timed out; handling alternative logic if needed.");
            }

            await repo.setVisitType(globals.OutletID, 1);
            Navigator.of(context, rootNavigator: true).pop('dialog');
            _UploadOrder(context);
            _UploadDocuments();

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => PreSellRoute(2222)),
                ModalRoute.withName("/PreSellRoute"));
          }
else {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Alert"),
                  content: new Text("Please allow location to proceed"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new ElevatedButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShopAction()),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }



          //    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        });
      }else{
        Navigator.of(context, rootNavigator: true).pop('dialog');
        print("position:"+position.toString());
        await repo.completeOrder( position.latitude,position.longitude,position.accuracy, globals.OutletID);
        await repo.setVisitType(globals.OutletID, 1);
        _UploadOrder(context);
        _UploadDocuments();
        Navigator.pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PreSellRoute(2222)),
            ModalRoute.withName("/PreSellRoute"));
      }
    }else{
      if(distance < Distance2){
        print("inside if");
        Position position = globals.currentPosition;
        await repo.completeOrder(position.latitude,position.longitude,
            position.accuracy, globals.OutletID);
        await repo.setVisitType(globals.OutletID, 1);
        Navigator.of(context, rootNavigator: true).pop('dialog');
//            //1	1	Test Outlet K/S	1	System	MANDI TOWN	03001234747		1	31.6089111000000000000	71.0783096000000000000	Lahore 	Sub Area Label 4	1	6	Karyana Store	2024-03-14	E	7	System	03001234747		1	100
        ///.................................Upload Orders Method.........................
        _UploadOrder(context);
        _UploadDocuments();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => PreSellRoute(2222)),
            ModalRoute.withName("/PreSellRoute"));
      }else {

        print("inside Else");

        Navigator.of(context, rootNavigator: true).pop('dialog');
        showDialog(
          context: context,
          builder: (BuildContext context) {
            // return object of type Dialog
            return AlertDialog(
              title: new Text("Error"),
              content: new Text(
                  'Can\'t place order, you are ${distance
                      .toInt()} meters away from the shop.'),
              actions: <Widget>[
                // usually buttons at the bottom of the dialog
                new ElevatedButton(
                  child: new Text("Close"),
                  onPressed: () {
                    Navigator.pop(
                      context,
                      MaterialPageRoute(builder: (context) => OrderCartView()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }    }



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
              _showDialog("Error", responseBody["error_code"], 0);
            }
          } else {
            // If that response was not OK, throw an error.

            //await _showDialog("Error Uploading No Order", "An error has occured " + responseBody.statusCode);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          //await _showDialog("Error Uploading No Order", "An error has occured " + e.toString());
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);

      }
    });
  }

  Future _UploadOrder(context) async {

    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());
    var str = currDateTime.split(".");

    String TimeStamp = str[0];

    print("currDateTime" + TimeStamp);

    int ORDERIDToDelete = 0;
    AllOrders = new List();
    await repo.getAllOrdersByIsUploaded(0).then((val) async {

      AllOrders = val;
      /*
      setState(() {
        AllOrders = val;

        print("MAIN ORDER" + AllOrders.toString());
      });
      */
      AllOrdersItems = new List();
      print(AllOrders.toString());
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
            AllOrders[i]['lat'] +
            "&lng=" +
            AllOrders[i]['lng'] +
            "&accuracy=" +
            AllOrders[i]['accuracy'] +
            "&PJP=" +
            AllOrders[i]['PJP'].toString() +
        "&version=" +
            appVersion +
            "&Spot_Discount=" +
            discountController.text ;

        ORDERIDToDelete = AllOrders[i]['id'];
        await repo
            .getAllAddedItemsOfOrder(AllOrders[i]['id'])
            .then((val) async {
          AllOrdersItems = val;
          /*
          setState(() {
            AllOrdersItems = val;
            print("ITEMS" + AllOrdersItems.toString());
          });
          */
          print("orderParam 1 :" + orderParam.toString());
          String orderItemParam = "";
          for (int j = 0; j < AllOrdersItems.length; j++) {
            orderParam += "&product_id=" +
                AllOrdersItems[j]['product_id'].toString() +
                "&quantity=" +
                AllOrdersItems[j]['quantity'].toString() +
                "&discount=" +
                AllOrdersItems[j]['discount'].toString() +
                "&unit_quantity=" +
                AllOrdersItems [j]['unit_quantity'].toString() +
                "&is_promotion=" +
                AllOrdersItems [j]['is_promotion'].toString() +
                "&promotion_id=" +
                AllOrdersItems [j]['promotion_id'].toString() +
                "&Spot_Discount_ID=" +
                AllOrdersItems [j]['DiscountID'].toString() +
                "&defaultDiscount=" +
                AllOrdersItems [j]['defaultDiscount'].toString() +
                "&maximumDiscount=" +
                AllOrdersItems [j]['maximumDiscount'].toString() +
                "";
          }
        });
        print("orderParam: "+orderParam.toString());
        var QueryParameters = <String, String>{
          "SessionID": EncryptSessionID(orderParam),
        };

        var url =
        Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncOrdersV13');
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
          print("bhai :"+response.statusCode.toString());
          if (response.statusCode == 200) {
          //  print();
            if (responseBody["success"] == "true") {
              await repo.markOrderUploaded(ORDERIDToDelete);
             // _showDialog("Success","order uploaded. ",1);

            } else {
              _showDialog("Error", responseBody["error_code"], 0);
            }
          } else {
            // If that response was not OK, throw an error.

            //_showDialog("Error", "An error has occured " + responseBody.statusCode, 0);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          //_showDialog("Error", "An error has occured " + e.toString(), 1);
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);

      }

    });
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
      String Title, String Message, int itemId, int orderId, int sourceId) {
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
                repo.deleteOrderItemBySourceId(orderId, sourceId);
                AllOrdersItems = new List();
                totalAmount = 0.0;
                for (int i = 0; i < AllOrders.length; i++) {
                  repo.getAllAddedItemsOfOrderByIsPromotion(AllOrders[i]['id'], 0).then((val) async {
                    setState(() {
                      AllOrdersItems = val;
                      totalAddedProducts = AllOrdersItems.length;
                      for (int i = 0; i < AllOrdersItems.length; i++) {
                        totalAmount += AllOrdersItems[i]['amount'];
                      }
                    });
                  });


                  repo.getAllAddedItemsOfOrderByIsPromotion(AllOrders[i]['id'], 1).then((val) async {
                    setState(() {
                      AllOrdersItemsPromotion = val;
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
