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

class Updateprofile extends StatefulWidget {

  @override
  _Updateprofile createState() => _Updateprofile();
}

class _Updateprofile extends State<Updateprofile> {
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
          backgroundColor: Colors.red[800],
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
                  int isOwnerPurchaser = 0;
                  if (_isChecked) {
                    isOwnerPurchaser = 1;
                  }
                  List args = new List();
                  String encodedOutletName = base64.encode(utf8.encode(outletNameController.text));
                  args.add({
                    'outlet_name': encodedOutletName,
                    'mobile_request_id': globals.getUniqueMobileId(),
                    'mobile_timestamp': globals.getCurrentTimestamp(),
                    'pic_channel_id': _selectedChannelArea,
                    'area_label': _AreatypeAheadController.text,
                    'sub_area_label': _SubAreatypeAheadController.text,
                    'address': addressController.text,
                    'owner_name': ownerNameController.text,
                    'owner_cnic': cnicController.text,
                    'owner_mobile_no': mobileNoController.text,
                    'purchaser_name': ownerPurchaseController.text,
                    'purchaser_mobile_no': mobileNumberPurchaserController.text,
                    'is_owner_purchaser': isOwnerPurchaser,
                    'lat': LatController.text,
                    'lng': LongController.text,
                    'accuracy': AccuracyController.text,
                    'created_on': globals.getCurrentTimestamp(),
                    'created_by': globals.UserID,
                    'is_uploaded': 0,
                    'is_new' : 0,
                  });

