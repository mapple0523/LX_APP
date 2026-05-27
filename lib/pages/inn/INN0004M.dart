import 'package:dtwms_app/models/commonActionBtn.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/pages/common/commAppBar.dart';
import 'package:dtwms_app/pages/inn/INN0004MP01.dart';
import 'package:dtwms_app/pages/inn/INN0004MP02.dart';
import 'package:dtwms_app/pages/stk/STK0006MP02.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class INN0004M extends StatefulWidget {
  @override
  _INN0004M createState() => _INN0004M();
}

class _INN0004M extends State<INN0004M>  {

  Future<dynamic> _callNaviOne() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => INN0004MP02()));
  }

  Future<dynamic> _callNaviTwo() async {
    final result = await Navigator.push(context, MaterialPageRoute(fullscreenDialog: true, builder: (context) => INN0004MP01()));
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
        appBar: pageAppBar(context, "생산"),
        body: Container(
          child: Column(
              children: <Widget> [
                CommonActionBtn("productionRegister",
                  height: (MediaQuery.of(context).size.height- pageAppBar(context, "pack").preferredSize.height-30) * 0.3,
                  width: 337,
                  fontSize: 23,
                  borderRadius : 30,
                  padding: 10,
                  onPressed: _callNaviOne,
                ),
                // CommonActionBtn("workOrderSearch",
                //   height: (MediaQuery.of(context).size.height- pageAppBar(context, "pack").preferredSize.height-30) * 0.3,
                //   width: 337,
                //   fontSize: 23,
                //   borderRadius : 30,
                //   onPressed: _callNaviTwo,
                // ),
              ]
          ),
        )
    );
  }
}