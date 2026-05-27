// create a listener for data wedge package
import 'dart:async';
import 'dart:convert';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter_zebra_datawedge/flutter_zebra_datawedge.dart';

class ZebraDataWedgeListener
{
  static List<dynamic> scanType;
  static Map<String, dynamic> rtnFnMap = {};

  StreamSubscription<dynamic> initDataWedgeListener() {
    return FlutterZebraDataWedge.listenForDataWedgeEvent((response) {
      dynamic callback;
      if (response != null && response is String) {
        Map<String, dynamic> jsonResponse;
        try {
          jsonResponse = json.decode(response);
        } catch (e) {
          print("Barcode Scan Fail : $e");
        }

        if (jsonResponse != null) {
          //바코드 입력값 확인.
          String result = jsonResponse["decodedData"];
          print("Barcode Result Value : $result");
          print("rtnFnMap ${rtnFnMap}");

          List<dynamic> findKeyList = CommonUtil.getBarcodeScanType(scanType, result);
          print("Barcode Function Key : $findKeyList");

          if(CommonUtil.isEmpty(findKeyList) || findKeyList.length == 0) {
            // scanType에 CM이있으면 CM으로 던지기
            print("scanType: $scanType");

            if(scanType != null && scanType.any((item) => item['CODE'] == 'CM')) {
              callback = rtnFnMap["CM"];
            } else {
              callback = rtnFnMap["E"];
            }
            try {
              callback(result.trim());
            } catch(e) {
              print("Barcode Callback Function Fail : $e");
            }
          }
          else {
            for(int i=0; i<findKeyList.length; i++) {
              callback = rtnFnMap[findKeyList[i]];
              try {
                // callback이 없는 경우 CM콜백으로 호출
                if(callback == null) {
                  callback = rtnFnMap["CM"];
                }

                callback(result.trim());
                break;
              } catch(e) {
                print("Barcode Callback Function Fail : $e");
              }
            }
          }
        } else {
          print("Barcode Result Value Is Null");
        }
      }
    });
  }

  static initFunc() {
    Iterable<String> keyList = rtnFnMap.keys;
    keyList.forEach((element) {
      if(element != "E" && element != "CM") rtnFnMap[element] = null;
    });
    //rtnFnMap = {};
  }
}




