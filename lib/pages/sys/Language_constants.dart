import 'dart:ui';

import 'package:dtwms_app/pages/sys/AppLocalizations.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String KOREA   = 'ko';
const String CHINA   = 'zh';

Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');
    case CHINA:
      return Locale(CHINA,'CN');
    case KOREA:
      return Locale(KOREA,'');
    default:
      return Locale(KOREA, '');
  }
}

String getTranslated(BuildContext context, String key) {
  return CommonUtil.isNull(AppLocalizations.of(context).translate(key))?key:AppLocalizations.of(context).translate(key) ;
}