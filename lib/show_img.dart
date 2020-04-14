import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_saver/image_saver.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageShow extends StatefulWidget {
  final List imgUrls;
  final String text;

  ImageShow({Key key, this.imgUrls, this.text}) : super(key: key);

  @override
  _ImageShowState createState() => _ImageShowState();
}

class _ImageShowState extends State<ImageShow> {
  final String baseUrl = 'https://www.ipicbook.com/fangdoc/';

  void _saveImage(BuildContext context, String url) async {
    var response = await http.get(url);
    File result = await ImageSaver.toFile(fileData: response.bodyBytes);
    final snackBar = SnackBar(content: Text(result == null ? '保存失败!' : '保存成功'));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('显示图片'),
        centerTitle: true,
      ),
      body: PageView.custom(
        childrenDelegate: SliverChildBuilderDelegate(
          (_, index) {
            if (index == 0) {
              String string = widget.text.toString();
              string = string.substring(string.indexOf(RegExp(r'JAVA.')) + 7);
              return ListView(
                padding: EdgeInsets.all(8),
                children: <Widget>[
                  SelectableText(
                    string,
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              );
            }
            return Stack(
              children: <Widget>[
                Center(
                  child: Stack(
                    children: <Widget>[
                      Center(child: CircularProgressIndicator()),
                      Center(
                        child: FadeInImage.memoryNetwork(
                          placeholder: kTransparentImage,
                          image: baseUrl + widget.imgUrls[index - 1],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 24,
                  bottom: 24,
                  child: FloatingActionButton(
                    child: Icon(Icons.file_download),
                    onPressed: () => _saveImage(
                        context, baseUrl + widget.imgUrls[index - 1]),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 24,
                  child: Text('如果图片不显示，请稍后再试\n图片下载成功，会有提示“保存成功”'),
                ),
              ],
            );
          },
          childCount: widget.imgUrls.length + 1,
        ),
      ),
    );
  }
}
