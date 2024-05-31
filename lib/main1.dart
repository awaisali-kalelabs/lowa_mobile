import 'dart:convert';
import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/com/pbc/model/pre_sell_outlets.dart';
import 'package:order_booker/com/pbc/model/products.dart';
import 'package:order_booker/home.dart';

import 'com/pbc/model/outlet_products_prices.dart';
import 'com/pbc/model/product_lrb_types.dart';
import 'com/pbc/model/product_sub_categories.dart';
import 'delayed_animation.dart';
import 'globals.dart' as globals;

void main() => runApp(App());
var uuid;

class DeviceId {
  static const MethodChannel _channel = const MethodChannel('device_id');
  static Future<String> get getID async {
    final String uid = await _channel.invokeMethod('getID');
    return uid;
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Title',
      //theme: kThemeData,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => new _LoginPageState();
}

String DeviceID;

Future<String> _getDeviceId() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
  return androidDeviceInfo.androidId;
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  BuildContext _ctx;

  final formKey = new GlobalKey<FormState>();

  String _password;
  String _userid;
  bool isChecked = false;
  final int delayedAmount = 500;
  double _scale;
  AnimationController _controller;
  bool _isLoading = false;
  bool LoginType;
  @override
  void initState() {
    super.initState();

    DeviceID = "";

    LoginType = false;
    _getDeviceId().then((val) {
      setState(() {
        DeviceID = val;
      });
    });

    var currDate = new DateTime.now();
    int weekDay = currDate.weekday;

    globals.WeekDay = getDayNumberAccordingToPBC(weekDay);
  }

  String getCurrentDayOfWeek() {
    var currDate = new DateTime.now();
    // var weekday = currDate.weekday;
    var weekday = DateFormat('EEEE').format(currDate);
    return weekday;
  }

  int getDayNumberAccordingToPBC(int dayNumber) {
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

  void onLoginTypeChange(bool val) {
    setState(() {
      LoginType = !LoginType;
    });
  }

  Widget get _animatedButtonUI => Container(
        height: 45,
        width: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.0),
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            'Login',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 200,
      ),
      lowerBound: 0.0,
      upperBound: 0.1,
    )..addListener(() {
        setState(() {});
      });
    _ctx = context;
    _scale = 1 - _controller.value;
    Widget loadingIndicator = _isLoading
        ? new Material(
            elevation: 8.0,
            shape: CircleBorder(),
            color: Colors.grey[100],
            child: new Padding(
                padding: const EdgeInsets.all(5.0),
                child: new Center(child: new CircularProgressIndicator())),
          )
        : _animatedButtonUI;

    return Scaffold(
        bottomNavigationBar: Text(DeviceID, textAlign: TextAlign.center),
        body: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                Color(0xff1C52A2),
                Colors.lightBlueAccent,
              ]),
            ),
            child: Column(children: <Widget>[
              new Form(
                key: formKey,
                child: new Column(
                  children: [
                    AvatarGlow(
                      endRadius: 110,
                      duration: Duration(seconds: 2),
                      glowColor: Colors.white24,
                      repeat: true,
                      repeatPauseDuration: Duration(seconds: 1),
                      startDelay: Duration(seconds: 1),
                      child: Material(
                          elevation: 8.0,
                          shape: CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Image.asset('assets/images/Pepsi-logo.png',
                                width: 200,
                                //size: 50.0,
                                fit: BoxFit.fill),
                            radius: 70.0,
                          )),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    DelayedAimation(
                      child: new Container(
                        height: 60,
                        width: 350,
                        child: TextFormField(
                          autofocus: false,
                          keyboardType: TextInputType.number,
                          onSaved: (val) => _userid = val,
                          inputFormatters: [
                            // WhitelistingTextInputFormatter.digitsOnly
                          ],
                          //onSaved: (val) => _username = val,
                          decoration: InputDecoration(
                            hintText: 'User ID',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0)),
                          ),
                        ),
                      ),
                      delay: delayedAmount + 500,
                    ),
                    DelayedAimation(
                      child: new Container(
                        height: 60,
                        width: 350,
                        child: TextFormField(
                          autofocus: false,
                          obscureText: true,
                          onSaved: (val) => _password = val,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0)),

                            // borderRadius: BorderRadius.circular(100.0),
                          ),
                        ),
                      ),
                      delay: delayedAmount + 500,
                    ),
                    DelayedAimation(
                      child: CheckboxListTile(
                        checkColor: Colors.white,
                        value: LoginType,
                        onChanged: onLoginTypeChange,
                        title: Text(
                          'Local',
                          style: TextStyle(color: Colors.white),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                      delay: delayedAmount + 500,
                    ),
                    SizedBox(
                      height: 40.0,
                    ),
                    DelayedAimation(
                      child: GestureDetector(
                        onTap: () {
                          _showLoader();
                          formKey.currentState.save();
                          _onTapDown();
                        },
                        child: Transform.scale(
                          scale: _scale,
                          child: loadingIndicator,
                        ),
                      ),
                      delay: delayedAmount + 1000,
                    ),
                  ],
                ),
              )
            ])));
  }

  Future<bool> SaveCashSaleOrder(String param) async {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());
    bool callreturn = false;
    print("currDateTime" + currDateTime);
    String param = "timestamp=" +
        currDateTime +
        "&LoginUsername=" +
        _userid +
        "&LoginPassword=" +
        _password +
        "&DeviceID=656d30b8182fea88&DeviceToken=123";
    print("PARAM " + param);
    print("PARAM " + EncryptSessionID(param));
    var QueryParameters = <String, String>{
      "SessionID": EncryptSessionID(param),
    };

    print(QueryParameters);
    print('called1');
    var url = Uri.http(globals.ServerURL,
        '/portal/mobile/MobileAuthenticateUserV9', QueryParameters);
