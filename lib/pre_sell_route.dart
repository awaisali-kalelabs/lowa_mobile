/*import 'package:camera/camera.dart';*/
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:order_booker/OutletOrderImage.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
/*import 'package:order_booker/delivery.dart';*/
import 'package:order_booker/gauge_segment.dart';
import 'package:order_booker/outlet_location.dart';
import 'package:order_booker/shopAction.dart';
/*import 'package:order_booker/take_images.dart';*/
import 'package:url_launcher/url_launcher.dart';

import 'globals.dart' as globals;
import 'globals.dart';
import 'home.dart';

// This app is a stateful, it tracks the user's current choice.
class PreSellRoute extends StatefulWidget {
  int DispatchID;

  PreSellRoute(DispatchID) {
    this.DispatchID = DispatchID;

    print(DispatchID);
  }
  @override
  _PreSellRoute createState() => _PreSellRoute(DispatchID);
}

class _PreSellRoute extends State<PreSellRoute> {
  int DispatchID;

  String selected;
  int weekday;
  int today;
  int isVisible;

  final searchController = TextEditingController();
  String _SelectFerightTerms;
  _PreSellRoute(DispatchID) {
    this.DispatchID = DispatchID;
  }
  Repository repo = new Repository();
  List Days = new List();

  List<bool> isSelected = [false, false, false, false, false, false, false];

  List<Map<String, dynamic>> PreSellOutlets;
  int navigate = 0;

  String radioButtonItem = 'ONE';

  // Group Value for Radio Button.
  //int globals.isAlternative = 1;

