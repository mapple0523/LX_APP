import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

enum DateFormatType { clientDateTime, clientDate, server }

class CommonUtil {
  static bool flushbarOpenFlag = false;
  static String appVersion = "";

  static bool isNull(String s) {
      if(StringUtils.isNullOrEmpty(s) || s.toLowerCase() == 'null') {
        return true;
      } else {
        return false;
      }
  }
  static bool isEmpty(dynamic o) {
    if(o == null || o == 'null') {
      return true;
    } else {
      if((o is List || o is Map) && o.length == 0) {
        return true;
      } else {
        return false;
      }
    }
  }

  static String nullStrDef(String s, [String def]) {
    if(isEmpty(def)) def = "";
    if(isNull(s)) return def;
    else return s;
  }

  static dynamic nullObjectDef(dynamic o, [dynamic def]) {
    if(o == null) {
      return def == null ? "" : def;
    } else {
      return o;
    }
  }

  static List<dynamic> emptyListDef(List<dynamic> o) {
    if(isEmpty(o)) return [];
    else return o;
  }

  static String maskDate(String dt, int type){
    if(type == 0) {
      if (dt != null && dt.trim() != "" && dt.trim().length == 14) {
        dt = dt.trim();
        dt = dt.substring(0, 4) + "-" + dt.substring(4, 6) + "-" +
            dt.substring(6, 8) + " " + dt.substring(8, 10) + ":" +
            dt.substring(10, 12) + ":" + dt.substring(12, 14);
      }
    }
    return dt;
  }

  static String numberWithComma(String value){
    int l = value.length;
    String result = '';
    if (l > 3) {
      switch (l % 3) {
        case 0:
          for (var i = 0; i < l; i++) {
            if (i % 3 == 0 && i != 0) result += ',';
            result += value[i];
          }
          break;
        case 1:
          for (var i = 0; i < l; i++) {
            if (i % 3 == 1) result += ',';
            result += value[i];
          }
          break;
        case 2:
          for (var i = 0; i < l; i++) {
            if (i % 3 == 2) result += ',';
            result += value[i];
          }
          break;
      }
    }
    return result;
  }

  static dynamic findValFromList (List<dynamic> pList, String chkKey, dynamic chkVal, String findKey){
    dynamic rtnVal = "";

    dynamic chkMap = findMapFromList(pList, chkKey, chkVal);
    if(chkMap.containsKey(findKey)) {
      return chkMap[findKey];
    }

    return rtnVal;
  }

  static dynamic findKeyFromList (List<dynamic> pList, String val){
    dynamic rtnVal = "";

    if(!isEmpty(pList) && pList.length > 0) {
      for(int i=0; i<pList.length; i++) {
        Map<String, Object> data = pList[i];
        Iterable<String> keyList = data.keys;
        keyList.forEach((element) {
          if(data[element] == val) rtnVal = element;
          return rtnVal;
        });
      }
    }

    return rtnVal;
  }

  static List<dynamic> getBarcodeScanType (List<dynamic> pList, String val){
    List<dynamic> rtnVal = [];

    if(!isEmpty(pList) && pList.length > 0 && !isNull(val)) {
      pList.map((e) {
        int chkLen = e['NAME'].toString().length;
        if(e['NAME'] == val.substring(0, chkLen)) {
          rtnVal.add(e["CODE"]);
        }
      }).toList();
    }
    return rtnVal;
  }

  static dynamic findRegExpRtnList (List<dynamic> pList, String chkKey, dynamic expr){
    List<dynamic> rtnList = [];
    RegExp regex = new RegExp(expr);
    if(pList is List && pList.length > 0) {
      for(var i=0; i<pList.length; i++) {
        dynamic e = pList[i];
        if(e is Map && e.containsKey(chkKey) && regex.allMatches(e[chkKey].toString()).length > 0) {
          rtnList.add(e);
        }
      }
    }

    return rtnList;
  }

  static List<dynamic> changeValueFromList (List<dynamic> pList, String chkKey, dynamic chkVal, String changeKey, dynamic changeVal){
    pList.map((e) {
      if(e.containsKey(chkKey) && e[chkKey] == chkVal) {
        if(e.containsKey(changeKey)) e[changeKey] = changeVal;
      }
    }).toString();

    return pList;
  }

  static List<dynamic> changeKeyValFromList (List<dynamic> pList, String changeKey, dynamic changeVal){
    pList.map((e) {
      if(e.containsKey(changeKey)) {
        e[changeKey] = changeVal;
      }
    }).toString();

    return pList;
  }

