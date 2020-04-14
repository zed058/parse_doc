import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
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

  void _saveImage(String url) async {
    var response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));
    final result =
        await ImageGallerySaver.saveImage(Uint8List.fromList(response.data));
    print('result:$result');
    if (result == null) {
      Fluttertoast.showToast(msg: '保存失败');
    } else {
      Fluttertoast.showToast(msg: '保存成功');
    }
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
                    onPressed: () =>
                        _saveImage(baseUrl + widget.imgUrls[index - 1]),
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
