import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'dart:math' as math;

import 'Unregisteredorders.dart';
import 'UnregisteredshopAction.dart';
import 'globals.dart' as globals;

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  runApp(UnregisteredAddToCart(globals.OutletID));
}

// This app is a stateful, it tracks the user's current choice.
class UnregisteredAddToCart extends StatefulWidget {
  int OutletId;

  UnregisteredAddToCart(OutletId) {
    this.OutletId = OutletId;

    print(OutletId);
  }
  @override
  _UnregisteredAddToCart createState() => _UnregisteredAddToCart(OutletId);
}

class _UnregisteredAddToCart extends State<UnregisteredAddToCart> {
  int OutletId;
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String selected;
  int weekday;
  int AddToCartReason;
  bool isDiscountAllowed = false;
  List<Map<String, dynamic>> AllAddToCarts;
  String _SelectFerightTerms;
  _UnregisteredAddToCart(OutletId) {
    this.OutletId = OutletId;
  }
  Repository repo = new Repository();
  List Days = new List();

  TextEditingController rateController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  List<bool> isSelected = [false, false, false, false, false, false, false];
  double maximumDiscount = 0;
  double defaultDiscount = 0;
  int DiscountID = 0;

  final _formkey = GlobalKey<FormState>();
  List<Map<String, dynamic>> AddToCartReasons;

  Future GetOutletOrderItemInfo() async {
    List OutletOrder = List();
    print(globals.unregisterorderid);
    print(globals.ProductID);
    OutletOrder =
    await repo.getOrderItemInfo(globals.unregisterorderid, globals.productId);

    OutletOrder = OutletOrder;
    if (OutletOrder.isNotEmpty) {
      setState(() {
        print(OutletOrder[0]["quantity"].toString());
        // quantityController.text = OutletOrder[0]["quantity"].toString();
        final _newValue = OutletOrder[0]["quantity"].toString();
        quantityController.value = TextEditingValue(
          text: _newValue,
          selection: TextSelection.fromPosition(
            TextPosition(offset: _newValue.length),
          ),
        );
      });
    }

    print(OutletOrder);
  }
  FocusNode myFocusNode;
  @override
  void initState() {
    //AddToCartReasons=new List();
    AddToCartReason = 0;
    discountController.text = "0";
    myFocusNode = FocusNode();
    Future.delayed(const Duration(seconds: 1), () async {
      // myFocusNode.requestFocus();
    });
    //weeK DAY to be Placed
    weekday = globals.WeekDay;

    AddToCartReasons = new List();

    if (weekday > 0) {
      isSelected[weekday - 1] = true;
    } else {
      isSelected[0] = true;
    }
    getProductPrice(globals.productId, globals.OutletID);

    repo.getAvailableStock(globals.productId).then((value)  {
      setState(() {
        stockController.text=  value.toInt().toString();
      });
    });

    globals.isFeatureAllowed(411).then((value)  {
      setState(() {
        isDiscountAllowed = value;
      });
    });

    repo.getSpotDiscount(globals.productId,globals.UnregisterChannelID).then((value) => {
      setState(() {
        if(value==null){
          DiscountID = 0;
          defaultDiscount = 0;
          maximumDiscount = 0;
          discountController.text = defaultDiscount==null ? "0": defaultDiscount.toString();

        }else{
          DiscountID = value['DiscountID'];
          defaultDiscount = value['default_discount'];
          maximumDiscount = value['maximum_discount'];
          defaultDiscount = value['default_discount'];
          discountController.text = defaultDiscount==null ? "0": defaultDiscount.toString();

        }

        print("defaultDiscount : " + defaultDiscount.toString());
        print("DiscountID : " + DiscountID.toString());
      })
    });


    GetOutletOrderItemInfo();
  }

  setAddToCartReason(int val) {
    setState(() {
      AddToCartReason = val;
    });
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

                    MaterialPageRoute(builder: (context) => UnregisteredShopAction()
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

  Widget _getAddToCartReasonsList(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        index == 0 ? Container() : Divider(),
        Container(
          child: RadioListTile(
            value: AddToCartReasons[index]['id'],
            groupValue: AddToCartReason,
            title: Text("" + AddToCartReasons[index]['label'],
                style: new TextStyle(fontSize: 16, color: Colors.black54)),
            //subtitle: Text("Radio 1 Subtitle"),
            onChanged: (val) {
              setAddToCartReason(val);
            },
            activeColor: Colors.orange[200],

            selected: true,
          ),
        )
      ],
    );
  }

  double cardWidth = 0.0;
  double priceRateCal = 0.0;
  double priceRateAfterDiscount = 0.0;
  double priceRate = 0.0;

