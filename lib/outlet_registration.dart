/*import 'package:camera/camera.dart';*/
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/globals.dart';
//import 'package:order_booker/shopAction.dart';

import 'com/pbc/model/pre_sell_outlets.dart';
import 'globals.dart' as globals;
import 'home.dart';

class OutletRegisteration extends StatefulWidget {
  OutletRegisteration() {}

  @override
  _OutletRegisteration createState() => _OutletRegisteration();
}

class _OutletRegisteration extends State<OutletRegisteration> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  int _selectedArea;
  int _selectedSubArea;
  int _selectedChannelArea;
  int _selectedOutletChannel;

  final TextEditingController _ChanneltypeAheadController =
  TextEditingController();
  final TextEditingController _OutletChanneltypeAheadController =
  TextEditingController();
  final TextEditingController _AreatypeAheadController =
  TextEditingController();

  final TextEditingController _SubAreatypeAheadController =
  TextEditingController();

  Repository repo = new Repository();
  List<Map<String, dynamic>> PCIChannels;
  List<Map<String, dynamic>> OutletChannel;
  List<Map<String, dynamic>> OutletAreas;
  List<Map<String, dynamic>> ProductsCatgories;
  List<Map<String, dynamic>> ProductsPrice;

  List<String> text = ["Owner is Purchaser"];
  bool _isChecked = false;
  String _currText = '';
  // String outlet_name = "";
  // String Area = "";
  // String Sub_Area = "";
  // String Channel = "";
  // String Owner_Name = "";
  // String telephone = "";
  // String Address = "";
  // String Sub_area = "";
  // String CNIC = "";
  // String PurchaserName = "";
  // String Purchaser_Number = "";
  //
  // String pic_channel_id="";
  // double lat = 0.0;
  // double lng = 0.0;
  // double Accuracy=0.0;


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
    OutletChannel = new List();
    repo.getOutletChannel().then((val) {
      setState(() {
        OutletChannel = val;
      });
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
  String outletImagePath = "";
  int mobileRequestID = globals.getUniqueMobileId();

  Future SaveOutletImage() async {
    if (outletImagePath != "") {
      List imageDetailList = new List();
      imageDetailList.add({
        "id": mobileRequestID,
        "documentfile": outletImagePath,
      });

      // await repo.insertOutletOrderTimestamp(globals.orderId, 3);
      bool result1 = await repo.saveOutletRegistrationImage(imageDetailList);

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

  Future _UploadDocuments() async {
    print("_UploadDocuments called");
   // List AllDocuments = new List();
    await repo.getNewOutletImages(mobileRequestID).then((val) async {
     /* setState(() {
        AllDocuments = val;
      });*/

      for (int i = 0; i < val.length; i++) {
        int MobileRequestID = int.parse(val[i]['id'].toString());
        try {
          print("AllDocuments.length" + val.length.toString());
          File photoFile = File(val[i]['file']);
          //  var stream =
          var stream = ByteStream(photoFile.openRead());
          var length = await photoFile.length();
          var url = Uri.http(
              globals.ServerURL, '/portal/mobile/MobileUploadNewOutletImage');
          print(url.toString());
          String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['RequestId'] = MobileRequestID.toString();
          print("===Hello1===");
          var multipartFile = new http.MultipartFile('file', stream, length,
              filename: "Outlet_" + fileName);

          request.files.add(multipartFile);
          print("multipartFile===>" + multipartFile.toString());
          var response = await request.send();
          print("====="+response.statusCode.toString());
          if (response.statusCode == 200) {
            print("MarkImage SUCCESS");
            await repo.markOutletRegistrationPhotoUploaded(MobileRequestID);
          }else{
            print("False");
          }
        } catch (e) {
          print("===Hello3===");
          print("e.toString()  " + e.toString());
        }
      }
    });
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
  final focus2 = FocusNode();
  double dynamicheight = 1.6;

  Widget build(BuildContext context) {
    final node = FocusScope.of(context);


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
                  MaterialPageRoute(builder: (context) => Home()),
                );
              }),
          actions: [
            ElevatedButton(
              child: Text('Save',
                  style: TextStyle(
                    color: Colors.white,
                  )),
              onPressed: () {
                SaveOutletImage();
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

                    setState(() {
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
                    'mobile_request_id': mobileRequestID,
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
                    'is_new' :1,
                    'outletchannel' :_selectedOutletChannel
                  });
                  _UploadDocuments();
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
                                padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                                child: Text(
                                    "Please use the camera  icon to take image"),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                child:  Row(
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
                                ),
                              ),
                              Divider(height: 10,),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextFormField(
                                  //enabled: false,
                                  controller: outletNameController,
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
                                  //readOnly: true,
                                  // autofocus: true,
                                  onChanged: (val) {
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.black12, width: 0.0),
                                    ),
                                    labelText: 'Outlet Name',
                                  ),
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return 'Please enter a outlet name. ';
                                    }
                                    return null;
                                  },
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
                                  child: TypeAheadFormField(
                                    textFieldConfiguration: TextFieldConfiguration(
                                      decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Colors.black12, width: 0.0),
                                        ),
                                        labelText: 'Outlet Channel',
                                      ),
                                      controller: this._OutletChanneltypeAheadController,
                                    ),
                                    suggestionsCallback: (pattern) async {
                                      return await repo.getChannel(
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
                                      this._OutletChanneltypeAheadController.text =
                                      suggestion['label'];
                                      this._selectedOutletChannel = suggestion['id'];
                                      FocusScope.of(context).requestFocus(focus2);
                                    },
                                    validator: (value) => value.isEmpty
                                        ? 'Please select Outlet channel'
                                        : null,
                                    onSaved: (value) => () {},
                                  )),
                              Container(
                                // width: cardWidth,
                                  padding: EdgeInsets.all(5.0),
                                  child: TextFormField(
                                    focusNode: focus2,
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
                                      labelText:'Owner Name',
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

                                    labelText: 'Purchaser Phone Number',
                                    hintText: ownerNameController.text,
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
                              //alignment: Alignment.bottomRight,
                              //  flex: 1,
                              //   child:
                                 MaterialButton(
                                  minWidth: MediaQuery.of(context).size.width,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  color: Colors.blue,
                                  child: Text(
                                    'Get GPS Location',
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

                                        setState(() {
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

                              Visibility(
                                visible: islocationGet,
                                child: Column(
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
                                    Container(
                                      // width: cardWidth,
                                      padding: EdgeInsets.all(5.0),
                                      child: TextField(
                                          autofocus: false,
                                          focusNode: myFocusNode,
                                          readOnly: true,
                                          onChanged: (val) {},
                                          keyboardType: TextInputType.text,
                                          controller: AccuracyController,
                                          decoration: InputDecoration(
                                            enabledBorder:
                                            const UnderlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black12,
                                                  width: 0.0),
                                            ),
                                            labelText: 'Accuracy',
                                          )),
                                    ),
                                  ],
                                ),
                              )
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
    _OutletRegisterationUpload(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => Home()));
  }

  Future _OutletRegisterationUpload(context) async {
    int ORDERIDToDelete = 0;
    List AllRegisteredOutlets = new List();
    await repo.getAllRegisteredOutletsByIsUploaded(0,1).then((val) async {
      setState(() {
        AllRegisteredOutlets = val;

        print("All Registered Outlets===>> " + AllRegisteredOutlets.toString());
      });

      for (int i = 0; i < AllRegisteredOutlets.length; i++) {
        String outletRegisterationsParams = "timestamp=" +
            globals.getCurrentTimestamp() +
            "&id_for_update=" +
            '0' +
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
            "&accuracy=" +
            (AllRegisteredOutlets[i]['accuracy'])
                .toString() +
            "&created_on=" +
            AllRegisteredOutlets[i]['created_on'] +
            "&created_by=" +
            AllRegisteredOutlets[i]['created_by'].toString() +
              "&OutletChannel=" +
            AllRegisteredOutlets[i]['outletchannel'].toString() +
            "&uuid=" +
            globals.DeviceID +
            "&version=" +
            globals.appVersion +
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
            globals.ServerURL, '/portal/mobile/MobileSyncOutletRegistration2');


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
            print("inside 200");
            if (responseBody["success"] == "true") {
              print("inside success");

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
