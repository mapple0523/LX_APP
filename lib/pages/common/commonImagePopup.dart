import 'dart:convert';
import 'dart:io';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';
import 'package:http_parser/http_parser.dart';

class ImagePopup extends StatefulWidget {
  // 호출하는 화면에서 사진이미지 불러올수 있는 key 받아야 함
  const ImagePopup({Key key, this.param}) : super(key: key);
  final dynamic param;

  @override
  _ImagePopup createState() => _ImagePopup();
}

class _ImagePopup extends State<ImagePopup> {

  String _url = "";

  @override
  void initState() {
    print("initState ${widget.param}");
    _url = widget.param["URL"];

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    var color = 0xff453658;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: pageAppBar(context, "inspectionCheck"),
      body: FooterLayout(
        footer: Row(
          children: [

          ],
        ),
        child: Container(
          child: GestureDetector(
              onTap: () {
                CommonUtil.hideKeyboard();
              },
              child: Container(
                alignment: Alignment.center,
                child: Image.network(
                  _url,
                  fit: BoxFit.fill,
                  errorBuilder: (_, __, ___) => Icon(Icons.hide_image),
                ),
              )
          ),
        ),
      ),
    );
  }

}
