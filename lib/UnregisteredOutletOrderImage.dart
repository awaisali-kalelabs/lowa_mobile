import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:order_booker/shopAction.dart';

import 'UnregisteredshopAction.dart';
import 'com/pbc/dao/repository.dart';
import 'com/pbc/model/outlet_orders.dart';
//import 'get_total_chillers.dart';
import 'globals.dart' as globals;
import 'globals.dart';
import 'orders.dart';

class UnregisteredOutletOrderImage extends StatefulWidget {

  @override
  _UnregisteredOutletOrderImage createState() => _UnregisteredOutletOrderImage();
}

class _UnregisteredOutletOrderImage extends State<UnregisteredOutletOrderImage> {
  int OrderID = 0;
  @override
  void initState() {
    super.initState();
    OrderID = getOrderNumber(0);
    print("OrderID :"+OrderID.toString());
  }

  void addTimestamp(orderId) async {
    //await repo.insertOutletOrderTimestamp(orderId, 1);
    //await repo.insertOutletOrderTimestamp(orderId, 2);
  }

  void initiateOrder(List<OutletOrders> order) {
    for (var i = 0; i < order.length; i++) {
      repo.initOrder(
          order[i].id,
          order[i].outlet_id,
          order[i].is_completed,
          order[i].is_uploaded,
          order[i].total_amount,
          order[i].uuid,
          order[i].created_on,
          order[i].lat,
          order[i].lng,
          order[i].accuracy,
          globals.selectedPJP);
    }
    // for (int i = 0; i < globals.serialNoController.length; i++) {
    //   repo.insertChiller(order[0].id, globals.serialNoController[i].text);
    // }
  }

  int getOrderNumber(int outletId) {
    List AllOrders = new List();
    repo.getAllOrders(outletId, 0).then((val) {
      setState(() {
        AllOrders = val;
      });
print("AllOrders ::"+AllOrders.toString());
      if (AllOrders.length < 1) {
        List<OutletOrders> order = new List();
        var currDate = new DateTime.now();
        String currentDat = currDate.toString();
        var str2 = currentDat.split(".");
        var str = currDate.toString();
        str = str.replaceAll("-", "");
        str = str.replaceAll(" ", "");
        str = str.replaceAll(":", "");
        // if (globals.sparkMobileRequestId == 0) {
        globals.sparkMobileRequestId = globals.getUniqueMobileId();
        // }
        orderId = globals.sparkMobileRequestId;
        OutletOrders orderobj = new OutletOrders(
            id: orderId,
            outlet_id: outletId,
            uuid: "abc",
            is_completed: 0,
            is_uploaded: 0,
            total_amount: 0.0,
            lat: 31.53136,
            lng: 74.35348,
            accuracy: 0);
        order.add(orderobj);
        // globals.OutletCurrentLat = 31.5310302;
        // globals.OutletCurrentLng = 74.3530428;
        initiateOrder(order);
        addTimestamp(orderId);
      } else {
        print("else of Image");
        orderId = AllOrders[0]['id'];
        addTimestamp(orderId);
      }
    });
  }

  String outletImagePath = "";
  Repository repo = new Repository();

  Future SaveOutletImage() async {
    var currDate = new DateTime.now();
    print("currDate :" + currDate.toString());
    if (outletImagePath != "") {
      List imageDetailList = new List();
      int mobileRequestID = orderId;
      imageDetailList.add({
        "id": mobileRequestID,
        "documentfile": outletImagePath,
        "created_on" : currDate,
      });
      print("imageDetailList :" + imageDetailList.toString());

      // await repo.insertOutletOrderTimestamp(globals.orderId, 3);
      bool result1 = await repo.saveOutletOrderImage(imageDetailList);
      print("imageDetailList"+result1.toString());
      if (result1 == true) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => UnregisteredShopAction()
          //MaterialPageRoute(
          //builder: (context) => Orders(outletId: widget.outletId)
        ));
      }
    } else {
      Flushbar(
        messageText: Column(
          children: <Widget>[
            Text(
              "Please provide outlet image",
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundGradient:
        LinearGradient(colors: [Colors.black, Colors.black]),
        icon: Icon(
          Icons.notifications_active,
          size: 30.0,
          color: Colors.blue[800],
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Colors.blue[800],
      )..show(context);
    }
  }

  openCamera() async {
    final _picker = ImagePicker();

    final imageFile = await _picker.getImage(
        source: ImageSource.camera,
        imageQuality: 30,
        preferredCameraDevice: CameraDevice.rear);
    setState(() {
      if (imageFile != null) outletImagePath = imageFile.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          bottomNavigationBar: BottomAppBar(
            color: Colors.white,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  RawMaterialButton(
                    onPressed: () async {
                      SaveOutletImage();
                    },
                    padding: const EdgeInsets.all(0.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: const Text('Next',
                          style: TextStyle(fontSize: 20, color: Colors.blue)),
                    ),
                  )
                ]),
          ),
          appBar: AppBar(
              backgroundColor: Colors.blue[800],
              actions: <Widget>[
                new Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                )
              ],
              title: Text(
                "Outlet Image",
                style: TextStyle(fontSize: 16),
              ),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  })),
          body: new Container(
              //padding: EdgeInsets.all(16.0),
              child: new ListView(
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Container(
                child: Column(
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(
                                    "Please use the camera  icon to take image"),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Row(
                                children: <Widget>[
                                  outletImagePath != ""
                                      ? Container(
                                          margin: const EdgeInsets.all(15.0),
                                          padding: const EdgeInsets.all(3.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black)),
                                          width: 100,
                                          height: 100,
                                          child:
                                              Image.file(File(outletImagePath)))
                                      : Container(
                                          margin: const EdgeInsets.all(15.0),
                                          padding: const EdgeInsets.all(3.0),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.black)),
                                          width: 100,
                                          height: 100,
                                        ),
                                  TextButton.icon(
                                    onPressed: () {
                                      openCamera();
                                    },
                                    icon: Icon(Icons.camera_alt,
                                        color: Color(0xFFC9002B)),
                                    label: Text("Camera",
                                        style: TextStyle(
                                            color: Color(0xFFC9002B))),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        // btnOkIcon: Icons.photo_library,
                        // btnCancelIcon: Icons.camera_alt,
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Divider(color: Color(0xFF004b93)),
                  ],
                ),
              )
            ],
          )),
        ));
  }
}
