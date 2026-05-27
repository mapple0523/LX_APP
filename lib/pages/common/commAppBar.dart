import 'dart:async';
import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/constants/pageConstant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/pages/sys/Language_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ota_update/ota_update.dart';
import 'message.dart';
import 'package:easy_localization/easy_localization.dart';

// 버전 체크
Future<void> _tryOtaUpdate() async {
  try {
    OtaUpdate()
        .execute(
      Constant.serverUrl + Constant.appUpdatePrefix,
      destinationFilename: Constant.appUpdateName,
    )
        .listen((OtaEvent event) {
      print(event.status);
    });
  } catch (e) {
    print('Failed to make OTA update. Details: $e');
  }
}

class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();
  factory VersionCheckService() => _instance;
  VersionCheckService._internal();

  Timer _timer;
  bool _isRunning = false;       // 타이머 동작 중 여부
  bool _isDialogShowing = false; // confirm 여부
  DateTime _lastChecked;

  void start(BuildContext context) {
    if (_isRunning) return;
    _isRunning = true;

    _checkVersion(context);

    _timer = Timer.periodic(Duration(hours: 1), (timer) {
      _checkVersion(context);
    });
  }

  void stop() {
    if (_timer != null) {
      _timer.cancel();
    }
    _isRunning = false;
  }

  Future<void> _checkVersion(BuildContext context) async {
    if (_isDialogShowing) return;
    
    if (_lastChecked != null &&
        DateTime.now().difference(_lastChecked).inHours < 1) return;
    _lastChecked = DateTime.now();

    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      dynamic param = {};
      param['versionName'] = packageInfo.version;
      param['versionCode'] = packageInfo.buildNumber;

      var rtnData = await transaction(context, "common/checkVersion.do", param);

      if (rtnData) {
        _isDialogShowing = true;
        bool result = await confirmDialog(context, "업데이트", "새로운 버전이 있습니다.\n업데이트 하시겠습니까?");
        _isDialogShowing = false; 
        if (result) {
          _tryOtaUpdate();
        }
      }
    } catch (e) {
      _isDialogShowing = false; 
      print("Version check error: $e");
    }
  }
}

defaultAppBar(BuildContext context, String pTitle, {List<Widget> actions = const []}) {
  //VersionCheckService().start(context);

  return AppBar(
    title: Text(getTranslated(context, pTitle), style: TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    elevation: 0.0,
    automaticallyImplyLeading: false,
    backgroundColor: Color.fromRGBO(34, 38, 41, 1),
    foregroundColor: Color.fromRGBO(255, 255, 255, 1),
    leading: IconButton(
      icon: Icon(Icons.logout),
      disabledColor: Color(0XFFFFFFFF),
      onPressed: () {
        confirmDialog(context, "로그아웃", "로그아웃 하시겠습니까?")
            .then((value) { if (value == true) callLogout(context); });
      },
    ),
    actions: actions,
  );
}

pageAppBar(BuildContext context, String pTitle, [dynamic param]) {
  //VersionCheckService().start(context);

  return AppBar(
    title: Text(getTranslated(context, pTitle), style: TextStyle(fontWeight: FontWeight.bold)),
    centerTitle: true,
    elevation: 0.0,
    automaticallyImplyLeading: false,
    leading: _backPage(context, param),
    backgroundColor: Color.fromRGBO(34, 38, 41, 1),
    foregroundColor: Color.fromRGBO(255, 255, 255, 1),
    actions: <Widget>[
      IconButton(
        icon: Icon(Icons.home),
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(
            context,
            PageConstant.routeNameMenu,
                (route) => false,
          );
        },
      ),
    ],
  );
}

commonAppBar(BuildContext context, String pTitle) {
  return AppBar(
    title: Text(pTitle),
    centerTitle: true,
    elevation: 0.0,
    automaticallyImplyLeading: true,
    leading: _logout(context),
  );
}

_logout(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.logout),
    onPressed: () {
      confirmDialog(context, "로그아웃", "로그아웃 하시겠습니까?")
          .then((value) { if (value == true) callLogout(context); });
    },
  );
}

_backPage(BuildContext context, [param]) {
  return IconButton(
    icon: const Icon(Icons.navigate_before),
    onPressed: () {
      Navigator.pop(context, param);
    },
  );
}