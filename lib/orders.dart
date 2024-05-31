import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:order_booker/add_to_cart.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/com/pbc/model/outlet_orders.dart';
import 'package:order_booker/promotion_sku_selection.dart';
import 'package:order_booker/shopAction.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:badges/badges.dart' as badges;

import 'globals.dart' as globals;
import 'order_cart_view.dart';

class Orders extends StatefulWidget {
  int outletId = 0;
  @override
  Orders({int outletId}) {
    this.outletId = outletId;
  }
  _OrdersState createState() => _OrdersState(outletId);
}

class _OrdersState extends State<Orders> {
  int outletId = 0;
  int totalAddedProducts = 0;
  double totalAmount = 0.0;
  bool isLocationTimedOut = false;

  _OrdersState(int outletId) {
    this.outletId = outletId;
  }

  int orderId = 0;
  int currentOrderId = 0;
  List<Map<String, dynamic>> Products;
  List<Map<String, dynamic>> ProductsLrbTypes;
  List<Map<String, dynamic>> ProductsCatgories;
  List<Map<String, dynamic>> ProductsPrice;
  List<Map<String, dynamic>> AllOrders;
  List<Map<String, dynamic>> AllOrdersItems;

  int selectedLRBMenuValue = 0;
  int selectedCategoryMenuValue = 0;
  List<bool> SelectedLRBType = new List();
  List<bool> SelectedCategories = new List();
  Repository repo = new Repository();
  TextEditingController rateController = TextEditingController();
  TextEditingController discountController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  double priceRateAfterDiscount = 0.0;
  double priceRate = 0.0;

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    rateController.dispose();
    super.dispose();
  }

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  @override
  void initState() {
    discountController.text = "0";
    Products = new List();
    repo
        .getProducts(selectedLRBMenuValue, selectedCategoryMenuValue)
        .then((val) {
      setState(() {
        Products = val;
      });
    });

    repo.getProductsLrbTypes("%%").then((val) {
      setState(() {
        ProductsLrbTypes = val;
        for (int i = 0; i < ProductsLrbTypes.length; i++) {
          SelectedLRBType.add(false);
        }
      });
    });

    ProductsCatgories = new List();
    repo.getProductsSubCategories("%%").then((val) {
      setState(() {
        ProductsCatgories = val;

        for (int i = 0; i < ProductsCatgories.length; i++) {
          SelectedCategories.add(false);
        }
      });
    });

    getOrderNumber(outletId);
    getTotalOrders(outletId);

  }

  int getOrderNumber(int outletId) {
    AllOrders = new List();
    repo.getAllOrders(outletId, 0).then((val) {
      setState(() {
        AllOrders = val;
      });

      if (AllOrders.length < 1) {
        List<OutletOrders> order = new List();
        var currDate = new DateTime.now();
        String currentDat = currDate.toString();
        var str2 = currentDat.split(".");


        var str = currDate.toString();
        str = str.replaceAll("-", "");
        str = str.replaceAll(" ", "");
        str = str.replaceAll(":", "");
        var mobileOrderstr = str.split(".");
        orderId = globals.getUniqueMobileId();
        OutletOrders orderobj = new OutletOrders(
            id: orderId,
            //id: globals.getUniqueMobileId(),
            outlet_id: outletId,
            //created_on: TimeStamp,
            uuid: "abc",
            is_completed: 0,
            is_uploaded: 0,
            total_amount: 0.0,
            lat: 0,
            lng: 0,
            accuracy: 0);
        order.add(orderobj);
        initiateOrder(order);
        // Dialogs.showLoadingDialog(context, _keyLoader);
        /*
        Position position;
        globals.getCurrentLocation(context).then((position1) {
          position = position1;
          print(position1);
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
          if (position != null || isLocationTimedOut) {

            if(isLocationTimedOut==false){
              lat = position.latitude;
              lng = position.longitude;
              accuracy = position.accuracy;
            }

            OutletOrders orderobj = new OutletOrders(
                id: orderId,
                outlet_id: outletId,
                //created_on: TimeStamp,
                uuid: "abc",
                is_completed: 0,
                is_uploaded: 0,
                total_amount: 0.0,
                lat: lat,
                lng: lng,
                accuracy: accuracy);
            order.add(orderobj);
            initiateOrder(order);
          } else {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                // return object of type Dialog
                return AlertDialog(
                  title: new Text("Alert"),
                  content: new Text("Please allow location to proceed"),
                  actions: <Widget>[
                    // usually buttons at the bottom of the dialog
                    new FlatButton(
                      child: new Text("Close"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ShopAction()),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }

          //    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        });*/
      } else {
        orderId = AllOrders[0]['id'];
      }
    });
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    var isOpen = _pc.isPanelOpen;
    if (isOpen) {
      _pc.close();
    }
  }

  int getTotalOrders(int outletId) {
    AllOrders = new List();
    repo.getAllOrders(outletId, 0).then((val) async {
      setState(() {
        AllOrders = val;
      });
      AllOrdersItems = new List();
      for (int i = 0; i < AllOrders.length; i++) {
        repo.getAllAddedItemsOfOrder(AllOrders[i]['id']).then((val) async {
          setState(() {
            AllOrdersItems = val;
            //totalAddedProducts = AllOrdersItems.length;
            for (int i = 0; i < AllOrdersItems.length; i++) {
              totalAmount += AllOrdersItems[i]['amount'];
            }
          });
        });


        repo.getAllAddedItemsOfOrderByIsPromotion(AllOrders[i]['id'], 0).then((val) async {
          setState(() {

            totalAddedProducts = val.length;

          });
        });

      }
    });
  }

  int lastSelectedLRBIndex = -1;
  bool lastLRBSelection = false;
  int lastSelectedSubCategoryIndex = -1;
  bool lastSubCategorySelection = false;
  Widget _getLRBTypeList(BuildContext context, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        index == 0 ? Container() : Divider(),
        ListTile(
          selected: SelectedLRBType[index],
          selectedTileColor: SelectedLRBType[index] ? Colors.blue : Colors.white,
          focusColor: Colors.lightBlueAccent,
          onTap: () async {
            setState(() {
              //To reset Value
              selectedLRBMenuValue = 0;

              for (int i = 0; i < SelectedLRBType.length; i++) {
                SelectedLRBType[i] = false;
              }
              for (int i = 0; i < SelectedCategories.length; i++) {
                SelectedCategories[i] = false;
              }
              lastSelectedSubCategoryIndex = -1;
              lastSubCategorySelection = false;

              SelectedLRBType[index] = true;

              if (lastSelectedLRBIndex == index) {
                SelectedLRBType[index] = !lastLRBSelection;
                //SelectedLRBType[index]=false;
              }
              selectedLRBMenuValue = ProductsLrbTypes[index]['id'];
              if (SelectedLRBType[index] == false) {
                selectedLRBMenuValue = 0;
                selectedCategoryMenuValue = 0;
              }
            });

            ProductsCatgories = new List();
            //working here
            repo
                .getProductsSubCategoriesByCategoryId(selectedLRBMenuValue)
                .then((val) {
              setState(() {
                ProductsCatgories = val;

                for (int i = 0; i < ProductsCatgories.length; i++) {
                  SelectedCategories.add(false);
                }
              });
            });

            repo
                .getProducts(selectedLRBMenuValue, selectedCategoryMenuValue)
                .then((val) {
              setState(() {
                Products = val;
              });
            });

            lastSelectedLRBIndex = index;
            lastLRBSelection = SelectedLRBType[index];
          },
          title: Text(ProductsLrbTypes[index]['label'].toString(),
              style: new TextStyle(
                  fontSize: 13,
                  color:
                      SelectedLRBType[index] ? Colors.white : Colors.blueGrey)),
        ),
      ],
    );
  }

  FocusNode _focus = new FocusNode();

  Widget _getLRBTypeList2(BuildContext context, int index) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        index == 0 ? Container() : Divider(),
        Row(
          children: [
            InkWell(
                focusColor:
                    SelectedLRBType[index] ? Colors.lightBlue : Colors.white,
                highlightColor:
                    SelectedLRBType[index] ? Colors.lightBlue : Colors.white,
                splashColor: Colors.lightBlue,
                onTap: () {
                  setState(() {
                    //To reset Value
                    selectedLRBMenuValue = 0;

                    for (int i = 0; i < SelectedLRBType.length; i++) {
                      SelectedLRBType[i] = false;
                    }
                    for (int i = 0; i < SelectedCategories.length; i++) {
                      SelectedCategories[i] = false;
                    }
                    lastSelectedSubCategoryIndex = -1;
                    lastSubCategorySelection = false;

                    SelectedLRBType[index] = true;

                    if (lastSelectedLRBIndex == index) {
                      SelectedLRBType[index] = !lastLRBSelection;
                      //SelectedLRBType[index]=false;
                    }
                    selectedLRBMenuValue = ProductsLrbTypes[index]['id'];
                  });

                  ProductsCatgories = new List();
                  //working here
                  repo
                      .getProductsSubCategoriesByCategoryId(
                          selectedLRBMenuValue)
                      .then((val) {
                    setState(() {
                      ProductsCatgories = val;

                      for (int i = 0; i < ProductsCatgories.length; i++) {
                        SelectedCategories.add(false);
                      }
                    });
                  });

                  repo
                      .getProducts(
                          selectedLRBMenuValue, selectedCategoryMenuValue)
                      .then((val) {
                    setState(() {
                      Products = val;
                    });
                  });

                  lastSelectedLRBIndex = index;
                  lastLRBSelection = SelectedLRBType[index];
                },
                child: Text(
                  ProductsLrbTypes[index]['label'].toString(),
                  style: new TextStyle(
                      fontSize: 13,
                      color: SelectedLRBType[index]
                          ? Colors.white
                          : Colors.blueGrey),
                ))
          ],
        ),
      ],
    );
  }

  final _formKey = GlobalKey<FormState>();
  Widget _getSubCategoirsList(BuildContext context, int index) {
    return Column(
      children: <Widget>[
        index == 0 ? Container() : Divider(),
        ListTile(
          selected: SelectedCategories[index],
          selectedTileColor:
              SelectedCategories[index] ? Colors.blue : Colors.white,
          focusColor: Colors.lightBlueAccent,
          onTap: () async {
            setState(() {
              //To reset value
              selectedCategoryMenuValue = 0;

              for (int i = 0; i < SelectedCategories.length; i++) {
                SelectedCategories[i] = false;
              }
              SelectedCategories[index] = true;
              if (lastSelectedSubCategoryIndex == index) {
                SelectedCategories[index] = !lastSubCategorySelection;
                //SelectedLRBType[index]=false;
              }
              selectedCategoryMenuValue = ProductsCatgories[index]['id'];
              if (!SelectedCategories[index]) {
                selectedCategoryMenuValue = 0;
              }
            });

            repo
                .getProducts(selectedLRBMenuValue, selectedCategoryMenuValue)
                .then((val) {
              setState(() {
                Products = val;
              });
            });

            lastSelectedSubCategoryIndex = index;
            lastSubCategorySelection = SelectedCategories[index];
          },
          title: Text(ProductsCatgories[index]['label'].toString(),
              style: new TextStyle(
                  fontSize: 13,
                  color: SelectedCategories[index]
                      ? Colors.white
                      : Colors.blueGrey)),
        ),
      ],
    );
  }

  void initiateOrder(List<OutletOrders> order) {
    // repo.deleteAllUnUsedOrder(outlet_id);

    for (var i = 0; i < order.length; i++) {
      repo.initOrder(
          order[i].id,
          order[i].outlet_id,
          order[i].is_completed,
          order[i].is_uploaded,
          order[i].total_amount,
          order[i].uuid,
          order[i].created_on,
          order[i].lat,
          order[i].lng,
          order[i].accuracy);
    }
  }

  void addItemOrder(orderId, List Items) {
    repo.addItemToCurrentOrder(orderId, Items, 0);
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
          priceRateAfterDiscount = ProductsPrice[0]["raw_case"];
          priceRate = ProductsPrice[0]["raw_case"];
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
          }
        });
      });
    });
  }

  bool isQuantityNotAdded = false;
  void _showDialog(int productId, String productLabel, int outletId) {
    getProductPrice(productId, outletId);

    showDialog(
      context: context,
      builder: (context) {
        String contentText = "Content of Dialog";
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: EdgeInsets.all(10),
                child: Stack(
                  clipBehavior: Clip.none, alignment: Alignment.topCenter,
                  children: <Widget>[
                    Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 1.8,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white),
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                    child: Text(productLabel),
                                  ),
                                  Container(
                                    // width: cardWidth,
                                    padding: EdgeInsets.all(5.0),
                                    child: TextField(
                                        controller: rateController,
                                        keyboardType: TextInputType.number,
                                        readOnly: true,
                                        autofocus: false,
                                        onChanged: (val) {},
                                        decoration: InputDecoration(
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.black12,
                                                width: 0.0),
                                          ),
                                          labelText: 'Rate',
                                        )),
                                  ),
                                  Container(
                                    // width: cardWidth,
                                    padding: EdgeInsets.all(5.0),
                                    child: TextFormField(
                                        controller: discountController,
                                        keyboardType: TextInputType.number,
                                        autofocus: false,
                                        onChanged: (val) {
                                          //ToReset Value to intital
                                          priceRateAfterDiscount = priceRate;
                                          priceRateAfterDiscount = priceRate -
                                              double.parse(
                                                  discountController.text);
                                          if (int.parse(
                                                  quantityController.text) !=
                                              0) {
                                            double amount = 0;
                                            double price = double.parse(
                                                    quantityController.text) *
                                                priceRateAfterDiscount;
                                            amountController.text =
                                                price.toString();
                                          }
                                        },
                                        decoration: InputDecoration(
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.black12,
                                                width: 0.0),
                                          ),
                                          labelText: 'Discount',
                                        )),
                                  ),
                                  Container(
                                    // width: cardWidth,
                                    padding: EdgeInsets.all(5.0),
                                    child: TextFormField(
                                        autofocus: true,

                                        onChanged: (val) {

                                          double price = double.parse(val) *
                                              priceRateAfterDiscount;
                                          amountController.text =
                                              price.toString();
                                        },
                                        validator: (val) {
                                          if (val == null ||
                                              val.isEmpty ||
                                              int.parse(val) <= 0) {
                                            return 'Please enter a valid quantity.';
                                          }
                                          return null;
                                        },
                                        controller: quantityController,
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
                                  ),
                                  /*Visibility(
                                  visible: isQuantityNotAdded,
                                    child:
                                      Container(
                                        alignment: Alignment.topLeft,
                                        child: Text("ABC",textAlign: TextAlign.left,style: TextStyle(color: Colors.blue),),
                                      ),
                                ),*/
                                  Container(
                                    // width: cardWidth,
                                    padding: EdgeInsets.all(5.0),
                                    child: TextField(
                                        autofocus: false,
                                        readOnly: true,
                                        onChanged: (val) {},
                                        keyboardType: TextInputType.number,
                                        controller: amountController,
                                        decoration: InputDecoration(
                                          enabledBorder:
                                              const UnderlineInputBorder(
                                            borderSide: const BorderSide(
                                                color: Colors.black12,
                                                width: 0.0),
                                          ),
                                          labelText: 'Amount',
                                        )),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: MaterialButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        color: Colors.lightBlue,
                                        child: Text(
                                          'Add to Cart',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        onPressed: () async {
                                          if (_formKey.currentState
                                              .validate()) {
                                            double Discount = 0;
                                            if (discountController.text == "") {
                                              Discount = 0;
                                            } else {
                                              Discount = double.parse(
                                                  discountController.text);
                                            }

                                            List Items = new List();
                                            DateFormat dateFormat = DateFormat(
                                                "dd/MM/yyyy HH:mm:ss");
                                            String currDateTime = dateFormat
                                                .format(DateTime.now());
                                            var str = currDateTime.split(".");
                                            Items.add({
                                              'product_id': productId,
                                              'discount': Discount,
                                              'quantity': int.parse(
                                                  quantityController.text),
                                              'amount': double.parse(
                                                  amountController.text),
                                              'created_on': str[0],
                                              'rate': double.parse(
                                                  rateController.text),
                                              'product_label': productLabel
                                            });

                                            addItemOrder(orderId, Items);

                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Orders(
                                                      outletId:
                                                          globals.OutletID)),
                                            );
                                          }

                                          //  order.add()
                                        }),
                                  )
                                ],
                              )),
                        ],
                      ),
                    ),

                  ],
                ));
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: Products != null ? Products.length : 0,
      itemBuilder: _getOutletsList,
    );
  }

  Widget _getOutletsList(BuildContext context, int index) {
    //  print(Products);
    return Column(
      children: <Widget>[
        index == 0 ? Container() : Divider(),
        Container(
          child: ListTile(
            onTap: () async {
              //_showDialog(Products[index]['product_id'],Products[index]['product_label'].toString(),outletId);
              globals.productLabel =
                  Products[index]['product_label'].toString();
              globals.productId = Products[index]['product_id'];
              globals.orderId = orderId;

              Navigator.push(
                context,
                //

                MaterialPageRoute(builder: (context) => AddToCart(1)
                    //  MaterialPageRoute(builder: (context) =>ShopAction_test()

                    ),
              );
            /*
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          AddToCart(1)),
                  ModalRoute.withName("/Orders"));*/


            },
            title: Text(Products[index]['package_label'].toString(),
                style: new TextStyle(fontSize: 16)),
          ),
        ),
        (Products.length - 1) == index
            ? Container(
                height: 500,
              )
            : Container(height: 0)
      ],
    );
  }

  double cardWidth = 0.0;
  PanelController _pc = new PanelController();
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    cardWidth = width / 1.1;

    BorderRadiusGeometry radius = BorderRadius.only(
      topLeft: Radius.circular(24.0),
      topRight: Radius.circular(24.0),
    );
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[800],
          leading: Container(
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 15.0, 0.0),
              child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopAction()),
                    );
                  })),
          actions: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
             /*   Flexible(
                    child: Container(
                  padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                  child: IconButton(
                      icon: Icon(Icons.account_balance_wallet),
                      color: Colors.white,
                      onPressed: () {}),
                )),*/
              /*  Flexible(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(0.0, 10.0, 15.0, 0.0),
                        child: Text(
                          globals
                              .getDisplayCurrencyFormat(totalAmount)
                              .toString(),
                          style: TextStyle(color: Colors.white),
                        )))*/
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.0, 10.0, 15.0, 0.0),
              child: badges.Badge(
                badgeContent: Text(
                  totalAddedProducts.toString(),
                  style: TextStyle(color: Colors.white),
                ),
                badgeColor: Colors.black,
                child: IconButton(
                    icon: Icon(Icons.shopping_cart),
                    color: Colors.white,
                    onPressed: () {
                      if(globals.isMultipleProductsFree==0){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  OrderCartView(OrderId: currentOrderId)),
                        );
                      }else{
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  PromotionSkuSelection()),
                        );
                      }
                    }),
              ),
            ),
          ],
        ),
        body: SlidingUpPanel(
          maxHeight: 250,
          minHeight: 70,
          backdropTapClosesPanel: true,
          backdropEnabled: false,
          panelSnapping: false,
          controller: _pc,
          panel: Center(
            child: Column(
              children: [
                Container(
                  color: Colors.black54,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 10.0),
                          child: Text(
                            "Categories",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 10.0),
                          child: Text(
                            "Sub Categories",
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Container(
                          height: 250,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                  child: ListView.builder(
                                shrinkWrap: true,
                                //physics: ClampingScrollPhysics(),
                                itemCount: ProductsLrbTypes != null
                                    ? ProductsLrbTypes.length
                                    : 0,
                                itemBuilder: _getLRBTypeList,
                              )),
                            ],
                          )),
                    ),
                    Expanded(
                      child: Container(
                          height: 250,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                  child: ListView.builder(
                                shrinkWrap: true,
                                //physics: ClampingScrollPhysics(),
                                itemCount: ProductsCatgories.length,
                                itemBuilder: _getSubCategoirsList,
                              )),
                            ],
                          )),
                    ),
                  ],
                ))
              ],
            ),
          ),
          collapsed: GestureDetector(
            onTap: () {
              var isOpen = _pc.isPanelOpen;

              var isclose = _pc.isPanelClosed;

              if (isOpen) {
                _pc.close();
              }
              if (isclose) {
                _pc.open();
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  "Filters",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                // width: cardWidth,
                margin: EdgeInsets.all(5.0),
                child: TextField(
                    focusNode: _focus,
                    autofocus: false,
                    onChanged: (val) {
                      repo
                          .getProductsBySerachMethod(selectedLRBMenuValue,
                              selectedCategoryMenuValue, val)
                          .then((val) {
                        setState(() {
                          Products = val;
                        });
                      });
                    },
                    decoration: InputDecoration(
                      enabledBorder: const UnderlineInputBorder(
                        borderSide:
                            const BorderSide(color: Colors.black12, width: 0.0),
                      ),
                      prefixIcon: const Icon(
                        Icons.search_sharp,
                      ),
                      labelText: 'Search',
                    )),
              ),
              _buildListView(),
            ],
          )),
        ),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text("Open"),
            onPressed: () => _pc.open(),
          ),
          ElevatedButton(
            child: Text("Close"),
            onPressed: () => _pc.close(),
          ),
          ElevatedButton(
            child: Text("Show"),
            onPressed: () => _pc.show(),
          ),
          ElevatedButton(
            child: Text("Hide"),
            onPressed: () => _pc.hide(),
          ),
        ],
      ),
    );
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
