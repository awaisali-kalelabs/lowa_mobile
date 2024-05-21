// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_downloader/flutter_downloader.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await FlutterDownloader.initialize();
//   runApp(DailyReports());
// }
//
// class DailyReports extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Daily Report PDF Downloader',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   String _taskId;
//
//   Future<void> _downloadFile() async {
//     final Directory directory = await getExternalStorageDirectory();
//     final String path = directory.path;
//     final String url = 'YOUR_BACKEND_ENDPOINT_HERE'; // Replace with your backend endpoint
//
//     final response = await http.get(Uri.parse(url));
//
//     final File file = File('$path/report.xlsx');
//     await file.writeAsBytes(response.bodyBytes);
//
//     setState(() {
//       _taskId = null;
//     });
//
//     await _convertToPdf(file);
//   }
//
//   Future<void> _convertToPdf(File excelFile) async {
//     final pdf = pw.Document();
//
//     // Add PDF content here, you can customize according to your needs
//     pdf.addPage(
//       pw.Page(
//         build: (context) {
//           return pw.Center(
//             child: pw.Text('Daily Report'),
//           );
//         },
//       ),
//     );
//
//     final Directory directory = await getExternalStorageDirectory();
//     final String path = directory.path;
//
//     final pdfFile = File('$path/report.pdf');
//     await pdfFile.writeAsBytes(await pdf.save());
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('PDF Generated Successfully'),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Daily Report PDF Downloader'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             if (_taskId != null) CircularProgressIndicator(),
//             ElevatedButton(
//               onPressed: _downloadFile,
//               child: Text('Download Report as PDF'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';


class DailyReports extends StatelessWidget {
  final String pdfUrl;
  DailyReports({@required this.pdfUrl});

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
     appBar:AppBar(
       title: Text("pdf view"),
       backgroundColor: Colors.blue,
     ),
         // body:SfPdfViewer.network(pdfUrl,
         // canShowPaginationDialog: true,
         // pageSpacing: 2.0,),
    );
  }
}
