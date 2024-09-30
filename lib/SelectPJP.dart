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
  @override
  _AreaSelectionScreenState createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> PJP = [];
  //bool isLoading = true; // Flag to check if PJP is still loading

  @override
  void initState() {
    super.initState();
    _loadPJPs(); // Load PJP data on initialization
  }

  // Method to load PJP data asynchronously
  void _loadPJPs() async {
    Repository repo = Repository();
    List<Map<String, dynamic>> fetchedPJP = await repo.getPJPs();

    setState(() {
      PJP = fetchedPJP;
      print("PJP " + PJP.toString());
    //  isLoading = false; // Set the flag to false when data is loaded
    });
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
          /*    isLoading
                  ? Center(
                      child:
                          CircularProgressIndicator()) // Show loading indicator while fetching PJP
                  :*/
              DropdownButtonFormField<String>(
                value: PJP.any((pjp) => pjp['PJPID'].toString() == globals.selectedPJP) ? globals.selectedPJP : null,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'PJP',
                ),
                items: PJP.map((pjp) {
                  return DropdownMenuItem<String>(
                    value: pjp['PJPID'].toString() ?? "",
                    child: Text('${pjp['PJPID']} - ${pjp['PJPName']}'),
                  );
                }).toList(),
                onChanged: (String newValue) {
                  setState(() {
                    globals.selectedPJP = newValue;
                    print("Selected PJP: " + globals.selectedPJP.toString());
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'No PJP assigned';
                  }
                  return null;
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
                        if (_formKey.currentState.validate()) {
           /*               showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );*/

                        //  await SaveCashSaleOrder();

                         // Navigator.of(context).pop();
                          Repository repo = Repository();
                          await   repo.updateisseleted();
                          await repo.UpdatePJPselection(globals.selectedPJP);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Home()),
                          );

                          print('Proceed button pressed');
                        }
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Proceed'),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
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
