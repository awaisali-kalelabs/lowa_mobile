library my_prj.globals;

import 'dart:async';
import 'dart:io';
// import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/home.dart';
import 'package:permission_handler/permission_handler.dart';
//wildspace1@%88
String appVersion = "v1.1";
final oCcy = new NumberFormat("#,##0");
final oCcy1 = new NumberFormat("#,##0.##");
double maxDiscountPercentage = 0;
int distributorId = 0;
bool isLoggedIn = false;
String DisplayName = "Islam Danish";

String ServerURL = "3.78.122.135";
int sparkMobileRequestId = 0;
//for Item_Quantity check
int Rate  = 0;
//
String DeviceID = "";
int UserID = 0;
int isLocalLoggedIn = 0;
int isFromLoginRoute = 0;
String common_outlets_vpo_classifications = "";
//Pre Sell Transaction
File OutletImage;
File SignImage;
String SignImagePath = "";
String OutletImagePath = "";
/////////////
// Channel tagging
String channelTag="";
int channelTagId;

////////////////
int VisitType = 0;
int DispatchID = 0;
int OutletID = 0;
String OutletName = "";
String OutletNumber = "";
String OutletAddress = "";
String OutletOwner = "";
int WeekDay = 0;
String PCI_Channel_ID="";
String PCI_Channel_Lable = "";
String order_created_on_date = "";
String Visit="";
int InvoiceID = 0;
double NetAmount = 0.0;
double NetAmountOld = 0.0;
int isMultipleProductsFree = 0;
int OutletIdforupdate=0;
double CashReceived = 0.0;
int DeliveryType = 0;
int PaymentTypeID = 0;
double Lat = 0.0;
double Lng = 0.0;
double Accuracy = 0.0;
int IsModified = 0;
int isImageUploading = 0;
int isDataUploading = 0;

int TotalOutlets = 0;
int SuccessfulDelivries = 0;
int PendingDeliveries = 0;
String AmountCollected = "0";
String salesReportStartDate = "";
String salesReportEndDate = "";


String ordersReportStartDate = "";
String ordersReportEndDate = "";

List<int> ProductID = new List();
List<int> ProductRawCases = new List();
List<int> UnitsPerSKU = new List();
List<int> ProductUnits = new List();

List<int> ProductRawCasesOriginal = new List();
List<int> ProductUnitsOriginal = new List();

String productLabel = "";
int productId = 0;
int orderId = 0;
int isAlternative = 1;
int No_orderId = 0;

StreamSubscription<Position> locationStream;
Position currentPosition;

//attendanceTypeId 1 for check In
//attendanceTypeId 2 for check Out
int attendanceTypeId=0;
final LocationSettings locationSettings = LocationSettings(
  accuracy: LocationAccuracy.high,
  distanceFilter: 100,
);
void Reset() {
  print('reset values');
  //DispatchID=0;
  OutletImage = null;
  SignImage = null;
  ProductID = new List();
  ProductRawCases = new List();
  UnitsPerSKU = new List();
  ProductUnits = new List();
  ProductRawCasesOriginal = new List();
  ProductUnitsOriginal = new List();
  OutletID = 0;
  InvoiceID = 0;
  NetAmount = 0.0;
  OutletName = "";
  CashReceived = 0.0;
  DeliveryType = 0;
  PaymentTypeID = 0;
  Lat = 0.0;
  Lng = 0.0;
  Accuracy = 0.0;
  IsModified = 0;
  NetAmountOld = 0.0;
}

int getUniqueMobileId() {
  print("UserID:" + UserID.toString());
  String MobileId = "";
  if (UserID.toString().length > 4) {
    MobileId = UserID.toString().substring(5) +
        DateTime.now().millisecondsSinceEpoch.toString();
  } else {
    MobileId = UserID.toString().substring(1) +
        DateTime.now().millisecondsSinceEpoch.toString();
  }
  return int.parse(MobileId);
}

