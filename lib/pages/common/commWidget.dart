
import 'package:date_format/date_format.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'location.dart';
import 'zone.dart';

Future<DateTime> commonDatePicker(BuildContext context, DateTime initialDate) async {
  DateTime rtnDate = await showDatePicker(
    context: context,
    //locale: const Locale('ko', 'KO'),
    //initialDatePickerMode: DatePickerMode.day,
    //initialEntryMode: DatePickerEntryMode.calendar,
    initialDate: initialDate, // 초깃값
    firstDate: DateTime(2018), // 시작일
    lastDate: DateTime(2040), // 마지막일
    builder: (BuildContext context, Widget child) {
      return Theme(
        data: ThemeData.dark(), // 다크테마
        child: child,
      );
    },
  );

  if(!CommonUtil.isEmpty(rtnDate)) {
    if(CommonUtil.isNull(formatDate(rtnDate, [yyyy, mm, dd])))
      rtnDate = initialDate;
    else
      initialDate = rtnDate;
  }

  return rtnDate;
}

// Location 선택 창.
Future<dynamic> navigateLocationSelection(BuildContext context, [dynamic param]) async {
  final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => LocationPage(param: param)));
  return result;
}

// Zone 선택 창
Future<dynamic> navigateZoneSelection(BuildContext context, [dynamic param]) async {
  final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => ZonePage(param: param)));
  return result;
}
