import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:order_booker/add_to_cart.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';
import 'package:order_booker/com/pbc/model/outlet_orders.dart';
import 'package:order_booker/shopAction.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'com/pbc/model/pci_sub_channel.dart';
import 'globals.dart' as globals;
import 'order_cart_view.dart';
import 'outlet_registration.dart';

class ChannelTaggingList extends StatefulWidget {
  @override
  _ChannelTaggingList createState() => _ChannelTaggingList();
}

class _ChannelTaggingList extends State<ChannelTaggingList> {
  Repository repo = new Repository();
  List values = [];



  @override
  Widget build(BuildContext context) {


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
                        MaterialPageRoute(
                            builder: (context) => OutletRegisteration()),
                      );
                    })),
          ),
          body: Padding(
              padding: const EdgeInsets.all(5.0),
              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
              child: Column(children: <Widget>[
                new Expanded(
                  child: new Padding(
                      padding: new EdgeInsets.only(top: 8.0),
                      child: FutureBuilder(
                        future: _getData(),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                              return new Text('loading...');
                            default:
                              if (snapshot.hasError)
                                return new Text('Error: ${snapshot.error}');
                              else
                                return createListView(context, snapshot);
                          }
                        },
                      )),
                )
              ]))),
    );
  }

  Future<List> _getData() async {


    await repo.getPCIChannels().then((value) => {
      //  chanelTaggingOptoin = value
      for (int i = 0; i < value.length; i++)
        {
          print(value[i]['label']),
          //  values.add(value[i]['label']),
          values.add({"title": value[i]['label'],
            "id": value[i]['id']})
        }
    });
    await new Future.delayed(new Duration(seconds: 0));

    return values;
  }

  Widget createListView(BuildContext context, AsyncSnapshot snapshot) {
    List values = snapshot.data;
    return new ListView.builder(
      itemCount: values.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> currentVal = values[index];
        return new Column(
          children: <Widget>[
            new ListTile(
              onTap: () async {
                print('nfnfnfnf3');
                print("");
                //  print(valuesId[index]);
                print(currentVal['title']);

                globals.channelTag=currentVal['title'];
                globals.channelTagId = currentVal['id'];
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OutletRegisteration()

                  ),
                );
              },
              title: new Text(currentVal['title']),
            ),
            new Divider(
              height: 2.0,
            ),
          ],
        );



      },
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
