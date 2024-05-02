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



class AttendanceAction extends StatefulWidget {
  @override
  _AttendanceActionState createState() => _AttendanceActionState();
}

class _AttendanceActionState extends State<AttendanceAction> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
   File _image;
   var imagePath;
   Repository repo = new Repository();
  List<Map<String, dynamic>> AllMarkedAttendances;
  List<Map<String, dynamic>> AllMarkedAttendancesPhotos;

  bool isLocationTimedOut = false;



  Future openCamera() async {
    print("Fronst Side Image");
    final ImagePicker _picker = ImagePicker();
    imagePath = (await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 30,
        preferredCameraDevice: CameraDevice.front));

//    imagePath = (await new ImagePicker().getImage(source: ImageSource.camera, imageQuality: 30, preferredCameraDevice: CameraDevice.rear));

    setState(() {
      //File _image = File(imagePath);
      _image = (File(imagePath.path));
      //  print("IMAGE PATH"+imagePath.toString());
      // print("IMAGE PATH"+_image.path);
    });
  }


  @override
  void initState() {
     repo.getAllMarkedAttendances(0).then((val) async {
      setState(() {
        AllMarkedAttendances = val;

       // print(" init State All Attendances PENDING " + AllMarkedAttendances.toString());
      });
    });


     repo.getAllMarkedAttendances(1).then((val) async {
       setState(() {
         AllMarkedAttendances = val;

        // print(" init State All Attendances UPLOADED" + AllMarkedAttendances.toString());
       });
     });

      repo.getAllMarkedUploadedAttendances(0).then((val) async {
       setState(() {
         AllMarkedAttendancesPhotos = val;

         print("init State     getAllMarkedUploadedAttendances ==============>>> " + AllMarkedAttendancesPhotos.toString());
       });
     });
  }

   MarkAttendanceLocally() {
    print("MarkAttendanceLocally 1");
     Dialogs.showLoadingDialog(context, _keyLoader);
     Position position=globals.currentPosition;
     if(position==null){
       globals.getCurrentLocation(context).then((position1) {
         position = position1;
       })
           .timeout(Duration(seconds: 7), onTimeout: ((){
      //   print("i am here timedout");

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
           repo.markAttendance(
               globals.getUniqueMobileId(),
               _image.path,
               globals.attendanceTypeId,
               lat,
               lng,
               accuracy,
               globals.UserID,
               0,
               globals.DeviceID,
               0
           );
           Navigator.of(context, rootNavigator: true).pop('dialog');
           _UploadMarkAttendance();
           _UploadMarkAttendancePhoto();
          Navigator.push(
             context,
               MaterialPageRoute(builder: (context) => Attendance())
           );

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

       repo.markAttendance(
         globals.getUniqueMobileId(),
         _image.path,
         globals.attendanceTypeId,
         globals.currentPosition.latitude,
         globals.currentPosition.longitude,
         globals.currentPosition.accuracy,
         globals.UserID,
         0,
         globals.DeviceID,0
       );
       print("MarkAttendanceLocally 2");
       Navigator.of(context, rootNavigator: true).pop('dialog');
       _showDialog("Success", "Attendance saved", 1);
       print("MarkAttendanceLocally 3");
       _UploadMarkAttendance();
/*
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) =>Attendance()
         ),
       );*/
   }
   }

   Future _UploadMarkAttendance() async {

     String TimeStamp = globals.getCurrentTimestamp();
     print("currDateTime" + TimeStamp);
     int ORDERIDToDelete = 0;
     AllMarkedAttendances = new List();
     await repo.getAllMarkedAttendances(0).then((val) async {
       setState(() {
         AllMarkedAttendances = val;

       //  print("_UploadMarkAttendance" + AllMarkedAttendances.toString());
       });

       for (int i = 0; i < AllMarkedAttendances.length; i++) {
         String orderParam = "timestamp=" +
             TimeStamp +
             "&AttendanceID=" +
             AllMarkedAttendances[i]['mobile_request_id'].toString() +
             "&TyepID=" +
             AllMarkedAttendances[i]['attendance_type_id'].toString() +
             "&MobileTimestamp=" +
             AllMarkedAttendances[i]['mobile_timestamp'].toString() +
             "&UserID=" +
             globals.UserID.toString() +
             "&LAT=" +
             AllMarkedAttendances[i]['lat'].toString() +
             "&LNG=" +
             AllMarkedAttendances[i]['lng'].toString() +
             "&Accu=" +
             AllMarkedAttendances[i]['accuracy'].toString() +
             "&UUID=" +
             AllMarkedAttendances[i]['uuid'] +
             "&DevicePlatformVersion=''" +
             "";
         ORDERIDToDelete = int.parse(AllMarkedAttendances[i]['mobile_request_id']);


         var QueryParameters = <String, String>{
           "SessionID": globals.EncryptSessionID(orderParam),
         };
         var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileSyncMarkAttendanceV3');

         try {
           var response = await http.post(url,
               headers: {
                 HttpHeaders.contentTypeHeader:
                 'application/x-www-form-urlencoded'
               },
               body: QueryParameters);

           var responseBody = json.decode(utf8.decode(response.bodyBytes));
          // print('called4');
           if (response.statusCode == 200) {
             if (responseBody["success"] == "true") {
               //   print ("success");
               await repo.markAttendanceUploaded(ORDERIDToDelete);
             }
             _UploadMarkAttendancePhoto();
           } else {
             // If that response was not OK, throw an error.

             //_showDialog("Error", "An error has occured " + responseBody.statusCode, 0);
           }
         } catch (e) {
           //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
          // _showDialog("Error", "An error has occured " + e.toString(), 1);
         }
         //var response = await http.post(localUrl, headers: {HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'},body: QueryParameters);

       }
     });
   }

  Future _UploadMarkAttendancePhoto() async {


    AllMarkedAttendancesPhotos = new List();
    await repo.getAllMarkedUploadedAttendances(0).then((val) async {
      setState(() {
        AllMarkedAttendancesPhotos = val;

        print("_UploadMarkAttendancePhoto     getAllMarkedUploadedAttendances ==============>>> " + AllMarkedAttendancesPhotos.toString());
      });

      for (int i = 0; i < AllMarkedAttendancesPhotos.length; i++) {
      int  ORDERIDToDelete = int.parse(AllMarkedAttendancesPhotos[i]['mobile_request_id']);
        try{
          print(AllMarkedAttendancesPhotos[i]['image_path']);
        File photoFile=File(AllMarkedAttendancesPhotos[i]['image_path']);
        var stream =new http.ByteStream(DelegatingStream.typed(photoFile.openRead()));
        var length = await photoFile.length();
        var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileUploadMarkAttendaceImage');


          String fileName = photoFile.path.split('/').last;

        var request = new http.MultipartRequest("POST", url);
        request.fields['value1'] = AllMarkedAttendancesPhotos[i]['mobile_request_id'];

        var multipartFile = new http.MultipartFile('file', stream, length,filename: fileName);
         // var multipartFile = new http.MultipartFile.fromString("file", photoFile.path);
        request.files.add(multipartFile);
        var response = await request.send();
        print(response.statusCode);

        if (response.statusCode == 200) {
          print("MobileUploadMarkAttendaceImage SUCCESS");
          await repo.markAttendanceUploadedPhoto(ORDERIDToDelete);
        }
        // } else {
        //   // If that response was not OK, throw an error.
        //   print("MobileUploadMarkAttendaceImage NOT WORKEDd");
        //  _showDialog(
        //       "Error", "An error has occured ", 0);
        // }

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
          title: Text(globals.attendanceTypeId==1?"Check In":"Check Out"
            ,
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
                  onPressed: ()=>_image!=null && imagePath!=null?MarkAttendanceLocally():ShowError(context)
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
                        "Please press camera button to take your picture",
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

                    MaterialPageRoute(builder: (context) => Attendance()
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
