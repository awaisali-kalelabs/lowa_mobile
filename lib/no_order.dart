import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/order_cart_view.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';
import 'package:intl/intl.dart';

import 'globals.dart' as globals;

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(NoOrder(globals.OutletID));
}

// This app is a stateful, it tracks the user's current choice.
class NoOrder extends StatefulWidget {
  int OutletId;

  NoOrder(OutletId) {
    this.OutletId = OutletId;

    print(OutletId);
  }
  @override
  _NoOrder createState() => _NoOrder(OutletId);
}

class _NoOrder extends State<NoOrder> {
  int OutletId;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String selected;
  int weekday;
  int noOrderReason;
  bool isLocationTimedOut = false;
  List<Map<String, dynamic>> AllNoOrders;
  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> AllOrdersItems;
  String _SelectFerightTerms;
  _NoOrder(OutletId) {
    this.OutletId = OutletId;
  }
  Repository repo = new Repository();
  List Days = new List();

  List<bool> isSelected = [false, false, false, false, false, false, false];

  List<Map<String, dynamic>> NoOrderReasons;

  @override
  void initState() {
    //NoOrderReasons=new List();
    noOrderReason = 0;

    Repository repo = new Repository();
    //weeK DAY to be Placed
    weekday = globals.WeekDay;

    NoOrderReasons = new List();

    repo.getNoOrderReasons().then((val) {
      setState(() {
        NoOrderReasons = val;
      });
    });

    if (weekday > 0) {
      isSelected[weekday - 1] = true;
    } else {
      isSelected[0] = true;
    }
  }

  setNoOrderReason(int val) {
    setState(() {
      noOrderReason = val;
    });
  }

  saveNoOrder() {
    Dialogs.showLoadingDialog(context, _keyLoader);
    Position position=globals.currentPosition;
    if(position==null){
      globals.getCurrentLocation(context).then((position1) {
        position = position1;
      })
          .timeout(Duration(seconds: 7), onTimeout: ((){
        print("i am here timedout");

        setState(() {
          isLocationTimedOut = true;
        });

      }))

          .whenComplete(() {

        double lat = 0.0;
        double lng = 0.0;
        double accuracy = 0.0;
        print(position);
        if (position != null || isLocationTimedOut) {
          if(isLocationTimedOut==false){
            lat = position.latitude;
            lng = position.longitude;
            accuracy = position.accuracy;
          }

          print(position);
          repo.saveNoOrder(
              globals.getUniqueMobileId(),
              globals.OutletID,
              noOrderReason,
              lat,
              lng,
              accuracy,
              globals.DeviceID);
          Navigator.of(context, rootNavigator: true).pop('dialog');
          _UploadNoOrder();
          _UploadOrder(context);
          repo.setVisitType(globals.OutletID, 2).then((value) {
            Navigator.push(
              context,
              //

              MaterialPageRoute(builder: (context) => PreSellRoute(1)
                //  MaterialPageRoute(builder: (context) =>ShopAction_test()

              ),
            );
          });
        } else {
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
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              });
        }
      });
    }else{
      repo.saveNoOrder(
          globals.getUniqueMobileId(),
          globals.OutletID,
          noOrderReason,
          position.latitude,
          position.longitude,
          position.accuracy,
          globals.DeviceID);
      Navigator.of(context, rootNavigator: true).pop('dialog');
      _UploadNoOrder();
      _UploadOrder(context);
      repo.setVisitType(globals.OutletID, 2).then((value) {
        Navigator.push(
          context,
          //

          MaterialPageRoute(builder: (context) => PreSellRoute(1)
            //  MaterialPageRoute(builder: (context) =>ShopAction_test()

          ),
        );
      });
    }

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
      setState(() {
        AllOrders = val;

        print("MAIN ORDER" + AllOrders.toString());
      });
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
            AllOrders[i]['accuracy'];

        ORDERIDToDelete = AllOrders[i]['id'];
        await repo
            .getAllAddedItemsOfOrder(AllOrders[i]['id'])
            .then((val) async {
          setState(() {
            AllOrdersItems = val;
            print("ITEMS" + AllOrdersItems.toString());
          });
          String orderItemParam = "";
          for (int j = 0; j < AllOrdersItems.length; j++) {
            orderParam += "&product_id=" +
                AllOrdersItems[j]['product_id'].toString() +
                "&quantity=" +
                AllOrdersItems[j]['quantity'].toString() +
                "&discount=" +
                AllOrdersItems[j]['discount'].toString() +
                "&unit_quantity=0&is_promotion=0&promotion_id=0";
          }
        });

        var QueryParameters = <String, String>{
          "SessionID": EncryptSessionID(orderParam),
        };

        var url =
        Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncOrdersV9');
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
              await repo.markOrderUploaded(ORDERIDToDelete);
              //_showDialog("Success","order uploaded. ",1);

            } else {
               _showDialog("Error Uploading Order", responseBody["error_code"], 0);
            }
          } else {
            // If that response was not OK, throw an error.

            //await _showDialog("Error Uploading Order", "An error has occured " + responseBody.statusCode);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          //await _showDialog("Error Uploading Order", "An error has occured " + e.toString());
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);

      }
    });
  }

  Future _UploadNoOrder() async {
    String TimeStamp = globals.getCurrentTimestamp();
    print("currDateTime" + TimeStamp);
    int ORDERIDToDelete = 0;
    AllNoOrders = new List();
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

  void ShowError(context) {
    Flushbar(
      messageText: Column(
        children: <Widget>[
          Text(
            "Please select the reason to proceed.",
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

  Widget _getNoOrderReasonsList(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        index == 0 ? Container() : Divider(),
        Container(
          child: RadioListTile(
            value: NoOrderReasons[index]['id'],
            groupValue: noOrderReason,
            title: Text("" + NoOrderReasons[index]['label'],
                style: new TextStyle(fontSize: 16, color: Colors.black54)),
            //subtitle: Text("Radio 1 Subtitle"),
            onChanged: (val) {
              print("Radio Tile pressed $val");
              setNoOrderReason(val);
            },
            activeColor: Colors.orange[200],

            selected: true,
          ),
        )
      ],
    );
  }

  double cardWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    cardWidth = width / 1.1;
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          appBar: AppBar(
              backgroundColor: Colors.red[800],
              title: Text(
                globals.OutletID.toString() + " - " + globals.OutletName,
                style: new TextStyle(color: Colors.white, fontSize: 14),
              ),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShopAction()),
                        ModalRoute.withName("/ShopAction"));
                  }),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      onPrimary: Colors.grey, // Text Color
                  ),
                  child: Text('Save',
                      style: TextStyle(
                        color: noOrderReason == 0 ? Colors.grey : Colors.white,
                      )),

                  onPressed: () {
                    /* _UploadOrder();*/
                    //  _showIndicator();
                    noOrderReason == 0 ? ShowError(context) : saveNoOrder();
                  },
                ),
              ]),
          body: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: [
                          Container(
                            child: Text(
                              "Please select the reason for not placing an order",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            alignment: Alignment.topLeft,
                          ),
                          Container(
                            //  width: cardWidth,

                            child: Container(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(
                                    child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: ClampingScrollPhysics(),
                                  itemCount: NoOrderReasons.length,
                                  itemBuilder: _getNoOrderReasonsList,
                                )),
                              ],
                            )),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ])),
    );
  }
}