/*
Future<Map<String,dynamic>> makeDelivery() async {
  isDataUploading=1;
  Map<String,dynamic> formData= new Map();
  Repository repo=Repository();
  await repo.initdb();
  List<Map> SalesInvoice=await repo.getSalesDispatchInvoices();
  String Found=SalesInvoice.length.toString();
  print("invoices found: " +Found);
  int uploaded=0;
  Map<String,dynamic> val=new Map();
  for(int i=0;i<SalesInvoice.length;i++){

    formData.addAll({"LoginUsername": UserID.toString()});
    formData.addAll({"DeviceID": DeviceID.toString()});

    formData.addAll({"InvoiceID": SalesInvoice[i]['sales_id'].toString()});
    formData.addAll({"PaymentType":  SalesInvoice[i]['reciept_type_id'].toString()});
    formData.addAll({"DeliveryType": SalesInvoice[i]['delivery_type_id'].toString()});
    formData.addAll({"CashReceived": SalesInvoice[i]['cash_recieved'].toString()});
    formData.addAll({"DispatchID": SalesInvoice[i]['id'].toString()});
    formData.addAll({"MobileInvoiceID": SalesInvoice[i]['mobile_id'].toString()});
    formData.addAll({"MobileTimestamp": SalesInvoice[i]['mobile_timestamp'].toString()});

    formData.addAll({"Lat": SalesInvoice[i]['lat'].toString()});
    formData.addAll({"Lng": SalesInvoice[i]['lng'].toString()});
    formData.addAll({"Accuracy": SalesInvoice[i]['accuracy'].toString()});

    List<Map> AdjustedProducts=await repo.getSalesDispatchAdjustedProducts(SalesInvoice[i]['sales_id']);
    formData.addAll({"OutletID": AdjustedProducts[0]['outlet_id'].toString()});
    formData.addAll({"ProductID": AdjustedProducts[0]['product_id'].toString()});
    formData.addAll({"RawCases": AdjustedProducts[0]['raw_cases'].toString()});
    formData.addAll({"UnitsPerSKU": AdjustedProducts[0]['units_per_sku'].toString()});
    formData.addAll({"Units": AdjustedProducts[0]['units'].toString()});
    formData.addAll({"RawCasesOriginal": AdjustedProducts[0]['raw_cases_original'].toString()});
    formData.addAll({"UnitsOriginal": AdjustedProducts[0]['units_original'].toString()});

    print('upload start');
    // _asyncFileUpload(globals.DispatchID,globals.InvoiceID,globals.DeviceID,globals.UserID.toString(),  globals.OutletImage);
    //_asyncFileUpload(globals.DispatchID,globals.InvoiceID,globals.DeviceID,globals.UserID.toString(),  globals.SignImage);
    print('upload ended');
    print(formData);

    final response = await http.post(ServerURL+'/deliverymanager/MobileAdjustmentExecute',body: formData);

    print(response.toString());

    if (response.statusCode == 200) {
      print(response.statusCode);
      var result=json.decode(response.body);
      print(result['success']);
      if(result['success']=="true"){
        Repository repo=Repository();
        await repo.initdb();
        Map<String, dynamic> NewValues=new Map();
        NewValues.addAll({'is_delivered':1});
        List WhereArgs=new List();
        WhereArgs.add(SalesInvoice[i]['sales_id'].toString());
        */
/*await repo.updatePreSellOutlet(NewValues,WhereArgs);
        await repo.deletePreSellSalesDispatchInvoice(SalesInvoice[i]['sales_id']);
        await repo.deletePreSellDispatchAdjustedProduct(SalesInvoice[i]['sales_id']);*/ /*

        uploaded++;
        //return true;
      }else if(result['success']=="false"){
        val.addAll({"success":0});
        val.addAll({"message":"An error occured: "+result['error_message']});
        isDataUploading=0;
        return val;
      }
    } else {
      val.addAll({"success":0});
      val.addAll({"message":"Cant upload, Check your internet connection!"});
      isDataUploading=0;
      return val;

    }
  }
  val.addAll({"success":1});
  val.addAll({"message":"Uploaded: " + Found + "/" + uploaded.toString()});
  isDataUploading=0;
  return val;

}
*/

void asyncFileUpload() async {
  //create multipart request for POST or PATCH method
  print("upload started--danish");
  isImageUploading = 1;
/*  Repository repo=Repository();
  await repo.initdb();*/
/*  List<Map> SalesInvoiceImages=await repo.getSalesDispatchInvoicesImages();*/

  /*for(int i=0;i<SalesInvoiceImages.length;i++){

    var request = http.MultipartRequest("POST", Uri.parse(ServerURL+'/deliverymanager/MobileUploadImages'));
    request.fields["DispatchID"] = SalesInvoiceImages[i]['id'].toString();
    request.fields["InvoiceID"] = SalesInvoiceImages[i]['sales_id'].toString();
    request.fields["DeviceID"] = DeviceID;
    request.fields["LoginUsername"] = UserID.toString();
    print('uploading started: ' + i.toString());
    //create multipart using filepath, string or bytes
   // var pic = await http.MultipartFile.fromPath("file_field", file.path);
    {

      var pic = await http.MultipartFile.fromPath("file_field", SalesInvoiceImages[i]['outlet_signature']);
      //add multipart to request
      request.files.add(pic);

      var source_image=SalesInvoiceImages[i]['outlet_image'];
      var target_image=SalesInvoiceImages[i]['outlet_image'].toString().replaceFirst("outlet", "outlet_compressed");
      var compressed =await testCompressAndGetFile(source_image,target_image);
      pic = await http.MultipartFile.fromPath("file_field", compressed);
      request.files.add(pic);
      var response = await request.send();

      //Get the response from the server
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      var result=json.decode(responseString);
      if(result['success']==true){
        */ /*repo.deletePreSellSalesDispatchInvoiceImages(SalesInvoiceImages[i]['sales_id']);*/ /*
      }
      print(responseString);
    }


  }*/
  //add text fields
  print("---upload ended danish");
  isImageUploading = 0;
}

Future<String> testCompressAndGetFile(
    String sourcePath, String targetPath) async {
  /*var result = await FlutterImageCompress.compressAndGetFile(
    sourcePath, targetPath,
    quality: 15,
  );*/

  /*print(result.lengthSync());

  return result.path;*/
}

