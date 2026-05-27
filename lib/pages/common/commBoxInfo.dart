import 'package:dtwms_app/commons/svcs/transaction.dart';
import 'package:dtwms_app/models/customGrid.dart';
import 'package:dtwms_app/models/zebraDataWedgeListener.dart';
import 'package:dtwms_app/utils/commonUtil.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_attachable/keyboard_attachable.dart';

import 'commAppBar.dart';

class OutBoxInfoPage extends StatefulWidget {
  const OutBoxInfoPage({Key key, this.param}) : super(key: key);

  final dynamic param;

  @override
  _OutBoxInfoPage createState() => _OutBoxInfoPage();
}

class _OutBoxInfoPage extends State<OutBoxInfoPage>{
  List<dynamic> _searchList = [];

  Future<void> _search() async {
    List<dynamic> rtnList = await transaction(context, "common/searchOutBoxList.do", widget.param);
    if(CommonUtil.isEmpty(rtnList))
      _searchList = [];
    else
      _searchList = rtnList;

    setState(() {

    });
  }
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _search();
    });
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
        resizeToAvoidBottomInset: false,
        appBar: pageAppBar(context, "boxList",false),
        body: FooterLayout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
                padding: EdgeInsets.only(left: 5),
                height : CommonUtil.pageMaxHeight(context,(55 * (_searchList.length - 7)).toDouble()),
                child: GestureDetector(
                    onTap: () {
                      CommonUtil.hideKeyboard();
                    },
                    child: Column(children: <Widget>[
                      Expanded(
                        child: CustomGrid(
                          ['outNo', 'materialCd','packQty'],
                          ['IF_OUT_NO', 'SHPR_ITEM_CD','BOX_QTY'],
                          _searchList,
                          enableRefresh: false,
                        ),
                      ),
                    ]))),
          ),
        ));
  }
}