  static dynamic findMapFromList (List<dynamic> pList, String chkKey, dynamic chkVal){
    dynamic rtnObj = {};

    if(pList is List && pList.length > 0) {
      for(var i=0; i<pList.length; i++) {
        dynamic e = pList[i];
        if(e is Map && e.containsKey(chkKey) && e[chkKey] == chkVal) {
          return e;
        }
      }
    }

    return rtnObj;
  }

  static dynamic findValueFromMap (dynamic pMap, String pKey){
    dynamic rtnVal;

    if(pMap is Map && pMap.containsKey(pKey)) {
      rtnVal = pMap[pKey] == null ? "" : pMap[pKey];
    } else {
      rtnVal = "";
    }

    String returnStr = rtnVal.toString();

    if(pKey == "ITEM_DESC"){
      if(returnStr.length > 15){
        List<String> descArr = returnStr.split(" ");
        if(descArr.length > 2){
          returnStr = "";
          for(int i =0; i < descArr.length; i++){
            returnStr += "${descArr[i]} ";
            if(i == 1){
              returnStr += "\r\n";
            }
          }
        }
      }
    }
    return returnStr;
  }

  static dynamic findIntValueFromMap (dynamic pMap, String pKey){
    dynamic rtnVal;

    if(pMap is Map && pMap.containsKey(pKey)) {
      if(pMap[pKey] == null || pMap[pKey] == ""){
        rtnVal = "";
      }
      else{
        if (pMap[pKey] is double) {
          rtnVal = pMap[pKey].toInt(); // 10.0 → 10
        }
        else{
          rtnVal = pMap[pKey];
        }
      }
    } else {
      rtnVal = "";
    }

    //int numVal = int.parse(rtnVal.toString());

    return rtnVal.toString();
  }

  static dynamic findDoubleValueFromMap (dynamic pMap, String pKey){
    dynamic rtnVal;

    if(pMap is Map && pMap.containsKey(pKey)) {
      if(pMap[pKey] == null || pMap[pKey] == ""){
        rtnVal = "";
      }
      else{
          rtnVal = pMap[pKey];
      }
    } else {
      rtnVal = "";
    }

    //int numVal = int.parse(rtnVal.toString());

    return rtnVal.toString();
  }

  static dynamic removeDash (String input){
    if(isNull(input)) return input;
    else return input.replaceAll('-', '');
  }

  static dynamic findObjectDef (dynamic pMap, String pKey, [dynamic def]){
    dynamic rtnVal;

    if(pMap is Map && pMap.containsKey(pKey)) {
      rtnVal = pMap[pKey];
    } else {
      rtnVal = def;
    }

    return rtnVal;
  }

  static String getString(dynamic o) {
    if(isEmpty(o))
      return "";
    else
      return o.toString();
  }

  static int getBetweenDt(String fDt, String tDt) {
    int strFdt = isNull(fDt) ? 0 : int.parse(removeDash(fDt));
    int strTdt = isNull(tDt) ? 0 : int.parse(removeDash(tDt));
    int rtnVal = 0;
    rtnVal = strTdt - strFdt;

    return rtnVal;
  }

  static String getAddDayStr(String dateStr, int addInt) {
    String rtnVal = "";

    if(!isNull(dateStr)) {
      DateTime dt = DateTime.parse(removeDash(dateStr));
      dt =  dt.add(Duration(days: addInt));
      rtnVal = formatDate(dt, [yyyy, '-', mm, '-', dd]);
    }
    return rtnVal;
  }

  static DateTime getDateFormStr(String dateStr) {
    DateTime dt;

    if(!isNull(dateStr)) {
      dt = DateTime.parse(removeDash(dateStr));
    }
    return dt;
  }

  static String getDateDashStr(dynamic dateStr) {
    String rtnVal = nullObjectDef(dateStr).toString();

    if(!isNull(dateStr)) {
      DateTime dt = DateTime.parse(dateStr);
      rtnVal = formatDate(dt, [yyyy, '-', mm, '-', dd]);
    }

    return rtnVal;
  }

  static void selectAll(TextEditingController obj) {
    if(isEmpty(obj)) return;

    obj.selection = TextSelection(baseOffset: 0,extentOffset: obj.text.length,);
  }

  static double pageMaxHeight(BuildContext context, [double size]) {
    if(CommonUtil.isEmpty(size))
      size = 0;
    return MediaQuery.of(context).size.height + 150 + size;
  }

