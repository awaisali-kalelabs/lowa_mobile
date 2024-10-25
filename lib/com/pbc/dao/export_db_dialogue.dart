import 'dart:io';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:order_booker/globals.dart' as globals;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
class ExportDbDialogue extends StatefulWidget {
  @override
  State<ExportDbDialogue> createState() => _ExportDbDialogueState();
}

class _ExportDbDialogueState extends State<ExportDbDialogue> {
  // GenericController controller = GenericController();
bool userUploadingDbFile = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0)),
      child: SizedBox(
        height: MediaQuery.of(context).size.height*.27,
        child:userUploadingDbFile?loaderBody():body(context),
      ),
    );
  }

  body(BuildContext context){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.cancel,
                color: Colors.redAccent,
              ),
            )),

        // Lottie.asset(AppImages.infoAnimation, height: 10.h),

        //const Spacer(),
        Center(
          child: Text(
            'Export DB',
            // style: AppStyles.textStyleMont(
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //     fontSize: 12.sp),
          ),
        ),
        // Obx(() => dashboardController.userUploadingDbFile.value?CustomLoader():),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Are you sure you want to top export db? ',
            textAlign: TextAlign.center,
          ),
        ),

        //  const Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  child: new Text("Yes"),
                  onPressed: () {
                    uploadDbFile(context);
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    height: 5.5,
                    //   width: 60.w,
                   /* decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18.0),
                        color: Colors.transparent,
                        border: Border.all(color: Color.fromARGB(2, 2, 2, 2))),*/
                    alignment: Alignment.center,
                    child: Text(
                      'No',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // CustomButton(text: 'Okay',onPress: (){
        //   Navigator.pop(context);
        // },),
        const Spacer(),
      ],
    );
  }

  loaderBody(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
        alignment: Alignment.topRight,
          child: IconButton(onPressed: (){
            userUploadingDbFile=false;
          }, icon: Icon(Icons.cancel)),
        ),
      Text('Uploading database file. Please wait...',textAlign: TextAlign.center,),
        SizedBox(height: 5,),
/*
        CustomLoader()
*/
      ],
    );
  }

uploadDbFile(BuildContext context) async {
    // var isInternetConnectionLive = await globals.checkInternet();
    var isInternetConnectionLive =true;
    if(isInternetConnectionLive){
      setState(() {
        userUploadingDbFile=true;
      });
    //  print('111');
      try {
        // String userId = await db.getUserData(globals.UserID);
        var dir = await getDatabasesPath();
        var path = join(dir, "delivery_managerV92.db");
        var imageFile = File(path);

         Reference reference = FirebaseStorage.instance.ref().child("db_export/").child(globals.UserID.toString()).child(imageFile.path);
       var uploadTask = await reference.putFile(imageFile);
      setState(() {
        userUploadingDbFile=false;
      });
       Navigator.pop(context);
        Navigator.pop(context);
     Fluttertoast.showToast(msg:' File uploaded successfully');    }
      catch (e) {      Fluttertoast.showToast(msg: e.toString());
       setState(() {
         userUploadingDbFile=false;
       });   }  }
    else{    Fluttertoast.showToast(msg: 'Weak Interner');    userUploadingDbFile=false;  }}
}
