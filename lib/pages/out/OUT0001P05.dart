import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/inn/INN0005MP01.dart';
import 'package:dtwms_app/pages/inn/INN0005MP02.dart';
import 'package:dtwms_app/pages/out/OUT0001M.dart';
import 'package:dtwms_app/pages/out/OUT0001P06.dart';
import 'package:dtwms_app/pages/out/OUT0002P01.dart';
import 'package:dtwms_app/pages/out/OUT0002P02.dart';
import 'package:dtwms_app/pages/out/OUT0005MP02.dart';
import 'package:dtwms_app/pages/out/OUT0005P01.dart';
import 'package:dtwms_app/pages/out/OUT0005P04.dart';
import 'package:dtwms_app/pages/out/OUTSAMPLE.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OUT0001P05 extends StatefulWidget {
  @override
  _OUT0001P05 createState() => _OUT0001P05();
}

class _OUT0001P05 extends State<OUT0001P05>  {

  Future<dynamic> _callNaviOne() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0001M()));
  }

  Future<dynamic> _callNaviTwo() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0001P06()));
  }

  Future<dynamic> _callNaviTEST() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUTSAMPLE()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ZebraDataWedgeListener.initFunc();
    return Scaffold(
        resizeToAvoidBottomInset : false,
        appBar: pageAppBar(context, "출고"),
        body: Container(
          child: Column(
              children: <Widget> [
                CommonActionBtn("피킹",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  padding: 10,
                  onPressed: _callNaviOne,
                ),
                CommonActionBtn("분할피킹",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  onPressed: _callNaviTwo,
                ),
                // CommonActionBtn("TEST",
                //   height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                //   width: 337,
                //   fontSize: 23,
                //   borderRadius : 30,
                //   onPressed: _callNaviTEST,
                // ),
              ]
          ),
        )
    );
  }
}