  static void hideKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
  }

  static void showKeyboard() {
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  // 문자열 가운데를 ellipsis
  static String middleEllipsis(String text,
      {int head = 3, List<String> delimiters = const ['^', ';']}) {
    List<int> indices = [];

    // 모든 구분자의 인덱스 수집
    for (var d in delimiters) {
      int start = 0;
      while (true) {
        int idx = text.indexOf(d, start);
        if (idx == -1) break;
        indices.add(idx);
        start = idx + 1;
      }
    }

    if (indices.isEmpty) {
      // 구분자 없으면 기본 head/tail 방식
      int tail = 12;
      if (text.length <= head + tail) return text;
      return '${text.substring(0, head)}...${text.substring(text.length - tail)}';
    }

    // 내림차순으로 정렬 후 뒤에서 두 번째 구분자 찾기
    indices.sort();
    int splitIndex = indices.length >= 2
        ? indices[indices.length - 2] + 1
        : indices.last + 1;

    String tailStr = text.substring(splitIndex);
    return '${text.substring(0, head)}...$tailStr';
  }

  // 아래 두 함수
  static String formatValue(dynamic value) {
    if (value == null) return '';

    // 숫자인 경우
    if (value is num || double.tryParse(value.toString()) != null) {
      return formatDecimalWithComma(value);
    }

    // 날짜 문자열인지 검사 (2024-07-12 or 2024-07-12T14:00:00 등)
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}');
    if (value is String && dateRegex.hasMatch(value)) {
      final dt = DateTime.parse(value);
      final isDateOnly = dt.hour + dt.minute + dt.second == 0;
      return formatDateTime(
          value,
          isDateOnly
              ? DateFormatType.clientDate
              : DateFormatType.clientDateTime);
    }

    return value.toString();
  }

  // 날짜 형식 'yyyy-mm-dd 오전/오후 hh:mm'로 변환, 원복
  static String formatDateTime(String dateTimeStr,
      [DateFormatType type = DateFormatType.clientDateTime]) {
    DateTime dateTime;

    try {
      switch (type) {
        case DateFormatType.clientDateTime:
          dateTime = DateTime.parse(dateTimeStr);
          return DateFormat('yyyy-MM-dd a hh:mm', 'ko').format(dateTime);
          break;
        case DateFormatType.clientDate:
          dateTime = DateTime.parse(dateTimeStr);
          return DateFormat('yyyy-MM-dd').format(dateTime);
          break;
        case DateFormatType.server:
          dateTime = DateFormat('yyyy-MM-dd a hh:mm', 'ko').parse(dateTimeStr);
          return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
          break;
        default:
          dateTime = DateFormat('yyyy-MM-dd a hh:mm', 'ko').parse(dateTimeStr);
          return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
      }
    } catch (e) {
      print('formatDateTime error: $e');
      return dateTimeStr;
    }
  }

  static String formatDecimalWithComma(dynamic value,
      {bool oneDecimal = false, bool threeDecimal = false}) {
    if (value == null) return '0';

    double number =
    (value is num) ? value.toDouble() : double.tryParse(value.toString());

    if (number == null) {
      // 숫자 변환 실패 → 원래 문자열 그대로
      return value.toString();
    }

    // 소수점 이하가 없으면 정수로, 아니면 최대 소수점 두 자리까지 출력
    if (number == number.truncateToDouble()) {
      return NumberFormat('#,###').format(number);
    } else if (oneDecimal) {
      return NumberFormat('#,##0.0').format(number);
    } else if (threeDecimal) {
      return NumberFormat('#,##0.000').format(number);
    } else {
      return NumberFormat('#,##0.00').format(number);
    }
  }

  static String parseLotNo(String scannedValue){
    String returnVal = "";
    // LXMMA / CRYSTALUX / IH830C-4006-EIL / N25Y0621-12 / 800KG
    if(scannedValue.startsWith("LXMMA")){
      List<String> strArr = scannedValue.split("/");
      returnVal = strArr[3].trim();
    }
    // LX#MMA&LD8890HI+W1917J/N25Y0621-12!500KGS!$693594   12
    else if(scannedValue.startsWith("LX#") || scannedValue.startsWith("LG#")){
      List<String> strArr = scannedValue.split("/");
      String Temp = strArr[1].trim();
      List<String> tmpArr = Temp.split("!");
      returnVal = tmpArr[0].trim();
    }else{
      returnVal = scannedValue;
    }

    returnVal = returnVal.replaceAll(" ", "-");

    return returnVal;
  }
}