String getDisplayCurrencyFormat(value) {
  String FormatedValue = "";
  if (value != null) {
    FormatedValue = oCcy.format(value);
  }

  return FormatedValue;
}

String getDisplayCurrencyFormatTwoDecimal(value) {
  String FormatedValue = oCcy1.format(value);
  return FormatedValue;
}

void startContinuousLocation(context) async {
  if (locationStream == null || locationStream.isPaused == true) {
    if (await Permission.location.request().isGranted) {
      if (await Permission.location.serviceStatus.isEnabled) {
        // Either the permission was already granted before or the user just granted it.

        if (await Geolocator.isLocationServiceEnabled()) {
          print("location stream started...");
          locationStream = Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
            print(position == null
                ? 'Unknown'
                : position.latitude.toString() +
                ', ' +
                position.longitude.toString() +
                ', ' +
                position.accuracy.toString());
            currentPosition = position;
          });
        } else {
          showDialog(
            context: context,
            barrierDismissible: false,
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    } else {
      await Permission.location.request();
    }
  } else {
    print("location already running...");
  }
}

void stopContinuousLocation() {
  if (locationStream != null && locationStream.isPaused == false) {
    print("running...., stopping it");
    locationStream.cancel();
    locationStream = null;
    currentPosition = null;
  }
}

Future getCurrentLocation(context) async {
  if (await Permission.location.request().isGranted) {
    if (await Permission.location.serviceStatus.isEnabled) {
      // Either the permission was already granted before or the user just granted it.

      if (await Geolocator.isLocationServiceEnabled()) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best);
        return position;
      }
    }
  } else {
    await Permission.location.request();
  }
}
//TODO:Intent
// Future<Position> openLocationSetting() async {
//   final AndroidIntent intent = new AndroidIntent(
//     action: 'android.settings.LOCATION_SOURCE_SETTINGS',
//   );
//   await intent.launch();
// }

String EncryptSessionID(String qry) {
  String ret = "";
  print(qry.length);
  for (int i = 0; i < qry.length; i++) {
    int ch = (qry.codeUnitAt(i) * 5) - 21;
    ret += ch.toString() + ",";
  }

  String ret2 = "";
  for (int i = 0; i < ret.length; i++) {
    int ch = (ret.codeUnitAt(i) * 5) - 21;
    ret2 += ch.toString() + "0a";
  }

  return ret2;
}

String getCurrentTimestamp() {
  DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  String currDateTime = dateFormat.format(DateTime.now());
  var str = currDateTime.split(".");

  String TimeStamp = str[0];
  return TimeStamp;
}

String getCurrentTimestampSql() {
  DateFormat dateFormat = DateFormat("yyyy/MM/dd HH:mm:ss");
  String currDateTime = dateFormat.format(DateTime.now());
  var str = currDateTime.split(".");

  String TimeStamp = str[0];
  return TimeStamp;
}

String getDisplayDateFormat(DateTime d) {
  DateFormat dateFormat = DateFormat("dd/MM/yyyy hh:mm:ss a");
  String currDateTime = dateFormat.format(d);
  var str = currDateTime.split(".");

  String TimeStamp = str[0];
  return TimeStamp;
}

Future<bool> isFeatureAllowed(featureId) async {
  Repository repo = new Repository();
  await repo.initdb();
  bool isUserAllowed = false;
  List<Map<String, dynamic>> Features = await repo.isUserAllowed(featureId);
  if (Features.length > 0) {
    isUserAllowed = true;
  }
  return isUserAllowed;
}

int weekNumber(DateTime date) {
  int dayOfYear = int.parse(DateFormat("D").format(date));
  return ((dayOfYear - date.weekday + 10) / 7).floor();
}

bool isOutletAllowed(int IsAlternative) {
  bool Allowed = false;

  int week = weekNumber(DateTime.now());
  //week++;
  //print("week" + week.toString());
  if (IsAlternative == 0) {
    Allowed = true;
  } else if (IsAlternative == 2 && week % 2 == 0) {
    //week is even
    Allowed = true;
    //System.out.println("even"+week);
  } else if (IsAlternative == 1 && week % 2 != 0) {
    //week is odd
    Allowed = true;
    //System.out.println("odd"+week);
  }

  return Allowed;
}


int getPBCDayNumber(int dayNumber) {
  int actualDayNumber = 0;
  if (dayNumber == 7) {
    //Day is Sunday
    actualDayNumber = 1;
  } else if (dayNumber == 1) {
    //Day is Monday
    actualDayNumber = 2;
  } else if (dayNumber == 2) {
    //Day is Tuesday
    actualDayNumber = 3;
  } else if (dayNumber == 3) {
    //Day is Wednesday
    actualDayNumber = 4;
  } else if (dayNumber == 4) {
    //Day is Thurday
    actualDayNumber = 5;
  } else if (dayNumber == 5) {
    //Day is Friday
    actualDayNumber = 6;
  } else if (dayNumber == 6) {
    //Day is Saturday
    actualDayNumber = 7;
  }
  return actualDayNumber;
}

class LoadingDialogs {
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


