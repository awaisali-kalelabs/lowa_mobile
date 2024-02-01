import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';

class Dialogs{
  static   _showDialog(String Title, String Message, BuildContext context) {
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
  _showLoader( BuildContext context) {
    // flutter defined function

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return  AlertDialog(

          backgroundColor: Colors.transparent,

          content: LoadingIndicator(indicatorType: Indicator.ballSpinFadeLoader, color: Colors.blue,)  ,
        );
      },
    );
  }
}