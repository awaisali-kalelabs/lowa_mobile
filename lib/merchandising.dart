import 'dart:convert';

import 'package:another_flushbar/flushbar.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:order_booker/attendance.dart';
import 'package:order_booker/home.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';

import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;
import 'com/pbc/dao/repository.dart';
import 'package:http/http.dart' as http;

// Obtain a list of the available cameras on the device.

// Get a specific camera from the list of available cameras.

class Merchandising extends StatefulWidget {
  @override
  _Merchandising createState() => _Merchandising();
}

class _Merchandising extends State<Merchandising> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  File _image;
  File _poster1;
  File _poster2;
  File _hanger;
  File _wobbler;
  File _shelf;
  File _sticker;
  File _pog;
  File _pog2;
  File _shelf1;
  File _shelf2;

  var imagePath;
  int imageTypeId=0;


  int mobileRequestId=0;

  Repository repo = new Repository();
  List imageDetailList=new List();
  List<Map<String, dynamic>> AllMerchandsingPhotos;


  bool isLocationTimedOut = false;

  Future openCamera(typeId) async {
    print("Fronst Side Image");
    final ImagePicker _picker = ImagePicker();
    imagePath = (await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 30,
        preferredCameraDevice: CameraDevice.front));

//    imagePath = (await new ImagePicker().getImage(source: ImageSource.camera, imageQuality: 30, preferredCameraDevice: CameraDevice.rear));

    setState(() {

      imageTypeId=typeId;
      if(typeId==1){
        _poster1 = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_poster1.path,"typeId":imageTypeId});
      }else if(typeId==2){
        _poster2 = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_poster2.path,"typeId":imageTypeId});
      }else if(typeId==3){
        _hanger = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_hanger.path,"typeId":imageTypeId});

      }else if(typeId==4){
        _wobbler = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }else if(typeId==5){
        _shelf = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }else if(typeId==6){
        _sticker = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }else if(typeId==7){
        _pog = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }else if(typeId==8){
        _pog2 = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }else if(typeId==9){
        _shelf1 = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }else if(typeId==10){
        _shelf2 = imagePath;
        _image = imagePath;
        imageDetailList.add({"image":_image.path,"typeId":imageTypeId});
      }

    });
  }

  @override
  void initState() {

    imageDetailList.clear();

    repo.getAllMerchandising(0).then((val) async {
      setState(() {
        AllMerchandsingPhotos = val;
        print(
            "_UploadMerchandisingPhoto     getAllMerchandising ==============>>> " +AllMerchandsingPhotos.toString());
      });
    });

  }

  MerchandisingLocally() async {
    print("MerchandisingLocally 1");
    Dialogs.showLoadingDialog(context, _keyLoader);
    Position position = globals.currentPosition;
    if (position == null) {
      globals.getCurrentLocation(context).then((position1) {
        position = position1;
      }).timeout(Duration(seconds: 7), onTimeout: (() {
        //   print("i am here timedout");

        setState(() {
          isLocationTimedOut = true;
        });
      })).whenComplete(() async {
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

       await repo.insertMerchandising(
              globals.getUniqueMobileId(),
              globals.OutletID,
              lat,
              lng,
              accuracy,
              0,
              globals.DeviceID,
              imageDetailList,
              0,
              globals.UserID
          );
          Navigator.of(context, rootNavigator: true).pop('dialog');
          _UploadMerchandisingPhoto();
           Navigator.push(
               context, MaterialPageRoute(builder: (context) => ShopAction()));
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
    } else {

     await repo.insertMerchandising(
          globals.getUniqueMobileId(),
          globals.OutletID,
          globals.currentPosition.latitude,
          globals.currentPosition.longitude,
          globals.currentPosition.accuracy,
          0,
          globals.DeviceID,
          imageDetailList,
          0,
          globals.UserID
      );


      print("MerchandisingLocally 2");
      Navigator.of(context, rootNavigator: true).pop('dialog');
      //_showDialog("Success", "Saved", 1);
      print("MerchandisingLocally 3");
      _UploadMerchandisingPhoto();


       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) =>ShopAction()
         ),
       );
    }
  }



  Future _UploadMerchandisingPhoto() async {
    AllMerchandsingPhotos = new List();
     repo.getAllMerchandising(0).then((val) async {
      setState(() {
        AllMerchandsingPhotos = val;

        print( "_UploadMerchandisingPhoto     getAllMerchandising ==============>>> " +AllMerchandsingPhotos.toString());
      });
    print("AllMerchandsingPhotos.length  ============>>. "+AllMerchandsingPhotos.length.toString());
      for (int i = 0; i < AllMerchandsingPhotos.length; i++) {


        int ORDERIDToDelete =
            int.parse(AllMerchandsingPhotos[i]['mobile_request_id']);
        try {
          File photoFile = File(AllMerchandsingPhotos[i]['image']);

          var stream =
              new http.ByteStream(DelegatingStream.typed(photoFile.openRead()));
          var length = await photoFile.length();
          var url = Uri.http(globals.ServerURL,'/portal/mobile/MobileUploadOrdersImageV2');

          String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['mobile_timestamp'] =AllMerchandsingPhotos[i]['mobile_timestamp'].toString();
          request.fields['outletId'] =AllMerchandsingPhotos[i]['outlet_id'].toString();
          request.fields['lat'] =AllMerchandsingPhotos[i]['lat'].toString();
          request.fields['lng'] =AllMerchandsingPhotos[i]['lng'].toString();
          request.fields['accuracy'] =AllMerchandsingPhotos[i]['accuracy'].toString();
          request.fields['uuid'] =AllMerchandsingPhotos[i]['uuid'].toString();
          request.fields['typeId'] =AllMerchandsingPhotos[i]['type_id'].toString();
          request.fields['userId'] =AllMerchandsingPhotos[i]['user_id'].toString();

          var multipartFile = new http.MultipartFile('file', stream, length,filename: fileName);

          request.files.add(multipartFile);
          var response = await request.send();
          print(response.statusCode);

          if (response.statusCode == 200) {
            print("markMerchandisingPhotoUploaded SUCCESS");
            await repo.markMerchandisingPhotoUploaded(ORDERIDToDelete,AllMerchandsingPhotos[i]['type_id']);
          }

        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          print("e.toString()  " + e.toString());
          //_showDialog("Error", "An error has occured " + e.toString(), 1);
        }
        //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);

      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          title: Text(
            "Merchandising",
            style: new TextStyle(color: Colors.white, fontSize: 14),
          ),
          actions: <Widget>[],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: FloatingActionButton(
        //     child: const Icon(Icons.camera_alt),
        //     onPressed: () {
        //       openCamera(_poster1);
        //     }),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          color: Colors.blue[100],
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              imagePath != null
                  ? Text("")
                  : Text(""),
              RawMaterialButton(
                  // fillColor: Colors.teal,
                  elevation: 0,
                  splashColor: Colors.blue[800],
                  textStyle: TextStyle(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[Text('Save')],
                  ),
                  onPressed: () => imageDetailList.length>0
                      ? MerchandisingLocally()
                      : ShowError(context)
                  /*onPressed: () {



                  }*/

                  )
            ],
          ),
        ),
        body: Container(
          margin: EdgeInsets.only(top: 10),
          constraints: BoxConstraints.expand(height: 800),

          // color: Colors.blue,
          child: ListView(
            children: [
              Column(
                children: <Widget>[
                  Row(
                    children: [
                      Container(
                        child: Text(
                          "TPOSM",
                          style: TextStyle(fontSize: 16),
                        ),
                        padding: EdgeInsets.all(10),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                openCamera(1);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _poster1 != null
                                        ? new Image.file(_poster1, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                            height: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Poster 1',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
                                openCamera(2);
                              },
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _poster2 != null
                                        ? new Image.file(_poster2, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Poster 2',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              )))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(3);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _hanger != null
                                        ? new Image.file(_hanger, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Hanger',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(4);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _wobbler != null
                                        ? new Image.file(_wobbler, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Wobbler',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              )))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(5);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _shelf != null
                                        ? new Image.file(_shelf, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Shelf',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(6);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _sticker != null
                                        ? new Image.file(_sticker, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Sticker',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              )))
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        child: Text(
                          "PPOSM",
                          style: TextStyle(fontSize: 16),
                        ),
                        padding: EdgeInsets.all(10),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(7);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _pog != null
                                        ? new Image.file(_pog, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'POG',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(8);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _pog2 != null
                                        ? new Image.file(_pog2, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'POG 2',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              )))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(9);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _shelf1 != null
                                        ? new Image.file(_shelf1, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Shelf 1',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              ))),
                      Expanded(
                          child: GestureDetector(
                              onTap: () {openCamera(10);},
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    _shelf2 != null
                                        ? new Image.file(_shelf2, width: 100,height: 100,)
                                        : Image.asset(
                                            "assets/images/take_photo.png",
                                            width: 100,
                                          ),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 5.0, 0.0, 0.0),
                                        child: Text(
                                          'Shelf 2',
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black),
                                        )),
                                  ],
                                ),
                              )))
                    ],
                  )
                ],
              ),
            ],
          ),
        ));
  }

  void ShowError(context) {
    Flushbar(
      messageText: Column(
        children: <Widget>[
          Text(
            "Please take picture to proceed.",
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
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
