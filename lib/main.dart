import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:another_flushbar/flushbar.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/com/pbc/model/outlet_areas.dart';
import 'package:order_booker/com/pbc/model/outlet_products_alternative_prices.dart';
import 'package:order_booker/com/pbc/model/outlet_products_prices.dart';
import 'package:order_booker/com/pbc/model/outlet_sub_areas.dart';
import 'package:order_booker/com/pbc/model/pci_sub_channel.dart';
import 'package:order_booker/com/pbc/model/pre_sell_outlets.dart';
import 'package:order_booker/com/pbc/model/product_lrb_types.dart';
import 'package:order_booker/com/pbc/model/product_sub_categories.dart';
import 'package:order_booker/com/pbc/model/products.dart';
import 'package:order_booker/com/pbc/model/user.dart';
import 'package:order_booker/com/pbc/model/user_features.dart';
/*
import 'package:order_booker/home.dart';
*/
import 'package:order_booker/order_cart_view.dart';
import 'package:splashscreen/splashscreen.dart';

import 'SelectPJP.dart';
import 'com/pbc/model/OutletChannel.dart';
import 'delayed_animation.dart';
import 'globals.dart' as globals;

void main() async {
  HttpOverrides.global = new MyHttpOverrides();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.blue[800], // navigation bar color
    statusBarColor: Colors.blue[800], // status bar color
  ));
  runApp(MyApp());
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Theia',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Nunito',
          primaryTextTheme:
              TextTheme(headline6: TextStyle(color: Colors.white))),
      initialRoute: "/",
      home: SplashScreen(
          seconds: 5,
          routeName: "/",
          navigateAfterSeconds: new LoginPage(),
          /*title: new Text('Welcome In SplashScreen',
          style: new TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0
          ),),*/
          //image: new Image.asset('images/Dewallett.png'),
          title: Text("Theia",
              style: TextStyle(
                  fontSize: 44,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.blue[800],
          styleTextUnderTheLoader: new TextStyle(),
          photoSize: 100.0,
          // onClick: ()=>print("Flutter Egypt"),
          loaderColor: Colors.white),
    );
  }
}
class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  final formKey = new GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  List<dynamic>  PJPList = [];
  final int delayedAmount = 500;
  FocusNode myFocusNode = new FocusNode();
  TextEditingController numberController = new TextEditingController();

  ScrollController _scrollController = new ScrollController();
  String _userid;
  String _password;
  bool LoginType;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  void onLoginTypeChange(bool val) {
    setState(() {
      LoginType = !LoginType;
    });
  }

  String DeviceID;

  Future<String> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
    return androidDeviceInfo.androidId;
  }

  Future _onTapDown() async {
    if (_userid.isNotEmpty) {
      if (_password.isNotEmpty) {
        Dialogs.showLoadingDialog(context, _keyLoader);
        //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
        Map<String, dynamic> formData = new Map();

        DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
        String currDateTime = dateFormat.format(DateTime.now());

        String param = "timestamp=" +
            currDateTime +
            "&LoginUsername=" +
            _userid +
            "&LoginPassword=" +
            _password +
            "&DeviceID=" +
            globals.DeviceID +
            "&DeviceToken=123";
        print("param:" + param);
        formData.addAll({"SessionID": EncryptSessionID(param)});

        if (LoginType) {
          await localLogin(int.parse(_userid), _password);
        } else {
          if (await SaveCashSaleOrder()) {
            globals.isLocalLoggedIn = 0;
            //danish
            Navigator.of(context, rootNavigator: true).pop('dialog');
            //Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AreaSelectionScreen(pjpList: PJPList,)),
            );
          }
        }
      } else {
        Flushbar(
          messageText: Column(
            children: <Widget>[
              Text(
                "Please provide password",
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
            color: Colors.blue,
          ),
          duration: Duration(seconds: 2),
          leftBarIndicatorColor: Colors.blue,
        )..show(context);
      }
    } else {
      Flushbar(
        messageText: Column(
          children: <Widget>[
            Text(
              "Please provide userid",
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
          color: Colors.blue,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Colors.blue,
      )..show(context);
    }

    // print(await fetchProducts());
  }

  Future<void> localLogin(int UserID, String Password) async {
    Repository repo = new Repository();
    await repo.initdb();

    List<Map> result = await repo.getUser(UserID, Password);
    print('test:' + result.toString());
    if (result.length > 0) {
      DateTime created_on = DateTime.parse(result[0]['created_on']);
      DateTime current_time = DateTime.now();
      current_time = current_time.subtract(Duration(days: 3));
      print(current_time.toString() + ":" + created_on.toString());
      if (current_time.isAfter(created_on)) {
        _showDialog("Error",
            "Local login has been expired, please find an internet connection");
      } else if (result.length > 0) {
        globals.DisplayName = result[0]['display_name'];
        globals.UserID = UserID;
        globals.DeviceID = DeviceID;
        globals.isLocalLoggedIn = 1;
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AreaSelectionScreen(pjpList: PJPList,)),
        );
      } else {
        _showDialog("Error", "Invalid user id or password");
      }
    } else {
      _showDialog("Error", "Invalid user id or password");
    }
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
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String getCurrentDayOfWeek() {
    var currDate = new DateTime.now();
    // var weekday = currDate.weekday;
    var weekday = DateFormat('EEEE').format(currDate);
    return weekday;
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

  Future<bool> SaveCashSaleOrder() async {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());
    bool callreturn = false;
    print("globals.DeviceID:" + globals.DeviceID);
    String param = "timestamp=" +
        currDateTime +
        "&LoginUsername=" +
        _userid +
        "&LoginPassword=" +
        _password +
        "&DeviceID=" +
        globals.DeviceID +
        "&DeviceToken=123" +
        "&AppVersion=" +
        globals.appVersion;

    var QueryParameters = <String, String>{
      "SessionID": EncryptSessionID(param),
    };
    //try {


    print("Called1111");
    print("param"+param);
    var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileAuthenticateUserV5', QueryParameters);
     print("Url........." + url.toString());
      var response = await http.get(url, headers: {
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      });
      var responseBody = json.decode(latin1.decode(response.bodyBytes));
    print(responseBody.toString());

    if (response.statusCode == 200) {
        print(responseBody.toString());
        if (responseBody["success"] == "true") {
          globals.DisplayName = responseBody['DisplayName'];
          globals.UserID = int.tryParse(_userid);
          globals.pjpid = responseBody['BeatPlanID'];
          globals.maxDiscountPercentage = double.tryParse(responseBody['maximum_discount_percentage'].toString()) ;
          globals.distributorId = int.tryParse(responseBody['distributor_id'].toString());
          print("globals.maxDiscountPercentage"+globals.maxDiscountPercentage.toString());
          print("globals.distributorId"+globals.distributorId.toString());
          print("globals.pjpid :"+globals.pjpid.toString());
          Repository repo = new Repository();
          print(responseBody['OutletChannel'].toString());
          await repo.initdb();
          print("PJPList : "+responseBody['PJPList'].toString());
          PJPList = responseBody['PJPList'];

          repo.deleteUsers();
          repo.insertUser(User.fromJson({
            'user_id': responseBody['UserID'],
            'display_name': responseBody['DisplayName'],
            'designation': responseBody['Designation'],
            'department': responseBody['Department'],
            'distributor_employee_id': responseBody['DistributorEmployeeId'],
            'password': _password,
            'created_on': DateTime.now().toString(),
            'IsOutletLocationUpdate': responseBody['IsOutletLocationUpdate'].toString()
          }));
          globals.IsOutletLocationUpdate = responseBody['IsOutletLocationUpdate'];
          print("IsOutletLocationUpdate "+globals.IsOutletLocationUpdate.toString());
          print(User.fromJson({
            'user_id': responseBody['UserID'],
            'display_name': responseBody['DisplayName'],
            'designation': responseBody['Designation'],
            'department': responseBody['Department'],
            'distributor_employee_id': responseBody['DistributorEmployeeId'],
            'password': _password,
            'created_on': DateTime.now().toString()
          }));

          await repo.deleteAllProducts();
          await repo.deleteAllPreSellOutlet();
          await repo.deleteAllProductsLrbTypes();
          await repo.deleteAllSubCategories();
          await repo.deleteAllOutletProductsPrices();
          await repo.deleteAllSpotDiscount();
          repo.deleteNoOrderReasons();

          List ProductGroupRows = responseBody['ProductGroupRows'];
          print("===="+ProductGroupRows.toString());
          if (ProductGroupRows == null) {
            _showDialog("Error", "Product group is not assigned to this user");
          } else {
            List products_rows = responseBody['ProductGroupRows'];

            for (var i = 0; i < products_rows.length; i++) {
              await repo.insertProduct(Products.fromJson(products_rows[i]));
            }


            List pre_sell_outlets_rows = responseBody['BeatPlanRows'];
            print("..........................................");
            print(responseBody['BeatPlanRows']);
            print("..........................................");

            print("3");
            List no_order_reasons = responseBody['NoOrderReasonTypes'];
            print("4");
            for (var i = 0; i < no_order_reasons.length; i++) {
              await repo.insertNoOrderReason(
                  no_order_reasons[i]['ID'], no_order_reasons[i]['Label']);
            }
            print("5");
           /* for (var i = 0; i < pre_sell_outlets_rows.length; i++) {
              pre_sell_outlets_rows[i]['visit_type'] =
                  await repo.getVisitType(pre_sell_outlets_rows[i]['OutletID']);

              //alternate week day logic starts

              int isVisible = 0;
              if(globals.isOutletAllowed(pre_sell_outlets_rows[i]['IsAlternative'])){
                isVisible = 1;
              }
              pre_sell_outlets_rows[i]['is_alternate_visible'] = isVisible;

              //alternate week day logic ends

              await repo.insertPreSellOutlet(
                  PreSellOutlets.fromJson(pre_sell_outlets_rows[i]));
            }*/


            List product_lrb_types_rows = responseBody['ProductLrbTypes'];
            for (var i = 0; i < product_lrb_types_rows.length; i++) {
              await repo.insertProductsLrbTypes(
                  ProductsLrbTypes.fromJson(product_lrb_types_rows[i]));
            }

            List product_sub_categories_rows =
                responseBody['ProductSubCategories'];
            for (var i = 0; i < product_sub_categories_rows.length; i++) {
              await  repo.insertProductsSubCategories(ProductSubCategories.fromJson(
                  product_sub_categories_rows[i]));
            }
            print("7");
            //working here
            var db = await repo.getDatabaseObject();
            var batch = db.batch();
            List outlet_product_prices_rows =
                responseBody['ActivePriceListRows'];
            for (var i = 0; i < outlet_product_prices_rows.length; i++) {
              batch.rawInsert("insert into outlet_product_prices(price_id,outlet_id, product_id, raw_case,unit) values("+outlet_product_prices_rows[i]['PriceListID']+","+outlet_product_prices_rows[i]['OutletID']+","+outlet_product_prices_rows[i]['ProductID']+","+outlet_product_prices_rows[i]['RawCase']+","+outlet_product_prices_rows[i]['Unit']+")");
              //repo.insertOutletProductsPrices(OutletProductsPrices.fromJson(outlet_product_prices_rows[i]));
            }
            await batch.commit(noResult: true);
            await db.transaction((txn) async {

            });

            print("8");
            /******************************************************************************/
            //FARHAN WORK STARTS
            /******************************************************************************/
            await repo.deleteAllOutletAreas();
            await repo.deleteAllOutletSubAreas();
            await repo.deleteAllOutletProductsAlternativePrices();
            await repo.deleteAllPCISubAreas();

            await repo.deletePromotionsActive();
            await repo.deletePromotionsProducts();
            await repo.deletePromotionsProductsFree();
            await repo.deleteAllOutletChannel();
            print("8.1");
            List outlet_product_alternative_prices_rows =
                responseBody['PriceListRows'];


            for (var i = 0;
                i < outlet_product_alternative_prices_rows.length;
                i++) {
             repo.insertOutletProductsAlternativePrices(OutletProductsAlternativePrices.fromJson(outlet_product_alternative_prices_rows[i]));
            }
            print("9");
            List outlet_areas_rows = responseBody['OutletsAreas'];

            for (var i = 0; i < outlet_areas_rows.length; i++) {
              await repo.insertOutletAreas( OutletAreas.fromJson(outlet_areas_rows[i]));
            }
            print("10");
            List outlet_sub_areas_rows = responseBody['OutletsSubAreas'];
            print("outlet_sub_areas_rows  == >>>" +
                outlet_sub_areas_rows.toString());

            for (var i = 0; i < outlet_sub_areas_rows.length; i++) {
              await repo.insertOutletSubAreas(
                  OutletSubAreas.fromJson(outlet_sub_areas_rows[i]));
            }
            print("11");
            List pci_sub_channel_rows = responseBody['PCISubChannel'];
            print("pci_sub_channel_rows ===>>> " +
                pci_sub_channel_rows.toString());

            for (var i = 0; i < pci_sub_channel_rows.length; i++) {
              await  repo.insertPCISubAreas(
                  PCISubAreas.fromJson(pci_sub_channel_rows[i]));
            }
            print("12");
            await repo.deleteAllUserFeatures();
            List user_features_rows = responseBody['UserFeatures'];
            if(user_features_rows!=null){
              for (var i = 0; i < user_features_rows.length; i++) {
                await repo.insertFeatures(
                    UserFeatures.fromJson(user_features_rows[i]));
              }
            }
            print("12");
            List Channel_Outlets = responseBody['OutletChannel'];
            if(user_features_rows!=null){
              for (var i = 0; i < Channel_Outlets.length; i++) {
                await repo.insertChannel(
                    OutletChannel.fromJson(Channel_Outlets[i]));
              }
            }
            print("spotDiscount .............."+responseBody['spotDiscount'].toString());
            List discount_rows = responseBody['spotDiscount'];
           // globals.ChannelIDCHECK = discount_rows['ChannelID'];
            if(discount_rows!=null){
              for (var i = 0; i < discount_rows.length; i++) {
                await repo.insertSpotDiscount(discount_rows[i]['DiscountID'],discount_rows[i]['ProductID'], discount_rows[i]['DefaultDiscount'], discount_rows[i]['MaximumDiscount'],discount_rows[i]['ChannelID']);
              }
            }



            List promotions_products = responseBody['promotions_products'];

            for (var i = 0; i < promotions_products.length; i++) {

              List promotions_products_brands = promotions_products[i]['Brands'];
              for (var j = 0; j < promotions_products_brands.length; j++) {
                repo.insertPromotionsProducts(promotions_products[i]['PromotionID'], promotions_products[i]['PackageID'], promotions_products[i]['TotalUnits'], promotions_products_brands[j]['BrandID']);
              }


            }


            List promotions_products_free = responseBody['promotions_products_free'];

            for (var i = 0; i < promotions_products_free.length; i++) {

              List promotions_products_brands = promotions_products_free[i]['Brands'];
              for (var j = 0; j < promotions_products_brands.length; j++) {
                List<Map<String, dynamic>> product = await repo.getProductsByPackageIdAndBrandId(promotions_products_free[i]['PackageID'], promotions_products_brands[j]['BrandID']);
                repo.insertPromotionsProductsFree(promotions_products_free[i]['PromotionID'],  promotions_products_free[i]['PackageID'], promotions_products_free[i]['TotalUnits'], promotions_products_free[i]['PackageLabel'], promotions_products_brands[j]['BrandID'], promotions_products_brands[j]['BrandLabel'], 1,product[0]['product_id']);

              }


            }


            List promotions_active = responseBody['promotions_active'];

            for (var i = 0; i < promotions_active.length; i++) {

              repo.insertPromotionsActive(promotions_active[i]['PromotionID'], promotions_active[i]['OutletID']);


            }


            /******************************************************************************/
            //FARHAN WORK ENDS
            /******************************************************************************/

            callreturn = true;
          }
        } else {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          _showDialog("Error", responseBody["error_code"]);
          callreturn = false;
        }
      } else {
        // If that response was not OK, throw an error.
        callreturn = false;
        _showDialog("Error", "An error has occured " + responseBody.statusCode);
      }
    /*} catch (e) {
      //Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
      _showDialog("Error", "Check your internet connection:" + e.toString());
    }*/
    return callreturn;
  }

  Repository repo = new Repository();
  @override
  initState() {
    super.initState();
    repo.initdb();
    LoginType = false;
    globals.isFromLoginRoute=1;
    myFocusNode.addListener(_onFocusChange);
    Future.delayed(const Duration(seconds: 0), () async {
      _scrollController.animateTo(
        99,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    });

    var currDate = new DateTime.now();
    int weekDay = currDate.weekday;

    globals.WeekDay = globals.getPBCDayNumber(weekDay);
    DeviceID = "";

    _getDeviceId().then((val) {
      setState(() {
        DeviceID = val;
        globals.DeviceID = DeviceID;
      });
    });
  }



  void _onFocusChange() {
    if (myFocusNode.hasFocus) {
      _scrollController.animateTo(
        0,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    } else {
      _scrollController.animateTo(
        99,
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 300),
      );
    }

    //  debugPrint("Focus: "+myFocusNode.hasFocus.toString());
  }

  @override
  void dispose() {
    super.dispose();
    myFocusNode.dispose();
    _scrollController.dispose();
    numberController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var Height = MediaQuery.of(context).size.height;
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            //resizeToAvoidBottomPadding: false,
            //bottomNavigationBar:
            appBar: PreferredSize( //wrap with PreferredSize
                preferredSize: Size.fromHeight(20), //height of appbar
                child: AppBar(
                    title:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(DeviceID==null ? "":DeviceID, textAlign: TextAlign.center,style: TextStyle(fontSize: 10),), Text(globals.appVersion,style: TextStyle(fontSize: 10))],) ,

                    automaticallyImplyLeading: false,
                )
            ),
            // appBar:  AppBar(
            //           title:Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //            children: [Text(DeviceID==null ? "":DeviceID, textAlign: TextAlign.center,style: TextStyle(fontSize: 10),), Text(globals.appVersion,style: TextStyle(fontSize: 10))],) ,
            //
            //   automaticallyImplyLeading: false,
            //
            // ),
            resizeToAvoidBottomInset: false,
            key: scaffoldKey,
            body: new GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      //padding: EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                          color: Colors.blue[800],
                          gradient: LinearGradient(
                              colors: [Colors.blue,Colors.white]),
                          image: DecorationImage(
                            image: AssetImage("images/backgroundimage.png"),
                            fit: BoxFit.cover,
                          )),
                      child: Column(children: <Widget>[
                        new Form(
                          key: formKey,
                          child: new Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              DelayedAimation(
                                child: new Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: Height / 4,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          AvatarGlow(
                                              endRadius: 90,
                                              duration: Duration(seconds: 2),
                                              glowColor: Colors.black,
                                              repeat: true,
                                              shape: BoxShape.circle,
                                              animate: true,
                                              curve: Curves.fastOutSlowIn,
                                              showTwoGlows: true,
                                              repeatPauseDuration:
                                                  Duration(seconds: 1),
                                              startDelay: Duration(seconds: 1),
                                              child: Material(
                                                elevation: 2.0,
                                                shape: CircleBorder(),
                                                child: ClipOval(
                                                  child: Image(
                                                    fit: BoxFit.fill,
                                                    height: 130,
                                                    width: 130,
                                                    image: AssetImage(
                                                        'images/logo.png'),
                                                  ),
                                                ),
                                              ))
                                        ])),
                                delay: delayedAmount + 250,
                              ),
                              DelayedAimation(
                                child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxHeight:
                                          MediaQuery.of(context).size.height /
                                              2,
                                    ),
                                    child: ScrollConfiguration(
                                        behavior: MyBehavior(),
                                        child: ListView(
                                            controller: _scrollController,
                                            reverse: true,
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            children: <Widget>[
                                              new Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  // height: constraints.maxHeight,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 50.0,
                                                      ),
                                                      Text(
                                                        'Login',
                                                        style: TextStyle(
                                                            fontSize: 22.0,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.blue),
                                                      ),

                                                      SizedBox(
                                                        height: 20.0,
                                                      ),
                                                      DelayedAimation(
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            //initialValue: '2762',
                                                            keyboardType:
                                                                TextInputType
                                                                    .number,
                                                            onSaved: (val) =>
                                                                _userid = val,
                                                            inputFormatters: [
                                                              // WhitelistingTextInputFormatter.digitsOnly
                                                            ],
                                                            //onSaved: (val) => _username = val,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'User ID',
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          20.0,
                                                                          10.0,
                                                                          20.0,
                                                                          10.0),
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100.0)),
                                                            ),
                                                          ),
                                                          delay: delayedAmount +
                                                              500),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      DelayedAimation(
                                                          child: TextFormField(
                                                            autofocus: false,
                                                            //initialValue: 'nisa1234',
                                                            obscureText: true,
                                                            onSaved: (val) =>
                                                                _password = val,
                                                            decoration:
                                                                InputDecoration(
                                                              hintText:
                                                                  'Password',
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          20.0,
                                                                          10.0,
                                                                          20.0,
                                                                          10.0),
                                                              border: OutlineInputBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              100.0)),

                                                            ),
                                                          ),
                                                          delay: delayedAmount +
                                                              500),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      DelayedAimation(
                                                        child: CheckboxListTile(
                                                          checkColor:
                                                              Colors.white,
                                                          value: LoginType,
                                                          onChanged:
                                                              onLoginTypeChange,
                                                          title: Text(
                                                            'Local',
                                                            style: TextStyle(
                                                                color:
                                                                    Colors.blue),
                                                          ),
                                                          controlAffinity:
                                                              ListTileControlAffinity
                                                                  .leading,
                                                        ),
                                                        delay:
                                                            delayedAmount + 500,
                                                      ),
                                                      SizedBox(
                                                        height: 10.0,
                                                      ),
                                                      DelayedAimation(
                                                        child: Material(
                                                          // needed
                                                          color:
                                                              Colors.blue[600],
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          child: InkWell(
                                                            onTap: () {
                                                              if (formKey
                                                                      .currentState
                                                                      .validate() &&
                                                                  (numberController
                                                                          .text)
                                                                      .isNotEmpty) {
                                                                //  globals.mobileNo = numberController.text;

                                                              }
                                                              formKey
                                                                  .currentState
                                                                  .save();

                                                              _onTapDown();
                                                            }, // needed
                                                            child: Container(
                                                                height: 45.0,
                                                                child: Center(
                                                                  child: Text(
                                                                    'Login'
                                                                    /*AppLocalizations.of(context).translate('continue_string')*/,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18.0,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                )),
                                                          ),
                                                        ),
                                                        delay:
                                                            delayedAmount + 500,
                                                      ),

                                                      Container(
                                                          height: 45.0,
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Image(
                                                                fit: BoxFit.fill,
                                                                height: 35,
                                                                width: 35,
                                                                image: AssetImage(
                                                                    'images/logo.png'),
                                                              ),
                                                              Text(
                                                                'Powered by Kale Labs'
                                                                /*AppLocalizations.of(context).translate('continue_string')*/,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                    15.0,
                                                                    color: Colors
                                                                        .blue),
                                                              ),

                                                            ],
                                                          )),
                                                      SizedBox(
                                                        height: 100.0,
                                                      ),

                                                    ],
                                                  ))
                                            ]))),
                                delay: delayedAmount + 500,
                              ),
                            ],
                          ),
                        )
                      ]));
                },
              ),
            )));
  }
}
