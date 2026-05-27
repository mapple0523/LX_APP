import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/constants/imageConstant.dart';
import "package:flutter/material.dart";


Widget widgetCopyRight() {
  return Align(
      alignment: Alignment.bottomCenter,
      child: Text(
        Constant.copyRight,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
      ));
}


Widget widgetAppTitle() {
  return Text(
    Constant.appTitle,
    style: TextStyle(
      fontWeight: FontWeight.bold, fontSize: 17,),
  );
}

Widget widgetAppTitleAndLogo() {
  return Column(
    children: <Widget>[
      Image.asset(ImageConstant.logoImg),
      //widgetAppTitle(),
    ],
  );
}