  final _formKey = GlobalKey<FormState>();
  bool isQuantityNotAdded = false;
  List<Map<String, dynamic>> ProductsPrice;

  void addItemOrderV0(orderId, List Items) {
    //repo.addItemToCurrentOrder(orderId, Items);
  }

  Future<void> addItemOrder(orderId,  productId, discount, quantity, amount, createdOn, rate, productLabel) async {
    var sourceId = globals.getUniqueMobileId();
    List Items = new List();
    Items.add({
      'product_id': productId,
      'discount': discount,
      'quantity': quantity,
      'amount': amount,
      'created_on': createdOn,
      'rate': rate,
      'product_label': productLabel,
      'unit_quantity': 0,
      'is_promotion': 0,
      'promotion_id': 0,
      'id': sourceId,
      'source_id': 0,
      'DiscountID' : DiscountID,
      'defaultDiscount' : defaultDiscount,
      'maximumDiscount' : maximumDiscount
    });
    int isNewEntry  = await  repo.addItemToCurrentOrder(orderId, Items, 0);

    List<Map<String, dynamic>> product = await repo.getProductById(productId);
    List<Map<String, dynamic>> promotionalProduct = await repo.getAllPromotionalProduct(globals.OutletID, product[0]['package_id'], product[0]['brand_id']);
    int promotionId = await repo.getPromotionId(globals.OutletID, product[0]['package_id'], product[0]['brand_id']);
    if(promotionalProduct!=null && promotionalProduct.isNotEmpty){
      int unitsApplicable = promotionalProduct[0]['total_units'];
      print('unitsApplicable ' + unitsApplicable.toString());
      int quantityUnits = product[0]['unit_per_case']*quantity;
      print('quantityUnits'+quantityUnits.toString());
      int  freeUnits = 0;
      if(quantityUnits>=unitsApplicable){
        freeUnits =  (quantityUnits/unitsApplicable).round();
        print(freeUnits =  (quantityUnits/unitsApplicable).round());
      }



      if(freeUnits>0){
        print('promotion_id:' + promotionId.toString());
        List<Map<String, dynamic>> freeProduct = await repo.getPromotionProductsFree(promotionId);
        if(freeProduct.length>1){
          globals.isMultipleProductsFree = 1;
        }else{
          globals.isMultipleProductsFree = 0;
        }
        print('freeProduct'+freeProduct.toString());
        int Remainder = 0;

        Remainder = (quantityUnits/48).toInt();
        print('Remainder'+Remainder.toString());
        if(freeUnits % 48 == 0) {
          freeUnits = freeUnits * freeProduct[0]['total_units'];
        }else{
          if(Remainder<2){
            freeUnits = freeProduct[0]['total_units'];
          }else{
            freeUnits = Remainder*4;
          }
        }
        print('freeUnits' + freeUnits.toString());
        //print(freeUnits = freeUnits*freeProduct[0]['total_units']);
        product = await repo.getProductsByPackageIdAndBrandId(freeProduct[0]['package_id'], freeProduct[0]['brand_id']);
        Items = new List();
        Items.add({
          'product_id': product[0]['product_id'],
          'discount': 0.0,
          'quantity': 0,
          'amount': 0.0,
          'created_on': createdOn,
          'rate': 0,
          'product_label': product[0]['package_label'],

          'unit_quantity': freeUnits,
          'is_promotion': 1,
          'promotion_id': promotionId,
          'id': globals.getUniqueMobileId(),
          'source_id':sourceId,
          'DiscountID':DiscountID,
          'defaultDiscount' : defaultDiscount,
          'maximumDiscount' : maximumDiscount
        });
        repo.addItemToCurrentOrder(orderId, Items, isNewEntry);

      }


    }



  }
  double getProductPrice(productId, outletId) {
    repo.getActiveProductPriceList(productId, outletId).then((val) async {
      setState(() {
        isQuantityNotAdded = false;
        amountController.text = "";
        quantityController.text = "";
        discountController.text = "";

        ProductsPrice = val;
        if (ProductsPrice.isNotEmpty) {
          print(      "raw_case" +  ( priceRateAfterDiscount = ProductsPrice[0]["raw_case"]).toString());
          priceRateAfterDiscount = ProductsPrice[0]["raw_case"];
          priceRate = ProductsPrice[0]["raw_case"];
          /*if(globals.maxDiscountPercentage>0 && priceRate>0){
            maximumDiscount = priceRate/100*globals.maxDiscountPercentage;
            print("print(maximumDiscount);"+maximumDiscount.toString());
          }*/

        }

        /*  priceRateAfterDiscount=153;
        priceRate=153;*/

        rateController.text = priceRate.toString();

      });

      await repo.getOutletProductsAlternativePrices(productId).then((val2) {
        setState(() {
          if (ProductsPrice.isEmpty) {
            ProductsPrice = val2;
            priceRateAfterDiscount = ProductsPrice[0]["raw_case_price"];
            priceRate = ProductsPrice[0]["raw_case_price"];
            rateController.text = priceRate.toString();

            /*if(globals.maxDiscountPercentage>0 && priceRate>0){
              maximumDiscount = priceRate/100*globals.maxDiscountPercentage;
              print("print(maximumDiscount);"+maximumDiscount.toString());
            }*/

          }
        });

      });
    });
  }
  onDiscountChange(val){

    if(val==null){
      val="0";
    }
    priceRateAfterDiscount = priceRate;
    print("Parse discountController"+double.parse(discountController.text).toString());
    print("Parse discountController"+maximumDiscount.toString());
    String errorMessage = "Discount cannot be greater than rate";
    if(double.parse(discountController.text)>maximumDiscount){
      errorMessage = "Discount cannot be greater than " + maximumDiscount.toString() + "";
    }
    if(double.parse(discountController.text)<defaultDiscount){
      errorMessage = "Discount cannot be less than " + defaultDiscount.toString() + "";
    }

    print("check......................................");
    print("maximumDiscount==> " + maximumDiscount.toString());
    print("discountController 1==> " + discountController.text.toString());

    if (double.parse(discountController.text) < priceRate && double.parse(discountController.text)<=maximumDiscount && double.parse(discountController.text) >= defaultDiscount ) {
     // priceRateAfterDiscount = priceRate - double.parse(discountController.text);
      priceRateCal = priceRate * double.parse(discountController.text)/100;
      priceRateAfterDiscount = priceRate - priceRateCal;
      print("discountController==> " + discountController.text.toString());
      print("priceRateAfterDiscount==> " + priceRateAfterDiscount.toString());

    } else {
      Flushbar(
        messageText: Column(
          children: <Widget>[
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundGradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black
            ]),
        icon: Icon(
          Icons.notifications_active,
          size: 30.0,
          color: Colors.blue,
        ),
        duration: Duration(seconds: 2),
        leftBarIndicatorColor: Colors.blue,
      )..show(context);
    }
    if (int.parse(quantityController.text) !=
        0) {
      double amount = 0;
      double price = double.parse(
          quantityController.text) *
          priceRateAfterDiscount;
      amountController.text =
          price.toStringAsFixed(2);
    }
  }

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
          key: _formkey,
          appBar: AppBar(
            backgroundColor: Colors.blue[800],
            title: Text(
              globals.productLabel,
              style: new TextStyle(color: Colors.white, fontSize: 14),
            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              UnregisteredOrders()),
                      ModalRoute.withName("/Orders"));
                }),
          ),
          backgroundColor: Colors.white,
          body: Stack(
            clipBehavior: Clip.none, alignment: Alignment.topCenter,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Card(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white),
                          padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                        // width: cardWidth,
                                        padding: EdgeInsets.all(5.0),
                                        child: TextField(
                                            controller: stockController,
                                            keyboardType: TextInputType.number,

                                            readOnly: true,
                                            autofocus: false,
                                            onChanged: (val) {},
                                            decoration: InputDecoration(
                                              enabledBorder: const UnderlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black12, width: 0.0),
                                              ),
                                              labelText: 'Available Stock',
                                            )),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                        // width: cardWidth,
                                        padding: EdgeInsets.all(5.0),
                                        child: TextField(
                                            controller: rateController,
                                            keyboardType: TextInputType.number,
                                            readOnly: true,
                                            autofocus: false,
                                            onChanged: (val) {},
                                            decoration: InputDecoration(
                                              enabledBorder: const UnderlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black12, width: 0.0),
                                              ),
                                              labelText: 'Rate',
                                            )),
                                      )),

                                  Expanded(
                                      child: Container(
                                        // width: cardWidth,
                                        padding: EdgeInsets.all(5.0),
                                        child: TextFormField(
                                            autofocus: true,
                                            onChanged: (val) {
                                              print("productId"+globals.productId.toString());
                                              print("=========="+val.toString());
                                              quantityController.text=val;
                                              print("priceRate" + priceRate.toString());
                                              print("discountController" + discountController.text.toString());
                                              priceRateCal = priceRate * double.parse(discountController.text)/100;
                                              priceRateAfterDiscount = priceRate - priceRateCal;
                                              double price = double.parse(val) * priceRateAfterDiscount;
                                              amountController.text =
                                                  price.toString();
                                              print("Val"+val);
                                              print("priceRateAfterDiscount"+priceRateAfterDiscount.toString());
                                              print("price"+price.toString());


                                            },
                                            validator: (val) {
                                              if (val == null ||
                                                  val.isEmpty ||
                                                  int.parse(val) <= 0) {
                                                return 'Please enter a valid quantity.';
                                              }
                                              return null;
                                            },
                                            focusNode: myFocusNode,
                                            // controller: quantityController,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              enabledBorder:
                                              const UnderlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black12,
                                                    width: 0.0),
                                              ),
                                              labelText: 'Quantity *',
                                            )),
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                      child: Container(
                                        // width: cardWidth,
                                        padding: EdgeInsets.all(5.0),
                                        child: TextFormField(
                                          //inputFormatters: [DecimalTextInputFormatter(decimalRange: 2)],
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                                            ],

                                            enabled: isDiscountAllowed,
                                            enableInteractiveSelection: isDiscountAllowed,
                                            controller: discountController,
                                            keyboardType: TextInputType.number,
                                            autofocus: false,
                                            onChanged: (val) {
                                              //ToReset Value to intital
                                              onDiscountChange(val);
                                            },
                                            decoration: InputDecoration(
                                              enabledBorder: const UnderlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black12, width: 0.0),
                                              ),
                                              labelText: 'Discount',
                                            )),
                                      )),
                                  Expanded(
                                      child: Container(
                                        // width: cardWidth,
                                        padding: EdgeInsets.all(5.0),
                                        child: TextField(
                                            autofocus: false,
                                            readOnly: true,
                                            onChanged: (val) {},
                                            keyboardType: TextInputType.number,
                                            controller: amountController,
                                            decoration: InputDecoration(
                                              enabledBorder: const UnderlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.black12, width: 0.0),
                                              ),
                                              labelText: 'Amount',
                                            )),
                                      )),
                                ],
                              )
                            ],
                          ),
                        )),
                    Expanded(
                      child: Align(
                          alignment: FractionalOffset.bottomCenter,
                          child: Container(
                            color: Colors.blue,
                            height: 57,
                            //  color: Colors.blue,
                            child: InkWell(
                              onTap: () {
                                if (_formKey.currentState.validate()) {
                                  double Discount = 0;
                                  if (discountController.text == "") {
                                    Discount = 0;
                                  } else {
                                    Discount =
                                        double.parse(discountController.text);
                                  }
                                  String errorMessage = "Discount cannot be greater than rate";
                                  if(Discount>maximumDiscount){
                                    errorMessage = "Discount cannot be greater than " + maximumDiscount.toString() + "";
                                  }
                                  print("defaultDiscount==>"+defaultDiscount.toString());
                                  print("Discount==>"+Discount.toString());
                                  if ( Discount < defaultDiscount) {
                                    errorMessage = "Discount cannot be less than " + defaultDiscount.toString();
                                  }

                                  //defaultDiscount
                                  if (Discount < priceRate && Discount <= maximumDiscount && Discount >= defaultDiscount) {
                                    globals.AfterSpotDsicount = priceRateAfterDiscount;

                                    DateFormat dateFormat =
                                    DateFormat("dd/MM/yyyy HH:mm:ss");
                                    String currDateTime =
                                    dateFormat.format(DateTime.now());
                                    var str = currDateTime.split(".");


                                    addItemOrder(globals.unregisterorderid, globals.productId, Discount, int.parse(quantityController.text), double.parse(amountController.text), str[0], double.parse(rateController.text), globals.productLabel);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                UnregisteredOrders()),
                                        ModalRoute.withName("/Orders"));
                                    /*
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Orders(
                                              outletId: globals.OutletID)),
                                    );
                                    */
                                  } else {
                                    Flushbar(
                                      messageText: Column(
                                        children: <Widget>[
                                          Text(
                                            errorMessage,
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundGradient: LinearGradient(
                                          colors: [Colors.black, Colors.black]),
                                      icon: Icon(
                                        Icons.notifications_active,
                                        size: 30.0,
                                        color: Colors.blue,
                                      ),
                                      duration: Duration(seconds: 2),
                                      leftBarIndicatorColor: Colors.blue,
                                    )..show(context);
                                  }
                                }
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.add_shopping_cart_sharp,
                                      color: Colors.white),
                                  Text("Add to Cart",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ) //Your widget here,
                      ),
                    ),
                  ],
                ),
              ),
/*
                    Positioned(
                        top: -90,
                        child:  Container(
                          width: 120,
                          height: 120,
                          decoration: new BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset("assets/images/cart.png",width: 100,height: 100,),
                        )
                    ),
            */
              /*    Positioned(
              top: 10,
              child:Container(
                child:,
              ),)*/
            ],
          )),
    );
  }
}
