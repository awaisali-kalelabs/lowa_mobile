import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'com/pbc/model/pre_sell_outlets.dart';
import 'globals.dart' as globals;
import 'globals.dart';
import 'package:order_booker/com/pbc/dao/repository.dart';

import 'home.dart';

class AreaSelectionScreen extends StatefulWidget {
  final List<dynamic> pjpList;

  AreaSelectionScreen({Key key, @required this.pjpList}) : super(key: key);

  @override
  _AreaSelectionScreenState createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  final _formKey = GlobalKey<FormState>();

  Future<bool> SaveCashSaleOrder() async {
    Repository repo = new Repository();
    await repo.initdb();
    DateFormat dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
    String currDateTime = dateFormat.format(DateTime.now());
    bool callreturn = false;
    print("globals.DeviceID:" + globals.DeviceID);
    String param = "timestamp=" +
        currDateTime +
        "&LoginUsername=" +
        globals.UserID.toString() +
        "&PJPID=" +
        globals.selectedPJP;

    var QueryParameters = <String, String>{
      "SessionID": EncryptSessionID(param),
    };

    print("Called1111");
    print("param" + param);
    var url = Uri.http(globals.ServerURL, '/portal/mobile/MobileAuthenticateOutletV1', QueryParameters);
    print("Url........." + url.toString());
    var response = await http.get(url, headers: {
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
    });
    var responseBody = json.decode(latin1.decode(response.bodyBytes));
    print(responseBody.toString());

    if (response.statusCode == 200) {
      print("Inside Status If");
      print(responseBody.toString());
      List pre_sell_outlets_rows = responseBody['BeatPlanRows'];

      // Check if pre_sell_outlets_rows is null or empty
      if (pre_sell_outlets_rows == "" || pre_sell_outlets_rows.isEmpty) {
        // Show an error dialog
        _showErrorDialog("No Outlets assigned to this PJP");
        return callreturn;
      }

      for (var i = 0; i < pre_sell_outlets_rows.length; i++) {
        pre_sell_outlets_rows[i]['visit_type'] =
        await repo.getVisitType(pre_sell_outlets_rows[i]['OutletID']);

        // alternate week day logic starts
        int isVisible = 0;
        if (globals.isOutletAllowed(pre_sell_outlets_rows[i]['IsAlternative'])) {
          isVisible = 1;
        }
        pre_sell_outlets_rows[i]['is_alternate_visible'] = isVisible;
        // alternate week day logic ends

        await repo.insertPreSellOutlet(
            PreSellOutlets.fromJson(pre_sell_outlets_rows[i]));
      }
    } else {
      print("Inside Status Else");
    }
    return callreturn;
  }

// Function to show an error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select PJP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please select your PJP:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: globals.selectedPJP ,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PJP',
                ),
                items: (widget.pjpList ?? []).map((pjp) {
                  return DropdownMenuItem<String>(
                    value: pjp['PJPID'].toString() ?? "",
                    child: Text('${pjp['PJPID']} - ${pjp['PJPName']}'),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    globals.selectedPJP = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No PJP assigned';
                  }
                  return null; // No error
                },
                hint: Text('Select PJP'),
              ),
              SizedBox(height: 20),
              if (globals.selectedPJP != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Validate the form
                        if (_formKey.currentState.validate()) {
                          // Show the loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false, // Prevents closing the dialog by tapping outside
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(), // Loading indicator
                              );
                            },
                          );

                          // Perform the action (saving the order)
                          await SaveCashSaleOrder();

                          // Close the loading dialog
                          Navigator.of(context).pop();

                          // Navigate to the Home screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );

                          print('Proceed button pressed');
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min, // To keep the button size minimal to the content
                        children: [
                          Text('Proceed'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward), // Replace with any icon you prefer
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
