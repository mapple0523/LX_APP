import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/stk/STK0006MP02.dart';
import 'package:dtwms_app/pages/stk/STK0006MP03.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'STK0006MP01.dart';

class STK0006M extends StatefulWidget {
  @override
  _STK0006M createState() => _STK0006M();
}

class _STK0006M extends State<STK0006M>  {

  Future<dynamic> _callNaviOne() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0006MP01()));
  }

  Future<dynamic> _callNaviTwo() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => STK0006MP02()));
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
        appBar: pageAppBar(context, "pack"),
        body: Container(
          child: Column(
              children: <Widget> [
                CommonActionBtn("boxPacking",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "pack").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  padding: 10,
                  onPressed: _callNaviOne,
                ),
                CommonActionBtn("palletPacking",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "pack").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  onPressed: _callNaviTwo,
                ),
              ]
          ),
        )
    );
  }
}