/*import 'package:camera/camera.dart';*/
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/shopAction.dart';

import 'com/pbc/model/pre_sell_outlets.dart';
import 'globals.dart' as globals;
import 'home.dart';

class Updatelocattion extends StatefulWidget {

  @override
  _Updatelocattion createState() => _Updatelocattion();
}

class _Updatelocattion extends State<Updatelocattion> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  int _selectedArea;
  int _selectedSubArea;
  int _selectedChannelArea;

  final TextEditingController _ChanneltypeAheadController =
  TextEditingController();
  final TextEditingController _AreatypeAheadController =
  TextEditingController();

  final TextEditingController _SubAreatypeAheadController =
  TextEditingController();

  Repository repo = new Repository();
  List<Map<String, dynamic>> PCIChannels;
  List<Map<String, dynamic>> OutletAreas;
  List<Map<String, dynamic>> ProductsCatgories;
  List<Map<String, dynamic>> ProductsPrice;

  List<String> text = ["Owner is Purchaser"];
  bool _isChecked;

  String _currText = '';
  String outlet_name = "";
  String Area = "";
  String Sub_Area = "";
  String Channel = "";
  String Owner_Name = "";
  String telephone = "";
  String Address = "";
  String Sub_area = "";
  String cache_contact_nic = "";
  String purchaser_name = "";
  String purchaser_mobile_no = "";

  String pic_channel_id="";
  double lat = 0.0;
  double lng = 0.0;
  double Accuracy=0.0;

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    PCIChannels = new List();
    repo.getPCIChannels().then((val) {
      setState(() {
        PCIChannels = val;
      });
    });


    repo.GetOutletformID(globals.OutletIdforupdate).then((val) {
      pic_channel_id=val[0]['pic_channel_id'];
      _selectedChannelArea=int. parse(val[0]['pic_channel_id']);
      outlet_name=val[0]['outlet_name'];
      Address =val[0]['address'];
      Channel =val[0]['channel_label'];
      Owner_Name =val[0]['owner'];
      telephone =val[0]['telephone'];
      Area =val[0]['area_label'];
      Sub_area =val[0]['sub_area_label'];
      purchaser_name =val[0]['purchaser_name'];
      purchaser_mobile_no =val[0]['purchaser_mobile_no'];
      cache_contact_nic =val[0]['cache_contact_nic'];
      lat = double.parse(val[0]['lat']);
      lng = double.parse(val[0]['lng']);
      Accuracy = double.parse(val[0]['accuracy']);
      outletNameController.text = outlet_name;
      _ChanneltypeAheadController.text = Channel;
      _AreatypeAheadController.text = Area;
      _SubAreatypeAheadController.text = Sub_area;
      addressController.text = Address;
      ownerNameController.text = Owner_Name;
     // mobileNoController.text = telephone;
      telephone == 'null' &&telephone == "null"  ? '':mobileNoController.text = telephone;
      //cnicController.text = CNIC.toString();
      cache_contact_nic.toString() == 'null' && cache_contact_nic.toString() == "null"  ? '':cnicController.text = cache_contact_nic.toString();
      ownerPurchaseController.text = purchaser_name;
      purchaser_mobile_no.toString() == 'null' &&purchaser_mobile_no.toString() == "null"  ? '':mobileNumberPurchaserController.text = purchaser_mobile_no.toString();
      //mobileNumberPurchaserController.text = Purchaser_Number.toString();
      LatController.text= lat.toString();
      LongController.text=lng.toString();
      AccuracyController.text=Accuracy.toString();




      // Owner_Name =val[0]['owner'];

    });

    repo.getOutletAreas().then((val) {
      setState(() {
        OutletAreas = val;
      });
    });

    myFocusNode = FocusNode();

    globals.startContinuousLocation(context);
  }


  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.


    return true;
  }


  TextEditingController outletNameController = TextEditingController();
  TextEditingController channelController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController subAreaController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ownerNameController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController ownerPurchaseController = TextEditingController();
  TextEditingController mobileNumberPurchaserController =
  TextEditingController();

  TextEditingController LatController = TextEditingController();
  TextEditingController LongController = TextEditingController();
  TextEditingController AccuracyController = TextEditingController();

  TextEditingController NewLatController = TextEditingController();
  TextEditingController NewLongController = TextEditingController();
  TextEditingController NewAccuracyController = TextEditingController();

  FocusNode myFocusNode;

  bool islocationGet = false;
  bool isLocationTimedOut = false;


  final focus = FocusNode();
  double dynamicheight = 1.6;

  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    if (ownerPurchaseController.text == ownerNameController.text &&
        mobileNumberPurchaserController.text == mobileNoController.text) {
      _isChecked = true;
    } else {
      _isChecked = false;
    }
    String selected;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text("Update Location"),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShopAction()),
                );
              }),
          actions: [
            ElevatedButton(
              child: Text('Save',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              onPressed: () {
                globals.stopContinuousLocation();
                // if (islocationGet == false) {
                //   _showDialog("Error", "Please get GPS Location", 0);
                //   return false;
                // }

                if (_formKey.currentState.validate()) {



                  _registerOutlet(context);
                } else {}
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Form(
                  key: _formKey,

                  child: ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: (Column(
                            children: [
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  enabled: false,
                                  controller: outletNameController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  //readOnly: true,
                                  autofocus: true,
                                  onChanged: (val) {
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Outlet Name',
                                  ),
                                ),
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  enabled: false,
                                  controller: LatController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  //readOnly: true,
                                  autofocus: true,
                                  onChanged: (val) {
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Previous Latitude',
                                  ),
                                ),
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  enabled: false,
                                  controller: LongController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  //readOnly: true,
                                  autofocus: true,
                                  onChanged: (val) {
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Previous Longitude',
                                  ),
                                ),
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  enabled: false,
                                  controller: AccuracyController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  //readOnly: true,
                                  autofocus: true,
                                  onChanged: (val) {
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Previous Accuracy',
                                  ),
                                ),
                              ),
                              MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.blue,
                                  child: Text(
                                    'Update Location',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {


                                    print("globals.currentPosition:"+globals.currentPosition.toString());
                                    if(globals.currentPosition==null){
                                      Dialogs.showLoadingDialog(context, _keyLoader);
                                      globals
                                          .getCurrentLocation(context)
                                          .then((position1) {
                                        globals.currentPosition = position1;
                                        print(position1);
                                      })
                                          .timeout(Duration(seconds: 7), onTimeout: ((){
                                        print("i am here timedout");

                                        setState(() {
                                          isLocationTimedOut = true;
                                        });

                                      }))
                                          .whenComplete(() {
                                        if(isLocationTimedOut){

                                          NewLatController.text = "0";
                                          NewAccuracyController.text = "0";
                                          NewLongController.text = "0";
                                        }else{

                                          NewLatController.text = globals.currentPosition.latitude.toString();
                                          NewAccuracyController.text = globals.currentPosition.accuracy.toString();
                                          NewLongController.text = globals.currentPosition.longitude.toString();
                                        }

                                        setState(
                                                () {
                                          islocationGet = true;
                                          dynamicheight = 1.6;
                                          myFocusNode.requestFocus();
                                        });


                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop();


                                      }).catchError((onError) {

                                        Navigator.of(context,
                                            rootNavigator: true)
                                            .pop();


                                        print("ERRROR" + onError.toString());
                                      });
                                    }else{

                                      NewLatController.text = globals.currentPosition.latitude.toString();
                                      NewAccuracyController.text = globals.currentPosition.accuracy.toString();
                                      NewLongController.text = globals.currentPosition.longitude.toString();
                                      setState(() {
                                        islocationGet = true;
                                        dynamicheight = 1.6;
                                        myFocusNode.requestFocus();
                                      });
                                    }

                                  }),
                                 Column(
                                  children: [
                                    Container(
                                      // width: cardWidth,
                                      padding: EdgeInsets.all(5.0),
                                      child: TextField(
                                          autofocus: false,
                                          readOnly: true,
                                          onChanged: (val) {},
                                          keyboardType: TextInputType.text,
                                          controller: NewLatController,
                                          decoration: InputDecoration(
                                            enabledBorder:
                                            const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Updated Latitude',
                                          )),
                                    ),
                                    Container(
                                      // width: cardWidth,
                                      padding: EdgeInsets.all(5.0),
                                      child: TextField(
                                          autofocus: false,
                                          readOnly: true,
                                          onChanged: (val) {},
                                          keyboardType: TextInputType.text,
                                          controller: NewLongController,
                                          decoration: InputDecoration(
                                            enabledBorder:
                                            const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Updated Longitiude',
                                          )),
                                    ),
                                    Container(
                                      // width: cardWidth,
                                      padding: EdgeInsets.all(5.0),
                                      child: TextField(
                                          autofocus: false,
                                          readOnly: true,
                                          onChanged: (val) {},
                                          keyboardType: TextInputType.text,
                                          controller: NewAccuracyController,
                                          decoration: InputDecoration(
                                            enabledBorder:
                                            const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Updated Accuracy',
                                          )),
                                    ),
                                  ],
                                ),

                            ],
                          ))),
                    ],
                  ),
                ),
              ],
            )));
  }


  Future _registerOutlet(context) async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    //await repo.registerOutlet(Items);
    Navigator.of(context,rootNavigator: true).pop();
    _OutletLocationUpdate(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => ShopAction()));
  }

  Future _OutletLocationUpdate(context) async {


    String outletRegisterationsParams = "updated_on=" +
        globals.getCurrentTimestamp() +
        "&outlet_id=" +
        globals.OutletID.toString() +
        "&lat=" +
        NewLatController.text.toString() +
        "&lng=" +
        NewLongController.text.toString() +
        "&accuracy=" +
        NewAccuracyController.text.toString() +
        "&uuid=" +
        globals.DeviceID +
        "&updated_by=" +
        globals.UserID.toString();
    print("outletRegisterationsParams:" + outletRegisterationsParams);

    print("outletRegisterationsParams:" + outletRegisterationsParams);

        /* String orderParam="timestamp="+globa+"&order_no="+AllOrders[i]['id'].toString()+"&outlet_id="+ globals.OutletID.toString()+"&created_on="+AllOrders[i]['created_on'].toString()+"&created_by=100450&uuid=656d30b8182fea88&platform=android&lat="+globals.currentPosition.latitude.toString()+"&lng="+globals.currentPosition.longitude.toString()+"&accuracy=21";
        print("AllOrders[i]['id']"+AllOrders[i]['id'].toString());*/

        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(outletRegisterationsParams),
        };
        print("QueryParameters " + QueryParameters.toString());
        var url = Uri.http(
            globals.ServerURL, '/portal/mobile/MobileOutletLocationUpdate');


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
repo.UpdateOutletLocation(globals.OutletID, NewLatController.text , NewLongController.text , NewAccuracyController.text);
              print("Outlet Location is Updated");
            } else {
              print("False Response");
              _showDialog("Error", responseBody["error_code"], 0);
              print("Error:" + responseBody["error_code"]);
            }
          } else {
            print("Status code is not 200");
            print("Error: An error has occured: " + responseBody.statusCode);
          }
        } catch (e) {
          print("Inside Catch");

          print("Error: An error has occured: " + e.toString());
        }


    /* Navigator.push(
      context,
      //

      MaterialPageRoute(builder: (context) =>ShopAction()


      ),
    );*/
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
                  Navigator.of(context).pop();
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
