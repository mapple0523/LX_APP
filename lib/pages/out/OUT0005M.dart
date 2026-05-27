import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/inn/INN0005MP01.dart';
import 'package:dtwms_app/pages/inn/INN0005MP02.dart';
import 'package:dtwms_app/pages/out/OUT0002P01.dart';
import 'package:dtwms_app/pages/out/OUT0002P02.dart';
import 'package:dtwms_app/pages/out/OUT0005MP02.dart';
import 'package:dtwms_app/pages/out/OUT0005P01.dart';
import 'package:dtwms_app/pages/out/OUT0005P04.dart';
import 'package:dtwms_app/pages/out/OUTSAMPLE.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OUT0005M extends StatefulWidget {
  @override
  _OUT0005M createState() => _OUT0005M();
}

class _OUT0005M extends State<OUT0005M>  {

  Future<dynamic> _callNaviOne() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0005P01()));
  }

  Future<dynamic> _callNaviTwo() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0005P04()));
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
                CommonActionBtn("carDispatch",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  padding: 10,
                  onPressed: _callNaviOne,
                ),
                CommonActionBtn("container",
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