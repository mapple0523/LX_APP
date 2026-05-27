import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/inn/INN0004MP01.dart';
import 'package:dtwms_app/pages/inn/INN0005MP01.dart';
import 'package:dtwms_app/pages/inn/INN0005MP02.dart';
import 'package:dtwms_app/pages/stk/STK0006MP02.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class INN0005M extends StatefulWidget {
  @override
  _INN0005M createState() => _INN0005M();
}

class _INN0005M extends State<INN0005M>  {

  Future<dynamic> _callNaviOne() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => INN0005MP01()));
  }

  Future<dynamic> _callNaviTwo() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => INN0005MP02()));
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
        appBar: pageAppBar(context, "shuttleInSearch"),
        body: Container(
          child: Column(
              children: <Widget> [
                // CommonActionBtn("shuttleSearch",
                //   height: (MediaQuery.of(context).size.height- pageAppBar(context, "pack").preferredSize.height-30) * 0.3,
                //   width: 337,
                //   fontSize: 23,
                //   borderRadius : 30,
                //   padding: 10,
                //   onPressed: _callNaviOne,
                // ),
                CommonActionBtn("shuttleDetailSearch",
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