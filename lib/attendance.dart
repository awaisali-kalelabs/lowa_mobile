import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/home.dart';
import 'package:order_booker/order_cart_view.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';

import 'attendance_action.dart';
import 'globals.dart' as globals;



// This app is a stateful, it tracks the user's current choice.
class Attendance extends StatefulWidget {



  @override
  _Attendance createState() => _Attendance();
}

class _Attendance extends State<Attendance> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  
  bool isLocationTimedOut = false;
  List<Map<String, dynamic>> AllNoOrders;
  String _SelectFerightTerms;
  
  Repository repo = new Repository();
  List Days = new List();

  List<bool> isSelected = [false, false, false, false, false, false, false];

  List<Map<String, dynamic>> NoOrderReasons;

  @override
  void initState() {

    Repository repo = new Repository();

    globals.startContinuousLocation(context);


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
              /*title: Text(
                globals.OutletID.toString() + " - " + globals.OutletName,
                style: new TextStyle(color: Colors.white, fontSize: 14),
              ),*/
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Home()),
                        ModalRoute.withName("/Home"));
                  }),
              actions: [

              ]
          ),
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
                              "Please select the attendance type",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54),
                            ),
                            padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                            alignment: Alignment.topLeft,
                          ),
                          Container(
                            child: Container(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                        child:GestureDetector(

                                            onTap: () {
                                              globals.attendanceTypeId=1;
                                              Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                              builder: (context) =>
                                                  AttendanceAction()),
                                              );
                                        },
                                        child:Card(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                height: 76,
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: <Widget>[

                                                    ListTile(
                                                        leading: Image.asset(
                                                          "assets/images/attendance_sign_in.png",
                                                          width: 25,
                                                        ),
                                                        title: Text('Check In' ,
                                                          style: new TextStyle(
                                                              fontSize: 18,
                                                              color: Colors.black54),)
                                                    ),

                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                        )
                                    ),

                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                 Row(
                                  children: <Widget>[
                                    Expanded(

                                      child:GestureDetector(
                                          onTap: () {
                                            globals.attendanceTypeId=2;
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AttendanceAction()),
                                            );
                                          },
                                        child:Card(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Container(
                                                height: 76,
                                                padding: EdgeInsets.all(10),
                                                child: Column(
                                                  children: <Widget>[

                                                    ListTile(
                                                        leading: Image.asset(
                                                          "assets/images/attendance_sign_out.png",
                                                          width: 25,
                                                        ),
                                                        title: Text('Check Out'
                                                          ,
                                                          style: new TextStyle(
                                                            fontSize: 18,
                                                            color: Colors.black54),)
                                                    ),

                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      )
                                    ),

                                  ],
                                ),

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


