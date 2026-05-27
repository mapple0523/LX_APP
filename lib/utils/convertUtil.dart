

import 'commonUtil.dart';
import "dart:convert" as convert;

class ConvertUtil {
  static bool convertBoolean(String s) {
    if(CommonUtil.isNull(s)) {
      return false;
    } else {
      return s.toLowerCase() == 'true';
    }
  }

  static dynamic copyObject(dynamic obj) {
    return convert.jsonDecode(convert.jsonEncode(obj));
  }

  static List<dynamic> cloneList(List<dynamic> list, [List<dynamic> ignoreList]) {
    List<dynamic> rtnList = [];

    for(int i=0; i<list.length; i++) {
      Map<String, dynamic> data     = list[i];
      Map<String, dynamic> addData  = {};
      if(!CommonUtil.isEmpty(ignoreList)) {
        ignoreList.map((e) {
          Iterable<String> keys = data.keys;
          keys.map((key) {
            if(key != e) {
              addData[key] = data[key];
              rtnList.add(addData);
            }
          }).toString();
        }).toString();
      } else {
        Iterable<String> keys = data.keys;
        keys.map((key) {
          addData[key] = data[key];
          rtnList.add(addData);
        }).toString();
      }
    }
    return rtnList;
  }

  static List<dynamic> removeColumn(List<dynamic> list, [List<dynamic> ignoreList]) {
    List<dynamic> rtnList = [];

    for (int i = 0; i < list.length; i++) {
      Map<String, dynamic> data = list[i];
      Map<String, dynamic> addData = {};

      if (!CommonUtil.isEmpty(ignoreList)) {
        Iterable<String> keys = data.keys;

        for (String key in keys) {
          if (!ignoreList.contains(key)) {
            addData[key] = data[key];
          }
        }
      } else {
        addData = Map.from(data);
      }

      rtnList.add(addData);
    }
    return rtnList;
  }

  static dynamic removeColumnOne(dynamic pRow, [List<dynamic> ignoreList]) {
    dynamic rtnData = {};

    Map<String, dynamic> data = pRow;
    Map<String, dynamic> addData = {};

    if (!CommonUtil.isEmpty(ignoreList)) {
      Iterable<String> keys = data.keys;

      for (String key in keys) {
        if (!ignoreList.contains(key)) {
          addData[key] = data[key];
        }
      }
    } else {
      addData = Map.from(data);
    }

    rtnData = addData;

    return rtnData;
  }
}
