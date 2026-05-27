import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/out/OUT0002P01.dart';
import 'package:dtwms_app/pages/out/OUT0002P02.dart';
import 'package:dtwms_app/pages/out/OUT0002P05.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OUT0002M extends StatefulWidget {
  @override
  _OUT0002M createState() => _OUT0002M();
}

class _OUT0002M extends State<OUT0002M>  {

  Future<dynamic> _callNaviOne() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0002P01()));
  }

  Future<dynamic> _callNaviTwo() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0002P02()));
  }

  Future<dynamic> _callNaviThree() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => OUT0002P05()));
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
        appBar: pageAppBar(context, "manageSerial"),
        body: Container(
          child: Column(
              children: <Widget> [
                CommonActionBtn("registerSerial",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  padding: 10,
                  onPressed: _callNaviOne,
                ),
                CommonActionBtn("removeSerial",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  onPressed: _callNaviTwo,
                ),
                CommonActionBtn("returnSerial",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "manageSerial").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  padding: 10,
                  onPressed: _callNaviThree,
                ),
              ]
          ),
        )
    );
  }
}