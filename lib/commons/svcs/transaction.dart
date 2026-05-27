import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/constants/pageConstant.dart';
import 'package:dtwms_app/pages/common/message.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import "package:flutter/material.dart";
import "dart:convert" as convert;
import "package:http/http.dart" as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


Future<dynamic> transaction(BuildContext context, String url, dynamic paramMap, [dynamic callbackFn]) async {
  print("transaction Start");
  showLoadingAlert(context);

  final _storage = FlutterSecureStorage();
  String authToken = "";

  if(CommonUtil.isEmpty(paramMap)) paramMap = {};

  try {
    authToken = await _storage.read(key: "AUTH_TOKEN");
  } catch(e) {}
  http.Response response;
  Map<String, dynamic> resultMap;
  dynamic rtnData;
  Map<String, dynamic> reqParam = {
    Constant.rtnData: paramMap,
    Constant.sysFlagNm : Constant.sysType,
    Constant.authTokenNm : authToken
  };

  try {
    response = await http.post(
        Uri.parse(Constant.serverUrl + Constant.serverPrefix + url)
        , headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    }
        , body: convert.json.encode(reqParam)
        , encoding: convert.Encoding.getByName("utf-8")
    ).timeout(const Duration(seconds: 120));

    hideLoadingAlert(context);

    if (response.statusCode == Constant.resSuccessCode) {
        resultMap = convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
        if(resultMap[Constant.rtnStatus] == Constant.resSuccessCode) {
          rtnData = resultMap[Constant.rtnData];
        } else if(resultMap[Constant.rtnStatus] == Constant.resErrorCode) {
          showInfoAlert(context, resultMap[Constant.rtnMssage]);
          rtnData = resultMap[Constant.rtnData];
        }

        if(!CommonUtil.isEmpty(callbackFn)) {
          callbackFn(resultMap[Constant.rtnStatus], rtnData);
        }
    } else if(response.statusCode == Constant.tokenFailCode) {
      String serverMsg = convert.utf8.decode(response.bodyBytes);

      showInfoAlertSync(context, serverMsg.isNotEmpty ? serverMsg :"This token is not valid").then((value) {
        if(value) {
          callLogout(context);
        }
      });
    } else {
      showInfoAlert(context, 'Request failed with status: ${response.statusCode}.');
      if(!CommonUtil.isEmpty(callbackFn)) {
        callbackFn(Constant.resErrorCode, null);
      }
    }
  } catch (e) {
    hideLoadingAlert(context);
    print("transaction Error => " + e.toString());
    showErrorAlert(context, e.toString());
    resultMap = null;
  } finally {
    //hideLoadingAlert(context);
    print("transaction End");
  }
  return rtnData;
}

Future<dynamic> imageTransaction(BuildContext context, String url, dynamic paramMap, [dynamic callbackFn]) async {
  print("imageTransaction Start");
  showLoadingAlert(context);

  final _storage = FlutterSecureStorage();
  String authToken = "";

  if(CommonUtil.isEmpty(paramMap)) paramMap = {};

  try {
    authToken = await _storage.read(key: "AUTH_TOKEN");
  } catch(e) {}
  http.Response response;
  Map<String, dynamic> resultMap;
  dynamic rtnData;



  Map<String, dynamic> reqParam = {
    Constant.sysFlagNm : Constant.sysType,
    Constant.authTokenNm : authToken
  };

  paramMap.forEach((key, value) {
    reqParam[key] = value;
  });

  try {
    response = await http.post(
        Uri.parse(Constant.serverUrl + Constant.serverPrefix + url)
        , headers: {
      "Accept": "application/json",
      "Content-Type": "application/json"
    }
        , body: convert.json.encode(reqParam)
        , encoding: convert.Encoding.getByName("utf-8")
    ).timeout(const Duration(seconds: 120));

    hideLoadingAlert(context);

    if (response.statusCode == Constant.resSuccessCode) {
      resultMap = convert.jsonDecode(convert.utf8.decode(response.bodyBytes));
      if(resultMap[Constant.rtnStatus] == Constant.resSuccessCode) {
        rtnData = resultMap[Constant.rtnData];
      } else if(resultMap[Constant.rtnStatus] == Constant.resErrorCode) {
        showInfoAlert(context, resultMap[Constant.rtnMssage]);
        rtnData = resultMap[Constant.rtnData];
      }

      if(!CommonUtil.isEmpty(callbackFn)) {
        callbackFn(resultMap[Constant.rtnStatus], rtnData);
      }
    } else if(response.statusCode == Constant.tokenFailCode) {
      showInfoAlertSync(context, "This token is not valid").then((value) {
        if(value) {
          callLogout(context);
        }
      });
    } else {
      showInfoAlert(context, 'Request failed with status: ${response.statusCode}.');
      if(!CommonUtil.isEmpty(callbackFn)) {
        callbackFn(Constant.resErrorCode, null);
      }
    }
  } catch (e) {
    hideLoadingAlert(context);
    print("transaction Error => " + e.toString());
    showErrorAlert(context, e.toString());
    resultMap = null;
  } finally {
    //hideLoadingAlert(context);
    print("transaction End");
  }
  return rtnData;
}


// ignore: missing_return
Future<Map<String, dynamic>> callLogout(BuildContext context) async {
    final _storage = FlutterSecureStorage();
    _storage.delete(key: Constant.sotrageAutoFlagKey);
    _storage.delete(key: Constant.sotrageTokenKey);
    Navigator.pushNamedAndRemoveUntil(context, PageConstant.routeNameSplash, (route) => false);
}

void pageMove(BuildContext context, String pageUrl) {
  if(CommonUtil.isNull(pageUrl)) {
    showInfoAlert(context, "pageNotFound");
  } else {
     Navigator.pushNamed(context, pageUrl);
  }
}