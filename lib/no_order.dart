import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/globals.dart';
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
  bool isLoading = false;
  String selected;
  int weekday;
  int noOrderReason;
  bool isLocationTimedOut = false;
  List<Map<String, dynamic>> AllNoOrders;
  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> AllOrdersItems;
  List<String> outletImagePath = ["", ""];
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

  openCamera(int count) async {
    print("add for " + count.toString());
    final _picker = ImagePicker();
    final imageFile = await _picker.getImage(
      source: ImageSource.camera,
      imageQuality: 30,
      preferredCameraDevice: CameraDevice.rear,
    );
    setState(() {
      if (imageFile != null) if (imageFile != null)
        outletImagePath.insert(count, imageFile.path);
    });
  }

  Future _UploadDocuments() async {
    print("_UploadDocuments called");
    List AllDocuments = new List();
    print("================" + globals.orderId.bitLength.toString());
   // for (int i = 0; i < 2; i++) {
      // if (outletImagePath.elementAt(i) != "") {

      await repo.getNoOrderImages(globals.orderId).then((val) async {
        setState(() {
          AllDocuments = val;
        });
        print("===" + val.toString());
        //List AllDocuments = val;

        print("==========" + AllDocuments.length.toString());
        for (int i = 0; i < AllDocuments.length; i++) {
          int MobileRequestID = int.parse(AllDocuments[i]['id'].toString());
          try {
            print("AllDocuments.length" + AllDocuments.length.toString());
            File photoFile = File(AllDocuments[i]['file']);
            //  var stream =
            var stream = ByteStream(photoFile.openRead());
            var length = await photoFile.length();
            var url = Uri.http(
                globals.ServerURL, '/portal/mobile/MobileUploadNoOrdersImage');
            print(url.toString());
            print("===Hello===");
            String fileName = photoFile.path
                .split('/')
                .last;

            var request = new http.MultipartRequest("POST", url);
            request.fields['NoOrderNo'] = MobileRequestID.toString();
            print("===Hello1===");
            var multipartFile = new http.MultipartFile('file', stream, length,
                filename: "Outlet_" + fileName);

            request.files.add(multipartFile);
            print("multipartFile===>" + multipartFile.toString());
            var response = await request.send();
            print("===Hello==" + response.toString());

            print("=====" + response.statusCode.toString());

            print("response" + response.statusCode.toString());
            print(response.toString());
            if (response.statusCode == 200) {
              print("MarkImage SUCCESS");
              await repo.markNoOrderPhotoUploaded(MobileRequestID, i + 1);
              //
            } else {
              print("False");
            }
          } catch (e) {
            print("===Hello3===");
            print("e.toString()  " + e.toString());
          }
        }
      });


/* }else {
        if(i < 1) {
          Flushbar(
            messageText: Column(
              children: <Widget>[
                Text(
                  "Please provide at least 1 outlet image",
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
          )
            ..show(context);
        }
      }*/

 // }
  }
  saveNoOrder() async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    Position position = globals.currentPosition;
    if (position == null) {
      globals.getCurrentLocation(context).then((position1) {
        position = position1;
      }).timeout(
        Duration(seconds: 7),
        onTimeout: (() {
          print("i am here timedout");
          setState(() {
            isLocationTimedOut = true;
          });
        }),
      ).whenComplete(() {
        double lat = 0.0;
        double lng = 0.0;
        double accuracy = 0.0;
        print(position);
        if (position != null || isLocationTimedOut) {
          if (isLocationTimedOut == false) {
            lat = position.latitude;
            lng = position.longitude;
            accuracy = position.accuracy;
          }
          print(position);
          repo.saveNoOrder(
            globals.orderId,
            globals.OutletID,
            noOrderReason,
            lat,
            lng,
            accuracy,
            globals.DeviceID,
              globals.selectedPJP
          );
          Navigator.of(context, rootNavigator: true).pop('dialog');
          _UploadNoOrder();
          repo.setVisitType(globals.OutletID, 2).then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShopAction()),
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
            },
          );
        }
      });
    } else {
      repo.saveNoOrder(
        globals.orderId,
        globals.OutletID,
        noOrderReason,
        position.latitude,
        position.longitude,
        position.accuracy,
        globals.DeviceID,
        globals.selectedPJP
      );
      Navigator.of(context, rootNavigator: true).pop('dialog');
      await _UploadNoOrder(); //(context);
      repo.setVisitType(globals.OutletID, 2).then((value) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ShopAction()),
        );
      });
    }
  }

  Future SaveOutletImage() async {
    for (int i = 0; i < 2; i++) {
      if (outletImagePath.elementAt(i) != "") {
        List imageDetailList = new List();
        int mobileRequestID = orderId;
        imageDetailList.add({
          "id": mobileRequestID,
          "documentfile": outletImagePath.elementAt(i),
          "file_type_id": i + 1,
        });
        bool result1 = await repo.saveOutletNOOrderImage(imageDetailList);
        if (result1 == true) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ShopAction(),
            ),
          );
        }
      } else {
        if (i < 1) {
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
            backgroundGradient: LinearGradient(colors: [Colors.black, Colors.black]),
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
    }
    //end of images Loop
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
            "&version=" +
            appVersion +
            "&accuracy=" +
            AllNoOrders[i]['accuracy'] +
            "&PJP=" +
            AllNoOrders[i]['PJP'].toString() +
            "";
        ORDERIDToDelete = AllNoOrders[i]['id'];
        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(orderParam),
        };
        var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncNoOrdersV3');
        print(url);
        try {
          var response = await http.post(
            url,
            headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},
            body: QueryParameters,
          );
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
            _showDialog("Error", "An error has occured " + responseBody.statusCode, 0);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          _showDialog("Error", "An error has occured " + e.toString(), 1);
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
                    MaterialPageRoute(builder: (context) => ShopAction()),
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
            title: Text(
              "" + NoOrderReasons[index]['label'],
              style: new TextStyle(fontSize: 16, color: Colors.black54),
            ),
            //subtitle: Text("Radio 1 Subtitle"),
            onChanged: (val) {
              print("Radio Tile pressed $val");
              setNoOrderReason(val);
            },
            activeColor: Colors.blue[200],
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
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
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
                MaterialPageRoute(builder: (context) => ShopAction()),
                ModalRoute.withName("/ShopAction"),
              );
            },
          ),
          actions: [
            isLoading ? CircularProgressIndicator() :   ElevatedButton(
              style: ElevatedButton.styleFrom(
                onPrimary: Colors.grey, // Text Color
              ),
              child: Text(
                'Save',
                style: TextStyle(
                  color: noOrderReason == 0 ? Colors.grey : Colors.white,
                ),
              ),
              onPressed: () async {
                isLoading = true;

                if(outletImagePath[0]!= "") {
                  print("========inside save order call=========");

                  noOrderReason == 0 ? ShowError(context) : await saveNoOrder();
                }
                await  SaveOutletImage();
                for (int i = 0; i < 2; i++) {
                  if (outletImagePath.elementAt(i) != "") {

                    await   _UploadDocuments();
                  } else {
                    Flushbar(
                      messageText: Column(
                        children: <Widget>[
                          Text(
                            "Please provide at least 1 outlet image",
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
                        color: Colors.blue[800],
                      ),
                      duration: Duration(seconds: 2),
                      leftBarIndicatorColor: Colors.blue[800],
                    )..show(context);
                  }
                }
                isLoading = false;

              },
            ),
          ],
        ),
        body:
        isLoading ?  CircularProgressIndicator(): ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 15,
                  ),
                  Text("Please use the camera  icon to take image"),
                  SizedBox(
                    height: 5,
                  ),
                  Column(
                    children: [
                      Row(
                        children: <Widget>[
                          outletImagePath.elementAt(0) != ""
                              ? Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            width: 100,
                            height: 100,
                            child: Image.file(File(outletImagePath.elementAt(0))),
                          )
                              : Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            width: 100,
                            height: 100,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              openCamera(0);
                            },
                            icon: Icon(Icons.camera_alt, color: Color(0xFFC9002B)),
                            label: Text(
                              "Camera",
                              style: TextStyle(color: Color(0xFFC9002B)),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          outletImagePath.elementAt(1) != ""
                              ? Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            width: 100,
                            height: 100,
                            child: Image.file(File(outletImagePath.elementAt(1))),
                          )
                              : Container(
                            margin: const EdgeInsets.all(15.0),
                            padding: const EdgeInsets.all(3.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                            ),
                            width: 100,
                            height: 100,
                          ),
                          TextButton.icon(
                            onPressed: () {
                              openCamera(1);
                            },
                            icon: Icon(Icons.camera_alt, color: Color(0xFFC9002B)),
                            label: Text(
                              "Camera",
                              style: TextStyle(color: Color(0xFFC9002B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Divider(
                    height: 2,
                  ),
                  Column(
                    children: [
                      Container(
                        child: Text(
                          "Please select the reason for not placing an order",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