//      Wave/grain/sales/MobileVFSalesContractExecute
    print(url);
    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
    });
    print(response);
    var responseBody = json.decode(utf8.decode(response.bodyBytes));
    print('called4');
    //  print(responseBody);
    if (responseBody["success"] == "true") {
      globals.DisplayName = responseBody['DisplayName'];
      globals.UserID = int.tryParse(_userid);
      globals.DeviceID = DeviceID;
      Repository repo = new Repository();
      await repo.initdb();
      await repo.deleteAllProducts();
      await repo.deleteAllPreSellOutlet();
      await repo.deleteAllProductsLrbTypes();
      await repo.deleteAllSubCategories();
      await repo.deleteAllOutletProductsPrices();
      List products_rows = responseBody['ProductGroupRows'];
      print("products_rows" + products_rows.toString());
      for (var i = 0; i < products_rows.length; i++) {
        repo.insertProduct(Products.fromJson(products_rows[i]));
      }
      List pre_sell_outlets_rows = responseBody['BeatPlanRows'];
      for (var i = 0; i < pre_sell_outlets_rows.length; i++) {
        repo.insertPreSellOutlet(
            PreSellOutlets.fromJson(pre_sell_outlets_rows[i]));
      }

      List product_lrb_types_rows = responseBody['ProductLrbTypes'];
      print("product_lrb_types_rows" + product_lrb_types_rows.toString());
      for (var i = 0; i < product_lrb_types_rows.length; i++) {
        repo.insertProductsLrbTypes(
            ProductsLrbTypes.fromJson(product_lrb_types_rows[i]));
      }

      List product_sub_categories_rows = responseBody['ProductSubCategories'];
      print("product_sub_categories_rows" +
          product_sub_categories_rows.toString());
      for (var i = 0; i < product_sub_categories_rows.length; i++) {
        repo.insertProductsSubCategories(
            ProductSubCategories.fromJson(product_sub_categories_rows[i]));
      }

      List outlet_product_prices_rows = responseBody['ActivePriceListRows'];
      for (var i = 0; i < outlet_product_prices_rows.length; i++) {
        repo.insertOutletProductsPrices(
            OutletProductsPrices.fromJson(outlet_product_prices_rows[i]));
      }

      callreturn = true;
    } else {
      callreturn = false;
    }
    return callreturn;
  }

  Future<bool> loginUser(Map<String, dynamic> formData, String param) async {
    print(formData);

    print("YOO YOOO " + globals.ServerURL + '/MobileAuthenticateUserV9');
    final response = await http
        .post((globals.ServerURL + '/MobileAuthenticateUserV9') as Uri, body: formData);
    print("YOO YOOO " + globals.ServerURL + '/MobileAuthenticateUserV9');
    print(response);
    if (response.statusCode == 200) {
      // print(response.body);

      var result = utf8.decode(response.bodyBytes);

      //print(result['success']);
      /*  if(result['success']=="true"){
        globals.DisplayName=result['DisplayName'];
        globals.UserID=int.tryParse(_userid);
        globals.DeviceID=DeviceID;
       // List products_rows=result['products_rows'];
        List outlets_rows=result['outlets_rows'];

       // List pre_sell_routes_rows=result['pre_sell_routes'];
        List pre_sell_outlets_rows=result['pre_sell_outlets'];
        //List pre_sell_outlet_products_rows=result['pre_sell_outlet_products'];

        globals.TotalOutlets=int.parse(result['total_outlets'].toString()) ;
        globals.SuccessfulDelivries=int.parse(result['successful_deliveries'].toString());
        globals.PendingDeliveries=int.parse(result['pending_deliveries'].toString());
        globals.AmountCollected=result['amount_collected'].toString();


       Repository repo=new Repository();
        await repo.initdb();






       for(var i=0;i<pre_sell_outlets_rows.length;i++){

          repo.insertPreSellOutlet(PreSellOutlets.fromJson(pre_sell_outlets_rows[i]));
        }

        return true;
      }else if(result['success']=="false"){
        _showDialog("Error","An error occured: "+result['error_code']);

        return false;
      }*/

    } else {
      // If that response was not OK, throw an error.
      _showDialog("Error", "Check your internet connection!");
      return false;
    }
  }

  Future<void> localLogin(int UserID, String Password) async {
    /*   Repository repo=new Repository();
    await repo.initdb();*/

    /* List<Map> result=await repo.getUser(UserID, Password);*/
    print('test:');
    /*if(result.length>0 ){
      DateTime created_on=DateTime.parse(result[0]['created_on']);
      DateTime current_time=DateTime.now();
      current_time=current_time.subtract(Duration(days: 3));
      print(current_time.toString()+":"+created_on.toString());
      if(current_time.isAfter(created_on)){
        _showDialog("Error","Local login has been expired, please find an internet connection");
      }else if(result.length>0 ){
        globals.DisplayName=result[0]['display_name'];
        globals.UserID=UserID;
        globals.DeviceID=DeviceID;
        globals.isLocalLoggedIn=1;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }else{
        _showDialog("Error","An error occured");


      }*/
    /*  }else{
      _showDialog("Error","An error occured");


    }*/
  }

  Future _onTapDown() async {
    Map<String, dynamic> formData = new Map();
    print(_userid);

    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());

    print("currDateTime" + currDateTime);

    String param = "timestamp=" +
        currDateTime +
        "&LoginUsername=" +
        _userid +
        "&LoginPassword=" +
        _password +
        "&DeviceID=656d30b8182fea88&DeviceToken=123";
    print("PARAM " + param);
    print("PARAM " + EncryptSessionID(param));

    formData.addAll({"SessionID": EncryptSessionID(param)});
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );*/

    /* Repository repo=new Repository();
    await repo.initdb();
  */

    print(LoginType);
    if (LoginType) {
      // await localLogin(int.parse(_userid) ,_password);

    } else {
      if (await SaveCashSaleOrder(param)) {
        // globals.isLocalLoggedIn=0;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      }
    }

    // print(await fetchProducts());
  }

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

  void _showDialog(String Title, String Message) {
    // flutter defined function
    Navigator.pop(context);
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoader() {
    // flutter defined function

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return SizedBox(
          height: 10,
          width: 10,
          child: AlertDialog(
            backgroundColor: Colors.transparent,
            content: LoadingIndicator(
              indicatorType: Indicator.ballPulse,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}
