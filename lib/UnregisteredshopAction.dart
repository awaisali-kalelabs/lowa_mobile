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
import 'Unregisteredorders.dart';
import 'UpdateLocation.dart';
import 'UpdateProfile.dart';
import 'globals.dart' as globals;
import 'orders.dart';

// This app is a stateful, it tracks the user's current choice.
class UnregisteredShopAction extends StatefulWidget {
  UnregisteredShopAction() {}

  @override
  _UnregisteredShopAction createState() => _UnregisteredShopAction();
}

class _UnregisteredShopAction extends State<UnregisteredShopAction> {
  _UnregisteredShopAction() {}

  Repository repo = new Repository();
  List OutletOrder = new List();
  int IsOrderPlaced = 0;
  bool updatecheck = false;



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
if( globals.IsOutletLocationUpdate == 1){
  updatecheck = true;
}else{
  updatecheck = false;
}
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
                                                          UnregisteredOrders()),
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
