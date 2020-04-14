import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parse_doc/AnimatedWaveProgress.dart';

import 'show_img.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle =
        SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '图文提取',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '图文提取'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String baseUrl = 'https://www.ipicbook.com/fangdoc/';
  List imgUrls = [];
  String text = '';
  int uploadValue = 0;

  @override
  void dispose() {
    super.dispose();
  }

  void _showImages(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ImageShow(imgUrls: imgUrls, text: text)));
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width / 2;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              if (imgUrls.length > 0 && text != '')
                _showImages(context);
              else
                return null;
            },
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          child: Container(
            width: _width,
            height: _width,
            child: AnimatedWaveProgress(
              value: uploadValue,
              waveColor: Colors.lightBlue,
              lightWaveColor: Colors.lightBlue[200],
              circleProgressColor: Colors.blue,
              circleProgressBGColor: Colors.blue[200],
              progressAnimatedDuration: Duration(milliseconds: 2000),
              progressTextFontSize: 36,
              hintText: Text(
                '点击上传文件',
                style: TextStyle(fontSize: 20, color: Colors.deepOrange),
              ),
            ),
          ),
          onTap: () async {
            File file = await FilePicker.getFile(
                type: FileType.custom, allowedExtensions: ['doc', 'docx']);
            if (file == null) return;
            var name = file.path
                .substring(file.path.lastIndexOf("/") + 1, file.path.length);
            var postData = FormData.fromMap({
              "file": await MultipartFile.fromFile(file.path, filename: name)
            });
            var response = await Dio().post(
              '${baseUrl}loadDoc',
              data: postData,
              onSendProgress: (int sent, int total) {
                setState(() {
                  uploadValue = (sent / total * 100).floor();
                });
              },
            );
            var data = jsonDecode(response.data.toString());
            if (data['code'] == 10000) {
              imgUrls = data['data']['imgUrls'];
              text = data['data']['text'];
              if (imgUrls != null && imgUrls.length > 0 && text != '') {
                _showImages(context);
              }
            } else {
              setState(() {
                uploadValue = 0;
              });
              Fluttertoast.showToast(
                msg: data['msg'],
                toastLength: Toast.LENGTH_LONG,
              );
            }
          },
        ),
      ),
    );
  }
}
