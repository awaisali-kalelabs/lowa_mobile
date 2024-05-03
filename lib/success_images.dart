import 'dart:ui';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SuccessImages(),
    );
  }
}

class SuccessImages extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _CheckCodeState();
}

class _CheckCodeState extends State<SuccessImages> {
  final TextEditingController _smsFilter = new TextEditingController();

  String _smscode = "";
  String _text = "";

  _CheckCodeState() {
    _smsFilter.addListener(_smsListen);
  }

  void _smsListen() {
    if (_smsFilter.text.isEmpty) {
      _smscode = "";
    } else {
      _smscode = _smsFilter.text;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _buildBar(context),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xff004883),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white, // Text Color
                  padding: const EdgeInsets.all(0.0),
                ),
                onPressed: () {},
                child: Container(
                  height: 51,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xffe32934),
                        Color(0xff004883),
                      ],
                    ),
                  ),
                  padding:
                      const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                  child: const Text('ٹھیک ہے',
                      style: TextStyle(fontFamily: 'Urdu', fontSize: 24)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white, // Text Color
                  padding: const EdgeInsets.only(bottom: 0),
                ),
                onPressed: () {},
                child: Container(
                  height: 51,
                  width: 90,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xff004883),
                        Color(0xffe32934),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: const Text('OK', style: TextStyle(fontSize: 20)),
                ),
              ),
            ]),
      ),
      body: new Container(
        //padding: EdgeInsets.all(16.0),
        child: new Column(
//          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            _buildTextFields(),
            // _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Thank You"),
      backgroundColor: Colors.pinkAccent,
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      margin: const EdgeInsets.only(left: 45.0, right: 20.0, top: 0),
      child: new Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(''),
          Container(
            height: 150,
            child: Image.asset(
              "assets/images/done_icon.png",
              width: 100,
            ),
          ),
          Text(''),
          new Container(
            child: new Text("Sent",
                textAlign: TextAlign.center,
                style: new TextStyle(fontSize: 20)),
          ),
          new Container(
            margin: const EdgeInsets.only(top: 20.0),
            child: new Text("تصویریں کمپنی کو بھیج دی گئی ہیں۔ شکریہ",
                textAlign: TextAlign.center,
                style: new TextStyle(fontFamily: 'Urdu', fontSize: 25)),
          ),
        ],
      ),
    );
  }
}
