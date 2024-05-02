import 'dart:convert';
import 'dart:io';
import 'dart:math';


import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:intl/intl.dart';
import 'package:order_booker/home.dart';
import 'package:order_booker/orders_report_view.dart';
import 'package:order_booker/sales_report_view.dart';
import 'package:progress_dialog/progress_dialog.dart';
// import 'package:wave/config.dart';
// import 'package:wave/wave.dart';
import 'globals.dart' as globals;
import 'package:http/http.dart' as http;

class OrdersReportSelectDate extends StatefulWidget {
  @override
  OrdersReportSelectDateState createState() => OrdersReportSelectDateState();
}

class OrdersReportSelectDateState extends State<OrdersReportSelectDate> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  ProgressDialog signupProgressDialog;
  final _dateFormat = new DateFormat('dd/MM/yyyy');


  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  @override
  initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    startDateController.text = _dateFormat.format(startDate).toString();
    endDateController.text = _dateFormat.format(endDate).toString();



  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("BACK BUTTON!"); // Do some stuff.
    //work here


    return true;
  }
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, var date, var dateController) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: date,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != date){
      setState(() {
        date = picked;
        dateController.text = _dateFormat.format(date).toString();
      });
    }

  }


  @override
  Widget build(BuildContext context) {
    signupProgressDialog = new ProgressDialog(context, isDismissible: false);
    var _height = MediaQuery.of(context).size.height;


    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            "Orders Report",
            style: TextStyle(fontSize: 15),
          ),
          backgroundColor: Colors.yellow[800],
          /*actions: <Widget>[
            FlatButton(
              textColor: Colors.white,
              onPressed: () {
                  globals.ordersReportStartDate = startDateController.text ;
                  globals.ordersReportEndDate = endDateController.text;
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => OrdersReportView()),
                      ModalRoute.withName("/orders_report"));
              },
              child: Text("View"),
              shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
            ),
          ],*/

          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Home()),
                    ModalRoute.withName("/home"));
              }),
        ),
        body: new GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: SingleChildScrollView(
              child: Container(
                // height: _height,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[

                    ListView(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        Divider(),
                      ListTile(
                        onTap: () {
                          //startDate.subtract(Duration(days: 1));
                          //endDate.subtract(Duration(days: 1));
                          globals.ordersReportStartDate = _dateFormat.format(startDate) ;
                          globals.ordersReportEndDate = _dateFormat.format(endDate) ;

                          print("globals.ordersReportStartDate:" + globals.ordersReportStartDate);
                          print("globals.ordersReportEndDate:" + globals.ordersReportEndDate);

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => OrdersReportView()),
                              ModalRoute.withName("/orders_report"));


                        },
                        leading: Text(""),
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: Text("Today",
                            style: new TextStyle(fontSize: 16, )),
                      ),
                        Divider(),

                        ListTile(
                          onTap: () {

                            globals.ordersReportStartDate = _dateFormat.format(startDate.subtract(Duration(days: 1))) ;
                            globals.ordersReportEndDate = _dateFormat.format(endDate.subtract(Duration(days: 1))) ;
                            print("globals.ordersReportStartDate:" + globals.ordersReportStartDate);
                            print("globals.ordersReportEndDate:" + globals.ordersReportEndDate);

                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => OrdersReportView()),
                                ModalRoute.withName("/orders_report"));


                          },
                          leading: Text(""),
                          trailing: Icon(Icons.arrow_forward_ios),
                          title: Text("Yesterday",
                              style: new TextStyle(fontSize: 16, )),
                        ),
                        Divider()
                    ],),

/*
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                            children: <Widget> [

                              TextFormField(

                                controller:startDateController,
                                readOnly: true,
                                validator: (val) {

                                },
                                onSaved: (val) {
                                  //startDate = _dateFormat.format(_dob).toString();
                                },
                                decoration: InputDecoration(
                                  labelText: "Start Date",
                                ),
                                onTap: (){

                                  _selectDate(context, startDate, startDateController);

                                },
                              ),
                              TextFormField(

                                controller:endDateController,
                                readOnly: true,
                                validator: (val) {

                                },
                                onSaved: (val) {
                                  //startDate = _dateFormat.format(_dob).toString();
                                },
                                decoration: InputDecoration(
                                  labelText: "End Date",
                                ),
                                onTap: (){

                                  _selectDate(context, endDate, endDateController);

                                },
                              )
                            ]
                        ),
                      ),
                    ),*/



                  ],
                ),
              ),
            )
        )
    );
  }
}
