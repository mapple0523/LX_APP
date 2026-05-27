
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/pages/common/shprItem.dart';
import 'package:dtwms_app/pages/mdm/MDM0001M.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:dtwms_app/utils/convertUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


Future<List<dynamic>> menuInfo(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> menuList = await transaction(context, "common/getMobileMenuInfo.do", param);
  if(menuList == null || menuList.length == 0) {
    showInfoAlert(context, "등록 된 메뉴가 없습니다.");
  }
  return menuList;
}


Future<List<dynamic>> comProdList(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> rtnList = await transaction(context, "common/prodList.do", param);
  return rtnList;
}

Future<List<dynamic>> shprItemInfo(BuildContext context, Map<String, dynamic> param) async {

  List<dynamic> menuList = await transaction(context, "stk0001/searchShprItem.do", param);

  return menuList;
}

Future<List<dynamic>> shprInfo(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> menuList = await transaction(context, "common/shpr.do", param);
  return menuList;
}

Future<List<dynamic>> shprItemGroupInfo(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> rtnList = await transaction(context, "common/shprItemGroup.do", param);
  return rtnList;
}

Future<List<dynamic>> shprItemComboList(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> rtnList = await transaction(context, "common/shprItemComboList.do", param);
  return rtnList;
}

Future<List<dynamic>> comCodeInfo(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> rtnList = await transaction(context, "common/comCode.do", param);
  return rtnList;
}

Future<List<dynamic>> comBizInfo(BuildContext context) async {
  List<dynamic> rtnList = await transaction(context, "common/comBiz.do", {});
  return rtnList;
}

Future<List<dynamic>> comboLocationList(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> rtnList = await transaction(context, "common/getComboLocInfo.do", param);
  return rtnList;
}

Future<dynamic> locationDetailInfo(BuildContext context, Map<String, dynamic> param) async {
  dynamic rtnData = await transaction(context, "common/getLocationDetail.do", param);
  return rtnData;
}

Future<bool> checkEmptyItemBarcode(BuildContext context, Map<String, dynamic> param) async {
  bool rtnVal = false;
  List<dynamic> resultVal = await transaction(context, "common/checkItemBarcode.do", param);

  if(!CommonUtil.isEmpty(resultVal)) {
    rtnVal = true;
  } else {
    rtnVal = false;
  }
  return rtnVal;
}

Future<dynamic> checkItemBarcode(BuildContext context, Map<String, dynamic> param) async {
  List<dynamic> resultVal = await transaction(context, "common/checkItemBarcode.do", param);
  dynamic rtnMap = {};
  if(CommonUtil.isEmpty(resultVal)) {

    await confirmDialog(context, "품목 바코드", "유효하지 않는(은) 바코드 입니다. 바코드 등록 화면으로 이동 하시겠습니까?").then((value) async {
      if(value == true) {
        final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => MDM0001M(param : param)));
        if(!CommonUtil.isEmpty(result) && result is Map) {
          rtnMap = result;
          //await showInfoAlertSync(context, "등록 되었습니다.");
        }
      }
    });
  } else {
    if(resultVal.length > 1) {
      rtnMap = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => ShprItem(param: ConvertUtil.copyObject(param))));
    } else {
      rtnMap = resultVal[0];
    }
  }

  return rtnMap;
}