  @override
  void initState() {
    super.initState();
    print("Inside Init of PresellRoute");
    print("Visit PJP :"+globals.selectedPJP.toString());
    BackButtonInterceptor.add(myInterceptor);
    globals.stopContinuousLocation();
    if (DispatchID == 0) {
      DispatchID = globals.DispatchID;
    }
    //PreSellOutlets=new List();

    Repository repo = new Repository();
    //weeK DAY to be Placed
    weekday = globals.WeekDay;
    isVisible = 1;
    today = globals.getPBCDayNumber(DateTime.now().weekday);

    PreSellOutlets = new List();

    repo.getPreSellOutletsByIsVisible(weekday, "%%", globals.isAlternative,globals.selectedPJP).then((val) {
      setState(() {
        PreSellOutlets = val;
        _SelectFerightTerms = weekday.toString();
      });
    });

    print("WEEK DAY IS" + weekday.toString());
    if (weekday > 0) {
      isSelected[weekday - 1] = true;
    } else {
      isSelected[0] = true;
    }
    if(navigate==1){

    }
  }
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    print("not navigating PRESELL"); // Do some stuff.
    //work here
    return true;

  }

  double cardWidth = 0.0;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    cardWidth = width / 1.1;


    return WillPopScope(
        onWillPop: () async => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            ),
        child: MaterialApp(
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.blue[800],
                leading: IconButton(
                    icon: Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Home()),
                      );
                    }),
                actions: [ Row(
                  mainAxisAlignment: MainAxisAlignment.start,

                  children: <Widget>[
                    Radio(
                      value: 1,
                      groupValue: globals.isAlternative,
                      activeColor: Colors.white,

                      onChanged: (val) {
                        setState(() {

                          globals.isAlternative = 1;
                        });
                        repo
                            .getPreSellOutletsByIsVisible(weekday, searchController.text, globals.isAlternative,globals.selectedPJP)
                            .then((value) {
                          setState(() {
                            PreSellOutlets = value;
                            print(PreSellOutlets);
                          });
                        });
                      },
                    ),
                    GestureDetector(onTap: () {
                      setState(() {

                        globals.isAlternative = 1;
                      });
                      repo
                          .getPreSellOutletsByIsVisible(weekday, searchController.text, globals.isAlternative,globals.selectedPJP)
                          .then((value) {
                        setState(() {
                          PreSellOutlets = value;
                          print(PreSellOutlets);
                        });
                      });
                    }, child: Text(
                      'This Week',
                      style: new TextStyle(fontSize: 14),
                    ),),
                    Container(width: 5,),

                    Radio(

                      value: 0,
                      groupValue: globals.isAlternative,
                      activeColor: Colors.white,
                      onChanged: (val) {
                        setState(() {

                          globals.isAlternative = 0;
                        });
                        repo
                            .getPreSellOutletsByIsVisible(weekday, searchController.text, globals.isAlternative,globals.selectedPJP)
                            .then((value) {
                          setState(() {
                            PreSellOutlets = value;
                            print(PreSellOutlets);
                          });
                        });
                      },
                    ),
                    GestureDetector(onTap: () {
                      setState(() {

                        globals.isAlternative = 0;
                      });
                      repo
                          .getPreSellOutletsByIsVisible(weekday, searchController.text, globals.isAlternative,globals.selectedPJP)
                          .then((value) {
                        setState(() {
                          PreSellOutlets = value;
                          print(PreSellOutlets);
                        });
                      });
                    }, child: Text(
                      'Last Week',
                      style: new TextStyle(fontSize: 14),
                    ),),
                    Container(width: 5,)
                  ],
                ),],
              ),
              body: ListView(
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Container(
                            color: Colors.black26,
                            child: ToggleButtons(
                              children: <Widget>[
                                Text("Su"),
                                Text("M"),
                                Text("T"),
                                Text("W"),
                                Text("Th"),
                                Text("F"),
                                Text("S"),
                              ],
                              color: Colors.white,
                              selectedColor: Colors.white,
                              fillColor: Colors.blue,
                              focusColor: Colors.green,
                              splashColor: Colors.lightBlueAccent,
                              highlightColor: Colors.grey,
                              borderColor: Colors.white,
                              borderWidth: 2,
                              selectedBorderColor: Colors.white,
                              onPressed: (int index) {
                                setState(() {
                                  print("Text button");
                                  for (int i = 0; i < 7; i++) {
                                    if (i == index) {
                                      isSelected[i] = true;
                                    } else {
                                      isSelected[i] = false;
                                    }
                                  }
                                  weekday = index + 1;
                                  globals.WeekDay = weekday;
                                  print(weekday.toString() + ":" + today.toString() );
                                  if(weekday!=today){
                                    setState(() {
                                      isVisible=-1;
                                    });
                                  }else{
                                    setState(() {
                                      isVisible=1;
                                    });
                                  }
                                  print(weekday);
                                  repo
                                      .getPreSellOutletsByIsVisible(weekday, searchController.text, globals.isAlternative, globals.selectedPJP)
                                      .then((value) {
                                    setState(() {
                                      PreSellOutlets = value;
                                      print(PreSellOutlets);
                                    });
                                  });

                                  print("isSelected" + isSelected.toString());
                                  print(isSelected[index]);
                                });
                              },
                              isSelected: isSelected,
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                // width: cardWidth,
                                padding: EdgeInsets.all(5.0),
                                child: TextField(
                                  controller: searchController,

                                    autofocus: false,

                                    onChanged: (val) {
                                      if(val.isEmpty){
                                        setState(() {
                                          isVisible=1;
                                        });
                                      }else{
                                        setState(() {
                                          isVisible=-1;
                                        });
                                      }
                                      repo
                                          .getPreSellOutletsByIsVisible(weekday, val, globals.isAlternative,globals.selectedPJP)
                                          .then((val) {
                                        setState(() {

                                          PreSellOutlets = val;
                                        });
                                      });
                                    },
                                    decoration: InputDecoration(
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black12, width: 0.0),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.search_sharp,
                                      ),
                                      labelText: 'Search',
                                    )),
                              ),
                              Container(
                                //  width: cardWidth,
                                child: Card(
                                  child: Container(
                                      child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Flexible(
                                          child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: ClampingScrollPhysics(),
                                        itemCount: PreSellOutlets != null
                                            ? PreSellOutlets.length
                                            : 0,
                                          itemBuilder: (context, index) {
                                          var color = Colors.white;
                                          if (PreSellOutlets[index]['visit_type'] == 1) {
                                            color = Colors.green[100];
                                          } else if (PreSellOutlets[index]['visit_type'] == 2) {
                                            color = Colors.blue[100];
                                          } else if (PreSellOutlets[index]['visit_type'] == 3) {
                                            color = Colors.purple[100];
                                          }
                                          return Column(
                                            children: <Widget>[
                                              index == 0 ? Container() : Divider(),
                                              Container(
                                                color: color,
                                                child: ListTile(
                                                  enabled: PreSellOutlets[index]['is_delivered'] == 1 ? false : true,
                                                  onTap: () async {
                                                    globals.OutletID = PreSellOutlets[index]['outlet_id'];
                                                    globals.OutletAddress = PreSellOutlets[index]['address'];
                                                    globals.OutletName = PreSellOutlets[index]['outlet_name'];
                                                    globals.OutletNumber = PreSellOutlets[index]['telephone'];
                                                    globals.OutletOwner = PreSellOutlets[index]['owner'];
                                                    globals.Lat = double.parse(PreSellOutlets[index]['lat']);
                                                    globals.Lng = double.parse(PreSellOutlets[index]['lng']);
                                                    globals.VisitType = int.parse(PreSellOutlets[index]['visit_type'].toString());
                                                    globals.PCI_Channel_ID = PreSellOutlets[index]['pic_channel_id'];
                                                    globals.Channel_ID = PreSellOutlets[index]['channel_id'];
                                                    globals.PCI_Channel_Lable = PreSellOutlets[index]['channel_label'].toString();
                                                    globals.order_created_on_date = PreSellOutlets[index]['order_created_on_date'];
                                                    globals.common_outlets_vpo_classifications= PreSellOutlets[index]['common_outlets_vpo_classifications'];
                                                    globals.Visit=PreSellOutlets[index]['Visit'];

                                                    await repo.deleteAllIncompleteOrder(PreSellOutlets[index]['outlet_id']);
                                                    globals.OutletIdforupdate = PreSellOutlets[index]['outlet_id'];
                                                  //  print( "Channel Id :"+globals.PCI_Channel_ID);
                                                    Navigator.push(
                                                        context,
                                                        //
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                 OutletOrderImage(outletId: globals.OutletID)));
                                                    //ShopAction()
                                                       // ));
                                                  },
                                                  trailing: Container(
                                                    width: 110,
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        IconButton(
                                                            icon: Icon(Icons.directions, color: Colors.blue),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) => OutletLocation(
                                                                      address: PreSellOutlets[index]['address']
                                                                          .toString(),
                                                                      name: PreSellOutlets[index]['outlet_name']
                                                                          .toString(),
                                                                      lat: double.parse(
                                                                          PreSellOutlets[index]['lat']),
                                                                      lng: double.parse(
                                                                          PreSellOutlets[index]['lng']),



                                                                    )),
                                                              );
                                                            }),
                                                        IconButton(
                                                            icon: Icon(Icons.phone, color: Colors.blue),
                                                            onPressed: () async {
                                                              var url = "tel:" +
                                                                  PreSellOutlets[index]['telephone'].toString();
                                                              if (await canLaunch(url)) {
                                                                await launch(url);
                                                              } else {
                                                                throw 'Could not launch $url';
                                                              }
                                                            }),
                                                      ],
                                                    ),
                                                  ),
                                                  title: Text(
                                                      PreSellOutlets[index]['outlet_id'].toString() +
                                                          " - " +
                                                          PreSellOutlets[index]['outlet_name'],
                                                      style: new TextStyle(fontSize: 16)),
                                                  subtitle: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.max,
                                                    children: <Widget>[
                                                      Text(PreSellOutlets[index]['address'],
                                                          style: new TextStyle(fontSize: 16)),
                                                      PreSellOutlets[index]['area_label'] != null
                                                          ? Text(
                                                        (PreSellOutlets[index]['area_label'] ?? "Empty") +
                                                            ", " +
                                                            (PreSellOutlets[index]['sub_area_label'] ?? "Empty"),
                                                        style: TextStyle(fontSize: 16),
                                                      )
                                                          : Container(),
                                                      /*Text('Rs. '+
                    PreSellOutlets[index]['net_amount'].toString() + "",
                    style: new TextStyle(fontSize: 16))*/
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          );
                                        },
                                      )),
                                    ],
                                  )),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ])),
        ));
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

void main() {
  runApp(PreSellRoute(1));
}