                  _registerOutlet(context, args);
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
                                  child: TypeAheadFormField(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black12, width: 0.0),
                                        ),
                                        labelText: 'Channel',
                                        hintText: 'Channel',
                                       // labelText: Channel??'Empty',
                                      ),
                                      controller: this._ChanneltypeAheadController,


                                    ),
                                    suggestionsCallback: (pattern) async {
                                      return await repo.getChannelSuggestions(
                                          "%" + pattern + "%");
                                    },
                                    itemBuilder: (context, suggestion) {
                                      return ListTile(
                                        leading: Text(
                                          '${suggestion['label']}',
                                        ),
                                      );
                                    },
                                    onSuggestionSelected: (suggestion) {
                                      this._ChanneltypeAheadController.text =
                                      suggestion['label'];
                                      this._selectedChannelArea = suggestion['id'];
                                      FocusScope.of(context).requestFocus(focus);
                                    },
                                    validator: (value) => value.isEmpty
                                        ? 'Please select a channel'
                                        : null,
                                    onSaved: (value) => () {},
                                  )),
                              Container(
                                // width: cardWidth,
                                  padding: EdgeInsets.all(5.0),
                                  child: TextFormField(
                                    focusNode: focus,
                                    decoration: InputDecoration(
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 0.0),
                                      ),
                                      labelText: 'Area',
                                        hintText: 'Area',

                                    ),
                                    autofocus: false,
                                    onChanged: (val) {},
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    controller: this._AreatypeAheadController,
                                    validator: (value) => value.isEmpty
                                        ? 'Please enter an area'
                                        : null,
                                  )),
                              Container(
                                // width: cardWidth,
                                  padding: EdgeInsets.all(5.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 0.0),
                                      ),
                                      labelText:'Sub Area',
                                        hintText: 'Sub_Area'
                                    ),
                                    autofocus: false,
                                    onChanged: (val) {},
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.next,
                                    controller: this._SubAreatypeAheadController,
                                    validator: (value) => value.isEmpty
                                        ? 'Please enter a sub area'
                                        : null,
                                  )),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  autofocus: false,
                                  onChanged: (val) {},
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  controller: addressController,
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Address',
                                    hintText: 'Address',
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter address.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  autofocus: false,
                                  //   readOnly: true,
                                  onChanged: (val) {},
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  controller: ownerNameController,
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText:'Owner_Name',
                                      hintText: 'Owner Name'

                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter owner name.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  autofocus: false,
                                  maxLength: 11,
                                  onChanged: (val) {},
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  controller: mobileNoController,
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText:  'Mobile No.',
                                      hintText: 'Mobile No.'
                                  ),
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Please enter mobile number.';
                                    } else if (val.length < 11) {
                                      return 'Please enter a valid mobile number.';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  autofocus: false,
                                  maxLength: 13,
                                  //  readOnly: true,
                                  onChanged: (val) {},
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.next,
                                  controller: cnicController,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),

                                    labelText:  'CNIC',
                                      hintText: 'CNIC'
                                  ),
                                  validator: (val) {
                                    if (!val.isEmpty && val.length < 13) {
                                      return 'Please enter a valid mobile number.';
                                    }else{
                                      Text("Hello");
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                  color: Colors.grey[100],
                                  // height: 350.0,
                                  child: CheckboxListTile(
                                    controlAffinity:
                                    ListTileControlAffinity.leading,
                                    title: Text(
                                      "Owner is Purchaser",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    value: _isChecked,
                                    onChanged: (val) {
                                      setState(() {
                                        _isChecked = val;

                                        if (_isChecked) {
                                          ownerPurchaseController.text =
                                              ownerNameController.text;
                                          mobileNumberPurchaserController.text =
                                              mobileNoController.text;
                                        } else {
                                          ownerPurchaseController.clear();
                                          mobileNumberPurchaserController.clear();
                                        }
                                      });
                                    },
                                  )),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  autofocus: false,
                                  //   readOnly: true,
                                  onChanged: (val) {},
                                  keyboardType: TextInputType.text,
                                  controller: ownerPurchaseController,
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Purchaser Name',
                                      hintText: 'Purchaser Name'
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter purchaser name.';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  autofocus: false,
                                  //  readOnly: true,
                                  maxLength: 11,
                                  onChanged: (val) {},
                                  keyboardType: TextInputType.number,
                                  controller: mobileNumberPurchaserController,
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),

                                    labelText:'Purchaser Phone Number',
                                      hintText: 'Purchaser Phone Number'
                                  ),
                                  validator: (val) {
                                    if (val.isEmpty) {
                                      return 'Please enter purchaser mobile number.';
                                    } else if (val.length < 11) {
                                      return 'Please enter a valid purchaser mobile number.';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              // Expanded(
                              // alignment: Alignment.bottomRight,
                              //  flex: 1,
                              //   child:
                              MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.redAccent,
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

                                          LatController.text = "0";
                                          AccuracyController.text = "0";
                                          LongController.text = "0";
                                        }else{

                                          LatController.text = globals.currentPosition.latitude.toString();
                                          AccuracyController.text = globals.currentPosition.accuracy.toString();
                                          LongController.text = globals.currentPosition.longitude.toString();
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

                                      LatController.text = globals.currentPosition.latitude.toString();
                                      AccuracyController.text = globals.currentPosition.accuracy.toString();
                                      LongController.text = globals.currentPosition.longitude.toString();
                                      setState(() {
                                        islocationGet = true;
                                        dynamicheight = 1.6;
                                        myFocusNode.requestFocus();
                                      });
                                    }

                                  }),

                              // Container(
                              //   // width: cardWidth,
                              //   padding: EdgeInsets.all(5.0),
                              //   child: TextFormField(
                              //     enabled: false,
                              //     controller: LatController,
                              //     keyboardType: TextInputType.text,
                              //     textInputAction: TextInputAction.next,
                              //     //readOnly: true,
                              //     autofocus: true,
                              //     onChanged: (val) {
                              //     },
                              //     decoration: InputDecoration(
                              //       enabledBorder: const UnderlineInputBorder(
                              //         borderSide: const BorderSide(
                              //             color: Colors.black12, width: 0.0),
                              //       ),
                              //       labelText:' Latitude',
                              //     ),
                              //     validator: (val) {
                              //       if (val == null || val.isEmpty) {
                              //         return 'Please enter a outlet name. ';
                              //       }
                              //       return null;
                              //     },
                              //   ),
                              // ),
                              // Container(
                              //   // width: cardWidth,
                              //   padding: EdgeInsets.all(5.0),
                              //   child: TextFormField(
                              //     enabled: false,
                              //     controller: LongController,
                              //     keyboardType: TextInputType.text,
                              //     textInputAction: TextInputAction.next,
                              //     //readOnly: true,
                              //     autofocus: true,
                              //     onChanged: (val) {
                              //     },
                              //     decoration: InputDecoration(
                              //       enabledBorder: const UnderlineInputBorder(
                              //         borderSide: const BorderSide(
                              //             color: Colors.black12, width: 0.0),
                              //       ),
                              //       labelText: 'longtude',
                              //     ),
                              //     validator: (val) {
                              //       if (val == null || val.isEmpty) {
                              //         return 'Please enter a outlet name. ';
                              //       }
                              //       return null;
                              //     },
                              //   ),
                              // ),
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
                                          controller: LatController,
                                          decoration: InputDecoration(
                                            enabledBorder:
                                            const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Latitude',
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
                                          controller: LongController,
                                          decoration: InputDecoration(
                                            enabledBorder:
                                            const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Longitiude',
                                          )),
                                    ),
                                    // Container(
                                    //   // width: cardWidth,
                                    //   padding: EdgeInsets.all(5.0),
                                    //   child: TextField(
                                    //       autofocus: false,
                                    //       focusNode: myFocusNode,
                                    //       readOnly: true,
                                    //       onChanged: (val) {},
                                    //       keyboardType: TextInputType.text,
                                    //       controller: AccuracyController,
                                    //       decoration: InputDecoration(
                                    //         enabledBorder:
                                    //         const UnderlineInputBorder(
                                    //           borderSide: const BorderSide(
                                    //               color: Colors.black12,
                                    //               width: 0.0),
                                    //         ),
                                    //         labelText: 'Accuracy',
                                    //       )),
                                    // ),
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


  Future _registerOutlet(context, List Items) async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    await repo.registerOutlet(Items);
    Navigator.of(context,rootNavigator: true).pop();
    _OutletRegisterationUpload2(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }

  Future _OutletRegisterationUpload2(context) async {
    int ORDERIDToDelete = 0;
    List AllRegisteredOutlets = new List();
    await repo.getAllRegisteredOutletsByIsUploaded(0,0).then((val) async {
      setState(() {
        AllRegisteredOutlets = val;

        print("All Registered Outlets===>> " + AllRegisteredOutlets.toString());
      });

      for (int i = 0; i < AllRegisteredOutlets.length; i++) {
        String outletRegisterationsParams = "timestamp=" +
            globals.getCurrentTimestamp() +
            "&id_for_update=" +
            (AllRegisteredOutlets[i]['id_for_update']).toString() +
            "&outlet_name=" +
            AllRegisteredOutlets[i]['outlet_name'] +
            "&mobile_request_id=" +
            (AllRegisteredOutlets[i]['mobile_request_id']).toString() +
            "&mobile_timestamp=" +
            AllRegisteredOutlets[i]['mobile_timestamp'] +
            "&channel_id=" +
            AllRegisteredOutlets[i]['channel_id'].toString() +
            "&area_label=" +
            AllRegisteredOutlets[i]['area_label'].toString() +
            "&sub_area_label=" +
            AllRegisteredOutlets[i]['sub_area_label'].toString() +
            "&address=" +
            AllRegisteredOutlets[i]['address'] +
            "&owner_name=" +
            AllRegisteredOutlets[i]['owner_name'] +
            "&owner_cnic=" +
            AllRegisteredOutlets[i]['owner_cnic'] +
            "&owner_mobile_no=" +
            AllRegisteredOutlets[i]['owner_mobile_no'] +
            "&purchaser_name=" +
            AllRegisteredOutlets[i]['purchaser_name'] +
            "&purchaser_mobile_no=" +
            AllRegisteredOutlets[i]['purchaser_mobile_no'] +
            "&is_owner_purchaser=" +
            AllRegisteredOutlets[i]['is_owner_purchaser'].toString() +
            "&lat=" +
            AllRegisteredOutlets[i]['lat'].toString() +
            "&lng=" +
            AllRegisteredOutlets[i]['lng'].toString() +
            // "&accuracy=" +
            // (AllRegisteredOutlets[i]['accuracy'])
            //     .toStringAsFixed(3)
            //     .toString() +
            "&created_on=" +
            AllRegisteredOutlets[i]['created_on'] +
            "&created_by=" +
            AllRegisteredOutlets[i]['created_by'].toString() +
            "&uuid=" +
            globals.DeviceID +
            "&platform=android";
        print("outletRegisterationsParams:" + outletRegisterationsParams);

        /* String orderParam="timestamp="+globa+"&order_no="+AllOrders[i]['id'].toString()+"&outlet_id="+ globals.OutletID.toString()+"&created_on="+AllOrders[i]['created_on'].toString()+"&created_by=100450&uuid=656d30b8182fea88&platform=android&lat="+globals.currentPosition.latitude.toString()+"&lng="+globals.currentPosition.longitude.toString()+"&accuracy=21";
        print("AllOrders[i]['id']"+AllOrders[i]['id'].toString());*/

        var QueryParameters = <String, String>{
          "SessionID": globals.EncryptSessionID(outletRegisterationsParams),
        };
        //var localUrl="http://192.168.10.37:8080/nisa_portal/mobile/MobileSyncOutletRegistration";
        // var localUrl="http://192.168.30.125:8080/nisa_portal/mobile/MobileSyncOutletRegistration";
        var url = Uri.http(
            globals.ServerURL, '/portal/mobile/MobileSyncOutletUpdate');


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
              print("Saved");
              repo.markOutletUploaded(
                  int.tryParse(AllRegisteredOutlets[i]['mobile_request_id']));
              //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();

            } else {
              // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
              _showDialog("Error", responseBody["error_code"], 0);
              print("Error:" + responseBody["error_code"]);
            }
          } else {
            //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
            //_showDialog("Error", "An error has occured: " + responseBody.statusCode, 0);
            print("Error: An error has occured: " + responseBody.statusCode);
          }
        } catch (e) {
          // Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          //_showDialog("Error", "An error has occured " + e.toString(), 1);
          print("Error: An error has occured: " + e.toString());
        }
      }
    });
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
