/*import 'package:camera/camera.dart';*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
/*import 'package:order_booker/delivery.dart';*/
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/outlet_location.dart';
/*import 'package:order_booker/take_images.dart';*/
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import 'globals.dart' as globals;
import 'orders.dart';
import 'package:flutter_beautiful_popup/main.dart';
import 'package:animated_dialog_box/animated_dialog_box.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
// This app is a stateful, it tracks the user's current choice.
class ShopAction_test extends StatefulWidget {
  //int DispatchID;

  ShopAction_test(){

  }
  @override
  _ShopAction_test createState() => _ShopAction_test();
}

class _ShopAction_test extends State<ShopAction_test> {

  @override
  void initState() {

  }



  // bool barrierDismissible = false,
  // Widget close,
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.grey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            }),
      ),
      body: SlidingUpPanel(
        panel: Center(
          child: Text("This is the sliding Widget"),
        ),
        body: Center(
          child: Text("This is the Widget behind the sliding panel"),
        ),
      ),
    );
  }
 /* @override
  Widget build(BuildContext context) {

    String selected;
    return  Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            color: Colors.grey,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            }),
      ),
      body:ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[


                  Card(
                      child:
                      Column(

                        children: [
                       Container(
                         child:   MaterialButton(
                           shape: RoundedRectangleBorder(
                             borderRadius: BorderRadius.circular(40),
                           ),
                           color: Colors.white,
                           child: Text('Rotated Dailog'),
                           onPressed: () async {
                             await animated_dialog_box.showScaleAlertBox(
                                 title: Center(child: Text("Hello")), // IF YOU WANT TO ADD
                                 context: context,
                                 firstButton: MaterialButton(
                                   // FIRST BUTTON IS REQUIRED
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(40),
                                   ),
                                   color: Colors.white,
                                   child: Text('Ok'),
                                   onPressed: () {
                                     Navigator.of(context).pop();
                                   },
                                 ),
                                 secondButton: MaterialButton(
                                   // OPTIONAL BUTTON
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(40),
                                   ),
                                   color: Colors.white,
                                   child: Text('Cancel'),
                                   onPressed: () {
                                     Navigator.of(context).pop();
                                   },
                                 ),
                                 icon: Icon(Icons.info_outline,color: Colors.red,), // IF YOU WANT TO ADD ICON
                                 yourWidget: Container(
                                   child: Text('This is my first package'),
                                 )
                             );
                           },
                         ),
                       )
                        ],

                      )
                  ),



                ],
              ),
            ),
          ]));


      *//*SingleChildScrollView(

        child: Container(
          color: Colors.white,
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize :MainAxisSize.min,

            children: [
              Flexible(
                flex: 1,
                child: _myRadioOptionsView(context),

              ),
              *//**//*Flexible(

                child: Image.asset("assets/images/radio_click.png",width: 300,),
              ),*//**//*

            ],
          ),
        )
      ),*//*




  }*/


  int _value = 1;
  Widget _myRadioOptionsView(BuildContext context) {

    final titles = ['Order', 'No Order','Mark Closed','Merchandising','Update Profile'];
    final values = [1, 2,3,4,5];
    final imagess = ['assets/images/mobile-shopping.png','assets/images/no_order.png','assets/images/alert.png','assets/images/merchandising.png','assets/images/settings.png'];

   // final icons = ['','This is a reason multi line'];



    return ListView.builder(

      shrinkWrap:true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
            color: Colors.white,
            //,
            child:

            Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [

              Container(
                color: Colors.white,

                //,
                child:  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                   color: Colors.white,
                    //shadowColor: Colors.white,

                    child: Padding(
                      padding:  EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(5.0),
                          child:  ListTile(

                            title: Text(
                              titles[index],style: TextStyle(color: Colors.black54),
                            ),

                            trailing: Image.asset(imagess[index],width: 40,),
                          ),
                      ),
                    )
                ),
              )
            ],

          ));
      },
    );
  }

}

List<charts.Series<GaugeSegment, String>> _createSampleData(data) {
  return [
    new charts.Series<GaugeSegment, String>(
      id: 'Segments',
      domainFn: (GaugeSegment segment, _) => segment.segment,
      measureFn: (GaugeSegment segment, _) => segment.size,
      data: data,
    )
  ];
}


