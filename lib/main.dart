import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hex/hex.dart';
// import 'package:flutter_file_manager/flutter_file_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission/permission.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'License Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("License Generator"),
        ),
        body: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final textController = TextEditingController();
  String last_saved_file;

  Future<String> get _storagePath async {
    try {
      // final dir = await getApplicationDocumentsDirectory();
      final dir = await getExternalStorageDirectory();

      return dir.path;
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<File> get _fileReference async {
    try {
      final dir = await _storagePath;

      final macaddr = textController.text;

      print(dir);

      return File('$dir/License.dat');
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<File> generateAndSaveLicense() async {
    try {
      final file = await _fileReference;
      final macaddr = textController.text;

      final bytesArr = HEX.decode(macaddr);

      final digest1 = sha1.convert(bytesArr);
      print("Digest 1 SHA1 : " + digest1.toString());
      final digest2 = sha1.convert(digest1.bytes);
      print("Digest 2 SHA1 : " + digest2.toString());
      final result = digest2.bytes;
      print("writing");
      await file.writeAsBytes(result);
      print("done");
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text('data saved to ${file.path}'),
        ),
      );
      return file;
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<String> readFile() async {
    try {
      final file = await _fileReference;

      print("reading");
      final es = await file.readAsBytes();

      setState(() {
        last_saved_file = HEX.encode(es);
      });

      print("finished");
      return "done";
    } catch (e) {
      print(e.toString());
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  _checkPermission() async {
    var permissionStatus =
        await Permission.getPermissionsStatus([PermissionName.Storage]);
    permissionStatus.forEach((permisi) {
      print(permisi.permissionName.toString() +
          " - " +
          permisi.permissionStatus.toString());
    });
    var askPermit = await Permission.requestSinglePermission(
        permissionStatus[0].permissionName);
    print(askPermit.toString());
  }

  @override
  void initState() {
    super.initState();
    readFile();

    _checkPermission();
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("==REBUILD===");
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Mac Address",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              color: Theme.of(context).primaryColor,
              onPressed: () {
                generateAndSaveLicense();
              },
              child: Text(
                "Generate and Save",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
            Text('$last_saved_file'),
          ],
        ),
      ),
    );
  }
}
