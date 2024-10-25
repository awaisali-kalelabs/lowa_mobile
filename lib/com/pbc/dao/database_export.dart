import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'export_db_dialogue.dart';

class DatabaseExport extends StatelessWidget {
  DatabaseExport({key});

  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Export Database", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue,  // Changed app bar color
        centerTitle: true,  // Align title to center
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
            stream: firebaseFirestore
                .collection('db_export')
                .doc('password')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());  // Show loader when waiting
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading data.'));
              } else {
                var password = snapshot.data["password"];
                bool canUserExportDb = snapshot.data["can_user_export_db"];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,  // Align everything to the left
                    children: [
                      SizedBox(height: 16),
                      Text(
                        'Enter password to export database:',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildPasswordField(
                          context: context,
                          controller: confirmpassword,
                          label: 'Password',
                          hint: 'Enter Password'
                      ),
                      SizedBox(height: 10),
                      _buildPasswordField(
                          context: context,
                          controller: passwordController,
                          label: 'Confirm Password',
                          hint: 'Confirm Password'
                      ),
                      SizedBox(height: 30),
                      Center(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),  // Rounded button
                            ),
                            backgroundColor: Colors.blue,  // Button color
                          ),
                          icon: Icon(Icons.cloud_upload, size: 18),  // Add an upload icon
                          label: Text(
                            "Export",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            onSubmit(
                                context: context,
                                password: password,
                                canUserExportDb: canUserExportDb);
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  // Build password input field with a uniform style
  Widget _buildPasswordField({
     BuildContext context,
     TextEditingController controller,
     String label,
     String hint,
  }) {
    return TextFormField(
      controller: controller,
    //  obscureText: true,  // Hide password text
      maxLength: 13,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),  // Rounded input field
          borderSide: BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue),
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.blue),  // Icon for password field
        filled: true,
        fillColor: Colors.grey[200],
      ),
      validator: (val) {
        if (val != null && val.isEmpty) {
          return 'Password cannot be empty';
        } else if (val != null && val.length < 13) {
          return 'Password must be at least 13 characters';
        }
        return null;
      },
    );
  }

  onSubmit({BuildContext context, String password, bool canUserExportDb}) {
    if (!canUserExportDb) {
      Fluttertoast.showToast(msg: 'User cannot upload database', backgroundColor: Colors.red);
    } else if (passwordController.text.isEmpty || confirmpassword.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill both fields', backgroundColor: Colors.orange);
    } else if (passwordController.text != confirmpassword.text) {
      Fluttertoast.showToast(msg: 'Passwords do not match', backgroundColor: Colors.orange);
    } else if (passwordController.text != password) {
      Fluttertoast.showToast(msg: 'Incorrect password', backgroundColor: Colors.red);
    } else {
      showDialog(context: context, builder: (context) => ExportDbDialogue());
    }
  }
}
