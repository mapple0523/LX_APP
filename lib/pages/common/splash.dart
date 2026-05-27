import 'package:dtwms_app/commons/constants/constant.dart';
import 'package:dtwms_app/commons/constants/imageConstant.dart';
import 'package:dtwms_app/commons/constants/pageConstant.dart';
import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/pages/common/textMaker.dart';
import "package:flutter/material.dart";
import "dart:async";

import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';


class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  OtaEvent currentEvent;
  @override
  void initState() {
    super.initState();
    _routePage();
  }

  _routePage() async {
    await Future.delayed(Duration(seconds: 3));
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    dynamic param = {};
    param['versionName']  = packageInfo.version;
    param['versionCode']  = packageInfo.buildNumber;
    var rtnData = await transaction(context, "common/checkVersion.do", param);
    //var rtnData = false;
    if( rtnData) {
      tryOtaUpdate();
    } else {
      return Navigator.pushReplacementNamed(context, PageConstant.routeNameLogin);
    }
  }

  Future<void> tryOtaUpdate() async {
    try {
      //LINK CONTAINS APK OF FLUTTER HELLO WORLD FROM FLUTTER SDK EXAMPLES
      OtaUpdate()
          .execute(
        Constant.serverUrl + Constant.appUpdatePrefix,
        destinationFilename: Constant.appUpdateName,
        //FOR NOW ANDROID ONLY - ABILITY TO VALIDATE CHECKSUM OF FILE:
        //sha256checksum: 'd6da28451a1e15cf7a75f2c3f151befad3b80ad0bb232ab15c20897e54f21478',
      )
          .listen(
            (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  Widget _buildBody() {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant.loginBgImg),
            fit: BoxFit.cover,
          )
      ),
      padding: EdgeInsets.all(30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            widgetAppTitleAndLogo(),
            Column(children: <Widget>[
              CircularProgressIndicator(
                // backgroundColor: Colors.pink,
                // valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Please Wait....",
              )
            ]),
            widgetCopyRight(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }
}
