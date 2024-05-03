/*import 'package:camera/camera.dart';*/
import 'package:another_flushbar/flushbar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
/*import 'package:order_booker/delivery.dart';*/
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/mark_close.dart';
import 'package:order_booker/merchandising.dart';
import 'package:order_booker/no_order.dart';
import 'package:order_booker/outlet_location.dart';
import 'package:order_booker/pre_sell_route.dart';
/*import 'package:order_booker/take_images.dart';*/
import 'package:url_launcher/url_launcher.dart';

import 'Outlet_sales_report_select_date.dart';
import 'UpdateProfile.dart';
import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class ShopAction extends StatefulWidget {
  ShopAction() {}

  @override
  _ShopAction createState() => _ShopAction();
}

class _ShopAction extends State<ShopAction> {
  _ShopAction() {}

  Repository repo = new Repository();
  List OutletOrder = new List();
  int IsOrderPlaced = 0;



  @override
  void initState() {
    print("init state");
    globals.startContinuousLocation(context);
    BackButtonInterceptor.add(myInterceptor);
    //GetOutletOrder();
print(globals.PCI_Channel_Lable);
    repo.isVisitExists(globals.OutletID).then((value) => {
      setState(() {
        IsOrderPlaced = value;
      })
    });

  }

  Future GetOutletOrder() async {
    OutletOrder = await repo.getAllOrders(globals.OutletID, 1);
    setState(() {
      OutletOrder = OutletOrder;
      if (OutletOrder.isNotEmpty && OutletOrder[0]["is_completed"] == 1) {
        //IsOrderPlaced = 1;
      }
    });

    print(OutletOrder);
  }



  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);

    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("not navigating"); // Do some stuff.
    //work here
    return true;

  }


  void ShowError(context, String message) {
    Flushbar(
      messageText: Column(
        children: <Widget>[
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
            ),
          ),
        ],
      ),
      backgroundGradient: LinearGradient(colors: [Colors.black, Colors.black]),
      icon: Icon(
        Icons.notifications_active,
        size: 30.0,
        color: Colors.teal,
      ),
      duration: Duration(seconds: 2),
      leftBarIndicatorColor: Colors.teal,
    )..show(context);
  }

  @override
  Widget build(BuildContext context) {
    String selected;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PreSellRoute(2222)),
                );
              }),
          title: Text(
            globals.OutletName,
            style: TextStyle(
                fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
                    Column(
                      children: [
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
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    5.0, 5.0, 0, 5.0),
                                                child: Icon(
                                                  Icons.location_on,
                                                  color: Colors.black,
                                                )),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.0, 5.0, 0, 5.0),
                                              child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              OutletLocation(
                                                                address: globals
                                                                    .OutletAddress,
                                                                name: globals
                                                                    .OutletName,
                                                                lat:
                                                                    globals.Lat,
                                                                lng:
                                                                    globals.Lng,
                                                                calledFrom: 2,
                                                              )),
                                                    );
                                                  },
                                                  child: Text(
                                                    globals.OutletAddress,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    5.0, 5.0, 0, 5.0),
                                                child: Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                )),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.0, 5.0, 0, 5.0),
                                              child: Text(
                                                globals.OutletOwner,
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black54,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            )
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(
                                                    5.0, 5.0, 0, 5.0),
                                                child: Icon(
                                                  Icons.phone_android,
                                                  color: Colors.black,
                                                )),
                                            Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  10.0, 5.0, 0, 5.0),
                                              child: GestureDetector(
                                                  onTap: () async {
                                                    var url = "tel:" +
                                                        globals.OutletNumber;
                                                    if (await canLaunch(url)) {
                                                      await launch(url);
                                                    } else {
                                                      throw 'Could not launch $url';
                                                    }
                                                  },
                                                  child: Text(
                                                    globals.OutletNumber==null?"":globals.OutletNumber,
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )),
                                            )
                                          ],
                                        ),
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
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                  color: HexColor("0000FF"),
                                                  elevation: 2,
                                                  child: Center(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children:[
                                                          // if(globals.PCI_Channel_Lable.contains(''))...{
                                                          //   Text(
                                                          //    "Empty",
                                                          //     style: TextStyle(
                                                          //         fontSize: 20,
                                                          //         fontWeight:
                                                          //         FontWeight
                                                          //             .bold,
                                                          //         color: Colors
                                                          //             .white),
                                                          //     textAlign: TextAlign
                                                          //         .center,
                                                          //   ),
                                                          // }else...{
                                                            Text(
                                                              globals.PCI_Channel_Lable??'Empty',
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                  color: Colors
                                                                      .white),
                                                              textAlign: TextAlign
                                                                  .center,
                                                            ),
                                                          // },
                                                      //     Text(
                                                      // globals.PCI_Channel_Lable.contains('other'),
                                                      //   style: TextStyle(
                                                      //           fontSize: 20,
                                                      //           fontWeight:
                                                      //               FontWeight
                                                      //                   .bold,
                                                      //           color: Colors
                                                      //               .white),
                                                      //       textAlign: TextAlign
                                                      //           .center,
                                                      //     ),
                                                          Text(
                                                            'Channel',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                  color: HexColor("0000FF"),
                                                  elevation: 2,
                                                  child: Center(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            globals.Visit??'Empty',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          Text(
                                                            'Visit Frequency',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                  color: HexColor("0000FF"),
                                                  elevation: 2,
                                                  child: Center(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            globals.order_created_on_date??'Empty',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          Text(
                                                            'Last Sale',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
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
                                                height: 80,
                                                alignment: Alignment.center,
                                                child: Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            0.0),
                                                  ),
                                                  color: HexColor("0000FF"),
                                                  elevation: 2,
                                                  child: Center(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                             globals.common_outlets_vpo_classifications??'Empty',
                                                            style: TextStyle(
                                                                fontSize: 20,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                          Text(
                                                            'VPO Classification',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white),
                                                            textAlign: TextAlign
                                                                .center,
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
                                      ],
                                    ))),
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 12.0,
                            ),
                            Flexible(
                                flex: 1,
                                child: Container(
                                    child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
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
                                                          Orders(
                                                              outletId: globals
                                                                  .OutletID)),
                                                );
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: <Widget>[
                                                    Image.asset(
                                                      "assets/images/mobile-shopping.png",
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
                                                          'Order',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color:
                                                                  Colors.black),
                                                        )),
                                                  ],
                                                ),
                                              )),
                                        ),
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  IsOrderPlaced == 1
                                                      ? ShowError(context,
                                                          "Order Already Placed")
                                                      : Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder:
                                                                  (context) =>
                                                                      NoOrder(
                                                                          22222)),
                                                        );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/no_order.png",
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
                                                            'No Order',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: IsOrderPlaced ==
                                                                        1
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black),
                                                          )),
                                                    ],
                                                  ),
                                                ))),
                                        /*
                                        Expanded(
                                            child: GestureDetector(
                                                onTap: () {
                                                  IsOrderPlaced == 1
                                                      ? ShowError(context,
                                                          "Order Already Placed")
                                                      :
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) => OutletClose()),
                                                    );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/marked_closed.png",
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
                                                            'Mark Close',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: IsOrderPlaced ==
                                                                        1
                                                                    ? Colors
                                                                        .grey
                                                                    : Colors
                                                                        .black),
                                                          )),
                                                    ],
                                                  ),
                                                ))),*/
                                        Expanded(
                                            child:GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            Merchandising()),
                                                  );
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Image.asset(
                                                        "assets/images/merchandising.png",
                                                        width: 55,
                                                      ),
                                                      Padding(
                                                          padding: EdgeInsets.fromLTRB(
                                                              0.0, 5.0, 0.0, 0.0),
                                                          child: Text(
                                                            'Merchandising',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors.black),
                                                          )),
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
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Updateprofile()),
                                              );

                                            },
                                          //  padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: <Widget>[
                                                Image.asset(
                                                  "assets/images/settings.png",
                                                  width: 55,
                                                ),
                                                Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0.0, 5.0, 0.0, 0.0),
                                                    child: GestureDetector(

                                                      child: Text(
                                                        'Update Profile',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black),
                                                      ),
                                                    )),
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
                                                        OutletSalesReportSelectDate()),
                                              );

                                            },
                                            //  padding: EdgeInsets.all(10),
                                            child: Column(
                                              children: <Widget>[
                                                Image.asset(
                                                  "assets/images/sales.png",
                                                  width: 55,
                                                ),
                                                Padding(
                                                    padding:
                                                    EdgeInsets.fromLTRB(
                                                        0.0, 5.0, 0.0, 0.0),
                                                    child: GestureDetector(

                                                      child: Text(
                                                        'Outlet Sales',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.black),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                        
                                      
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                          ),
                                        )
                                      ],
                                    ),

                                  ],
                                ))),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ]));


  }

  int _value = 1;
  Widget _myRadioOptionsView(BuildContext context) {
    final titles = [
      'Order',
      'No Order',
      'Mark Closed',
      'Merchandising',
      'Update Profile'
    ];
    final values = [1, 2, 3, 4, 5];
    final imagess = [
      'assets/images/mobile-shopping.png',
      'assets/images/no_order.png',
      'assets/images/alert.png',
      'assets/images/merchandising.png',
      'assets/images/settings.png'
    ];

    // final icons = ['','This is a reason multi line'];

    return ListView.builder(
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
            color: Colors.white,
            //,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,

                  //,
                  child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      color: Colors.white,
                      //shadowColor: Colors.white,

                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: Container(
                          color: Colors.white,
                          padding: EdgeInsets.all(5.0),
                          child: ListTile(
                            title: Text(
                              titles[index],
                              style: TextStyle(color: Colors.black54),
                            ),
                            trailing: Image.asset(
                              imagess[index],
                              width: 40,
                            ),
                          ),
                        ),
                      )),
                )
              ],
            ));
      },
    );
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
