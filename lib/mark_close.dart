import 'dart:convert';


import 'package:another_flushbar/flushbar.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';



import 'package:path_provider/path_provider.dart';
import 'globals.dart' as globals;
import 'com/pbc/dao/repository.dart';
import 'package:http/http.dart' as http;


// Obtain a list of the available cameras on the device.


// Get a specific camera from the list of available cameras.



class OutletClose extends StatefulWidget {
  @override
  _OutletCloseState createState() => _OutletCloseState();
}

class _OutletCloseState extends State<OutletClose> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
   File _image;
   var imagePath;
   Repository repo = new Repository();
  List<Map<String, dynamic>> AllOutletsMarkedClose;
  bool isLocationTimedOut = false;



  // Future openCamera() async {
  //   print("Fronst Side Image");
  //   imagePath = (await ImagePicker.pickImage(
  //       source: ImageSource.camera, imageQuality: 30)) ;
  //   setState(() {
  //    _image=imagePath;
  //    print("IMAGE PATH"+imagePath.toString());
  //    print("IMAGE PATH"+_image.path);
  //   });
  //
  // }
  Future openCamera() async {
    print("Fronst Side Image");
    final ImagePicker _picker = ImagePicker();
    imagePath = (await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 30,
        preferredCameraDevice: CameraDevice.front));
    setState(() {
      _image=imagePath;
      print("IMAGE PATH"+imagePath.toString());
      print("IMAGE PATH"+_image.path);
    });
  }

  @override
  void initState() {
     repo.getAllOutletMarkClose(0).then((val) async {
      setState(() {
        AllOutletsMarkedClose = val;

        print("OutletClosed" + AllOutletsMarkedClose.toString());
      });
    });
  }

   markOutletCloseLocally() {

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
           repo.saveOutletMarkClose(
               globals.getUniqueMobileId(),
               globals.OutletID,
               _image.path,
               lat,
               lng,
               accuracy,
               globals.DeviceID);
           Navigator.of(context, rootNavigator: true).pop('dialog');
           _UploadOutletMarkClosed();
           _UploadOutletMarkClosedPhoto();
           repo.setVisitType(globals.OutletID, 3).then((value) {
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

     repo.saveOutletMarkClose(
         globals.getUniqueMobileId(),
         globals.OutletID,
         _image.path,
         globals.currentPosition.latitude,
         globals.currentPosition.longitude,
         globals.currentPosition.accuracy,
         globals.DeviceID);
     Navigator.of(context, rootNavigator: true).pop('dialog');
     _UploadOutletMarkClosed();
     repo.setVisitType(globals.OutletID, 3).then((value) {
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

   Future _UploadOutletMarkClosed() async {

     String TimeStamp = globals.getCurrentTimestamp();
     print("currDateTime" + TimeStamp);
     int ORDERIDToDelete = 0;
     AllOutletsMarkedClose = new List();
     await repo.getAllOutletMarkClose(0).then((val) async {
       setState(() {
         AllOutletsMarkedClose = val;

         print("OutletClosed" + AllOutletsMarkedClose.toString());
       });

       for (int i = 0; i < AllOutletsMarkedClose.length; i++) {
         String orderParam = "timestamp=" +
             TimeStamp +
             "&NoOrderID=" +
             AllOutletsMarkedClose[i]['id'].toString() +
             "&OutletID=" +
             AllOutletsMarkedClose[i]['outlet_id'].toString() +
             "&MobileTimestamp=" +
             AllOutletsMarkedClose[i]['created_on'].toString() +
             "&UserID=" +
             globals.UserID.toString() +
             "&Lat=" +
             AllOutletsMarkedClose[i]['lat'] +
             "&Lng=" +
             AllOutletsMarkedClose[i]['lng'] +
             "&accuracy=" +
             AllOutletsMarkedClose[i]['accuracy'] +
             "";
         ORDERIDToDelete = AllOutletsMarkedClose[i]['id'];
         var QueryParameters = <String, String>{
           "SessionID": globals.EncryptSessionID(orderParam),
         };
         var url =
         Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncOutletClosed');
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
               await repo.markOutletMarkCloseUploaded(ORDERIDToDelete);
             } else {
               //_showDialog("Error", responseBody["error_code"], 0);
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
     _UploadOutletMarkClosedPhoto();
   }

  Future _UploadOutletMarkClosedPhoto() async {


    AllOutletsMarkedClose = new List();
    await repo.getAllOutletMarkClose(1).then((val) async {
      setState(() {
        AllOutletsMarkedClose = val;

        print("OutletClosed" + AllOutletsMarkedClose.toString());
      });

      for (int i = 0; i < AllOutletsMarkedClose.length; i++) {
      int  ORDERIDToDelete = AllOutletsMarkedClose[i]['id'];
        try{
            print(AllOutletsMarkedClose[i]['image_path']);
          File photoFile=File(AllOutletsMarkedClose[i]['image_path']);
          var stream =new http.ByteStream(DelegatingStream.typed(photoFile.openRead()));
          var length = await photoFile.length();

          var url =
          Uri.http(globals.ServerURL, '/portal/mobile/MobileUploadOutletClosedImage');
          print(url);

            String fileName = photoFile.path.split('/').last;

          var request = new http.MultipartRequest("POST", url);
          request.fields['value1'] = AllOutletsMarkedClose[i]['id'].toString();

          var multipartFile = new http.MultipartFile('file', stream, length,filename: fileName);
           // var multipartFile = new http.MultipartFile.fromString("file", photoFile.path);
          request.files.add(multipartFile);
          var response = await request.send();
          print(response.statusCode);
          if (response.statusCode == 200) {

              await repo.markOutletMarkCloseUploadedPhoto(ORDERIDToDelete);

          } else {
            // If that response was not OK, throw an error.
            print("NOT WORKEDd");
           //_showDialog("Error", "An error has occured ", 0);
          }
        } catch (e) {
          //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          print("e.toString()  "+e.toString());
         // _showDialog("Error", "An error has occured " + e.toString(), 1);
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
    return  Scaffold(

        appBar: AppBar(backgroundColor: Colors.yellow[800],
          title: Text(
            globals.OutletID.toString() + " - " + globals.OutletName,
            style: new TextStyle(color: Colors.white, fontSize: 14),
          ),
          actions: <Widget>[

          ],),
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.camera_alt), onPressed: (){
          openCamera();

        }),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 4.0,
          color: Colors.yellow[100],
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              imagePath!=null?
              RawMaterialButton(
                //fillColor: Colors.teal,
                elevation: 0,
                splashColor: Colors.yellow,
                textStyle: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[Text('Retake')],
                ),
                onPressed: (){
                  print("M pressed");
                  setState(() {
                    imagePath=null;
                    _image=null;
                  });

                  openCamera();
                }


            ):Text(""),
              RawMaterialButton(
                 // fillColor: Colors.teal,
                  elevation: 0,
                  splashColor: Colors.yellow,
                  textStyle: TextStyle(color: Colors.white),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[Text('Save')],
                  ),
                  onPressed: ()=>_image!=null && imagePath!=null?markOutletCloseLocally():ShowError(context)
                  /*onPressed: () {



                  }*/

              )
            ],
          ),
        ),

        body:  Container(
          margin: EdgeInsets.only(top: 10),
          constraints: BoxConstraints.expand(height: 800),


          // color: Colors.red,
          child: Column(
            children: <Widget>[
              Container(


                child:_image==null ? Container(
                      child:  Text(
                        "Please press camera button to take picture of closed outlet.",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54),
                        ),
                    padding: EdgeInsets.fromLTRB(15, 15, 0, 0),
                    alignment: Alignment.topLeft,
                  ):new Image.file(_image),
              ),

            ],
          ),

        )
    );
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


  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

 /* Future<File> get _localFile() async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }*/

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
