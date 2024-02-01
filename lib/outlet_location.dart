import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:order_booker/pre_sell_route.dart';
import 'package:order_booker/shopAction.dart';

import 'globals.dart' as globals;

void main() => runApp(OutletLocation());

class OutletLocation extends StatefulWidget {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int calledFrom;
  OutletLocation(
      {this.name, this.address, this.lat, this.lng, this.calledFrom});

  @override
  _OutletLocation createState() => _OutletLocation(
      name: this.name,
      lng: this.lng,
      lat: this.lat,
      address: this.address,
      calledFrom: this.calledFrom);
}

class _OutletLocation extends State<OutletLocation> {
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int calledFrom;

  _OutletLocation(
      {this.name, this.address, this.lat, this.lng, this.calledFrom});
  final Map<String, Marker> _markers = {};
  Future<void> _onMapCreated(GoogleMapController controller) async {
    setState(() {
      print("marker details");

      print(this.name);
      print("lat:" + this.lat.toString());
      print("lng:" + this.lng.toString());

      print(this.address);

      _markers.clear();
      final marker = Marker(
        markerId: MarkerId(this.name),
        position: LatLng(this.lat, this.lng),
        infoWindow: InfoWindow(
          title: this.name,
          snippet: this.address,
        ),
      );
      _markers[this.name] = marker;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              this.name,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                color: Colors.grey,
                onPressed: () {
                  if (this.calledFrom == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ShopAction()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PreSellRoute(globals.DispatchID)),
                    );
                  }
                }),
          ),
          body: GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(this.lat, this.lng),
              zoom: 15,
            ),
            markers: _markers.values.toSet(),
          ),
        ),
      );
}
