import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import "package:flutter/material.dart";

class App_Function{
  static Map<String,dynamic> LOGIN_USER_INFO = {};

  static Future<String> GetLocation(BuildContext context, String kind) async {
    Map<String, dynamic> param = {
      "LOCATION_KIND" : CommonUtil.isNull(kind)?"P":kind,
    };

    List<dynamic> rtnList = await transaction(context, "common/getCommonDefalutBin.do", param);

    return rtnList[0]["LOCATION_CD"].toString();
  }
}